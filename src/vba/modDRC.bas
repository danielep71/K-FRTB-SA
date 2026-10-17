Attribute VB_Name = "modDRC"
'==============================================================================
' modDRC
' Default risk charge for non-securitizations (MAR22):
'   gross JTD -> maturity scaling -> obligor netting by seniority ->
'   hedge benefit ratio and risk-weighted bucket charge -> sum of buckets.
'==============================================================================
Option Explicit

Private mTotal As Double

Public Function DrcTotal() As Double
    DrcTotal = mTotal
End Function

Public Sub RunDRC()
    Dim ws As Object, r As Long, src As String, ok As Boolean, found As Boolean
    Dim n As Long, i As Long, j As Long, o As Long, nObl As Long, rk As Long, maxRank As Long
    Dim obligor As String, bucket As String, quality As String, seniority As String
    Dim notional As Double, mv As Double, maturity As Double, lgd As Double, jtd As Double, w As Double

    ' Positions after validation
    Dim pObl() As String, pBucket() As String, pQuality() As String, pRank() As Long, pJtd() As Double

    ' Obligors
    Dim oName() As String, oBucket() As String, oQuality() As String, oRW() As Double
    Dim oLong() As Double, oShort() As Double, oKeys As Collection
    Dim longByRank() As Double, shortByRank() As Double, carry As Double, offset As Double

    ' Buckets
    Dim nB As Long, bLong() As Double, bShort() As Double, bWLong() As Double, bWShort() As Double
    Dim hbr As Double, drcB As Double

    mTotal = 0#
    Set ws = GetSheet(SH_IN_DRC)
    maxRank = DrcMaxRank()

    ' Count rows
    n = 0
    r = 2
    Do While Not (IsBlank(ws.Cells(r, 1).Value) And IsBlank(ws.Cells(r, 2).Value))
        n = n + 1
        r = r + 1
    Loop
    ReDim pObl(1 To MaxL(n, 1))
    ReDim pBucket(1 To MaxL(n, 1))
    ReDim pQuality(1 To MaxL(n, 1))
    ReDim pRank(1 To MaxL(n, 1))
    ReDim pJtd(1 To MaxL(n, 1))

    ' 1. Gross JTD per position (MAR22.10-22.12) and maturity scaling (MAR22.17)
    j = 0
    For r = 2 To n + 1
        src = SH_IN_DRC & " row " & r
        obligor = ToText(ws.Cells(r, 2).Value)
        bucket = ToText(ws.Cells(r, 3).Value)
        quality = ToText(ws.Cells(r, 4).Value)
        seniority = ToText(ws.Cells(r, 5).Value)
        ok = True
        If obligor = "" Then
            LogMessage "ERROR", src, "Obligor is required; row skipped"
            ok = False
        ElseIf Not IsValidDrcBucket(bucket) Then
            LogMessage "ERROR", src, "Invalid DRC bucket '" & bucket & "'; row skipped"
            ok = False
        ElseIf DrcSeniorityRank(seniority) = 0 Then
            LogMessage "ERROR", src, "Unknown seniority '" & seniority & "'; row skipped"
            ok = False
        ElseIf Not IsNumber(ws.Cells(r, 6).Value) Or Not IsNumber(ws.Cells(r, 7).Value) Then
            LogMessage "ERROR", src, "Notional and market value must be numeric; row skipped"
            ok = False
        Else
            DrcRiskWeight quality, found
            If Not found Then
                LogMessage "ERROR", src, "Unknown credit quality '" & quality & "'; row skipped"
                ok = False
            End If
        End If
        If ok Then
            notional = ToDouble(ws.Cells(r, 6).Value, 0#)
            mv = ToDouble(ws.Cells(r, 7).Value, 0#)
            maturity = ToDouble(ws.Cells(r, 8).Value, DrcMaxMaturity())
            If IsNumber(ws.Cells(r, 9).Value) Then
                lgd = ToDouble(ws.Cells(r, 9).Value, 0#)
            Else
                lgd = DrcLGD(seniority, found)
            End If
            ' JTD = LGD x notional + P&L, with P&L = market value - notional (signed amounts)
            jtd = lgd * notional + (mv - notional)
            If notional >= 0# Then jtd = MaxD(jtd, 0#) Else jtd = MinD(jtd, 0#)
            w = MinD(MaxD(maturity, DrcMinMaturity()), DrcMaxMaturity()) / DrcMaxMaturity()
            j = j + 1
            pObl(j) = obligor
            pBucket(j) = bucket
            pQuality(j) = quality
            pRank(j) = DrcSeniorityRank(seniority)
            pJtd(j) = jtd * w
        End If
    Next r
    n = j

    ' 2. Obligors
    Set oKeys = New Collection
    nObl = 0
    ReDim oName(1 To MaxL(n, 1))
    ReDim oBucket(1 To MaxL(n, 1))
    ReDim oQuality(1 To MaxL(n, 1))
    For i = 1 To n
        o = KeyIndex(oKeys, pObl(i))
        If o = 0 Then
            nObl = nObl + 1
            oName(nObl) = pObl(i)
            oBucket(nObl) = pBucket(i)
            oQuality(nObl) = pQuality(i)
            AddKey oKeys, pObl(i), nObl
        Else
            If oBucket(o) <> pBucket(i) Then
                LogMessage "WARN", SH_IN_DRC, "Obligor " & pObl(i) & " has positions in several buckets; " & oBucket(o) & " is used"
            End If
            If oQuality(o) <> pQuality(i) Then
                LogMessage "WARN", SH_IN_DRC, "Obligor " & pObl(i) & " has several credit qualities; " & oQuality(o) & " is used"
            End If
        End If
    Next i

    ' 3. Net long/short per obligor (MAR22.19-22.20): a short offsets a long
    ' only when it ranks the same as, or junior to, the long. Ranks run from
    ' the most junior (1) to the most senior; unused shorts carry upward.
    ReDim oRW(1 To MaxL(nObl, 1))
    ReDim oLong(1 To MaxL(nObl, 1))
    ReDim oShort(1 To MaxL(nObl, 1))
    For o = 1 To nObl
        ReDim longByRank(1 To maxRank)
        ReDim shortByRank(1 To maxRank)
        For i = 1 To n
            If pObl(i) = oName(o) Then
                If pJtd(i) >= 0# Then
                    longByRank(pRank(i)) = longByRank(pRank(i)) + pJtd(i)
                Else
                    shortByRank(pRank(i)) = shortByRank(pRank(i)) - pJtd(i)
                End If
            End If
        Next i
        carry = 0#
        For rk = 1 To maxRank
            carry = carry + shortByRank(rk)
            offset = MinD(longByRank(rk), carry)
            oLong(o) = oLong(o) + longByRank(rk) - offset
            carry = carry - offset
        Next rk
        oShort(o) = carry
        oRW(o) = DrcRiskWeight(oQuality(o), found)
    Next o

    ' 4. Bucket charge (MAR22.23-22.24)
    nB = DrcBucketCount()
    ReDim bLong(1 To nB)
    ReDim bShort(1 To nB)
    ReDim bWLong(1 To nB)
    ReDim bWShort(1 To nB)
    For o = 1 To nObl
        i = DrcBucketIndex(oBucket(o))
        bLong(i) = bLong(i) + oLong(o)
        bShort(i) = bShort(i) + oShort(o)
        bWLong(i) = bWLong(i) + oRW(o) * oLong(o)
        bWShort(i) = bWShort(i) + oRW(o) * oShort(o)
    Next o

    WriteDrcOutput nObl, oName, oBucket, oQuality, oRW, oLong, oShort

    Dim wsOut As Object
    Set wsOut = GetSheet(SH_OUT_DRC)
    wsOut.Range("I1:N1").Value = Array("Bucket", "NetLong", "NetShort", "HBR", "WeightedLong", "WeightedShort")
    wsOut.Cells(1, 15).Value = "DRC"
    For i = 1 To nB
        If bLong(i) + bShort(i) > 0# Then
            hbr = bLong(i) / (bLong(i) + bShort(i))
        Else
            hbr = 0#
        End If
        drcB = MaxD(bWLong(i) - hbr * bWShort(i), 0#)
        mTotal = mTotal + drcB
        wsOut.Cells(i + 1, 9).Value = DrcBucketName(i)
        wsOut.Cells(i + 1, 10).Value = bLong(i)
        wsOut.Cells(i + 1, 11).Value = bShort(i)
        wsOut.Cells(i + 1, 12).Value = hbr
        wsOut.Cells(i + 1, 13).Value = bWLong(i)
        wsOut.Cells(i + 1, 14).Value = bWShort(i)
        wsOut.Cells(i + 1, 15).Value = drcB
    Next i
End Sub

Private Sub WriteDrcOutput(ByVal nObl As Long, ByRef oName() As String, ByRef oBucket() As String, _
                           ByRef oQuality() As String, ByRef oRW() As Double, _
                           ByRef oLong() As Double, ByRef oShort() As Double)
    Dim ws As Object, o As Long
    Set ws = GetSheet(SH_OUT_DRC)
    ws.Cells.Clear
    ws.Range("A1:F1").Value = Array("Obligor", "Bucket", "CreditQuality", "RW", "NetLong", "NetShort")
    For o = 1 To nObl
        ws.Cells(o + 1, 1).Value = oName(o)
        ws.Cells(o + 1, 2).Value = oBucket(o)
        ws.Cells(o + 1, 3).Value = oQuality(o)
        ws.Cells(o + 1, 4).Value = oRW(o)
        ws.Cells(o + 1, 5).Value = oLong(o)
        ws.Cells(o + 1, 6).Value = oShort(o)
    Next o
End Sub

Private Function MaxL(ByVal a As Long, ByVal b As Long) As Long
    If a > b Then MaxL = a Else MaxL = b
End Function
