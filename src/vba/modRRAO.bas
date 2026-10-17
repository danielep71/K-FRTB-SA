Attribute VB_Name = "modRRAO"
'==============================================================================
' modRRAO
' Residual risk add-on (MAR23): gross notional x risk weight, where the risk
' weight depends on whether the residual risk is exotic or other.
'==============================================================================
Option Explicit

Private mTotal As Double

Public Function RraoTotal() As Double
    RraoTotal = mTotal
End Function

Public Sub RunRRAO()
    Dim ws As Object, r As Long, src As String, category As String
    Dim rw As Double, found As Boolean
    mTotal = 0#
    Set ws = GetSheet(SH_IN_RRAO)
    r = 2
    Do While Not (IsBlank(ws.Cells(r, 1).Value) And IsBlank(ws.Cells(r, 2).Value))
        src = SH_IN_RRAO & " row " & r
        category = ToText(ws.Cells(r, 2).Value)
        rw = RraoRiskWeight(category, found)
        If Not found Then
            LogMessage "ERROR", src, "Unknown RRAO category '" & category & "'; row skipped"
        ElseIf Not IsNumber(ws.Cells(r, 3).Value) Then
            LogMessage "ERROR", src, "Gross notional is not numeric; row skipped"
        ElseIf ToDouble(ws.Cells(r, 3).Value, 0#) < 0# Then
            LogMessage "ERROR", src, "Gross notional must be non-negative; row skipped"
        Else
            mTotal = mTotal + rw * ToDouble(ws.Cells(r, 3).Value, 0#)
        End If
        r = r + 1
    Loop
End Sub
