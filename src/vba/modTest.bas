Attribute VB_Name = "modTest"
'==============================================================================
' modTest
' In-workbook regression test: compares the outputs of the last run with the
' [EXPECTED] table on Test_Expected. Items are either Out_Summary keys
' (e.g. "TOTAL") or "RiskClass|Component|Scenario" keys of Out_RiskClass
' (e.g. "GIRR|DELTA|MEDIUM").
'==============================================================================
Option Explicit

Private Const ABS_TOLERANCE As Double = 0.01
Private Const REL_TOLERANCE As Double = 0.000000001

Public Sub RunRegressionTest()
    Dim failures As Long, total As Long
    failures = ExecuteRegressionTest(total)
    If total = 0 Then
        MsgBox "No expected values found on " & SH_TEST & ".", vbExclamation, APP_NAME
    ElseIf failures = 0 Then
        MsgBox "Regression test PASSED (" & total & " items).", vbInformation, APP_NAME
    Else
        MsgBox "Regression test FAILED: " & failures & " of " & total & " items differ." & vbCrLf & _
               "See the " & SH_TEST & " sheet.", vbCritical, APP_NAME
    End If
End Sub

Public Sub RunRegressionTestSilent()
    Dim total As Long
    ExecuteRegressionTest total
End Sub

Private Function ExecuteRegressionTest(ByRef total As Long) As Long
    Dim ws As Object, r As Long, firstRow As Long, failures As Long
    Dim item As String, expected As Double, actual As Variant, diff As Double

    Set ws = GetSheet(SH_TEST)
    firstRow = FindTagRow(ws, "EXPECTED") + 2
    failures = 0
    total = 0
    r = firstRow
    Do While Not IsBlank(ws.Cells(r, 1).Value) And firstRow > 2
        item = CStr(ws.Cells(r, 1).Value)
        expected = ToDouble(ws.Cells(r, 2).Value, 0#)
        actual = ActualValue(item)
        total = total + 1
        If IsEmpty(actual) Then
            ws.Cells(r, 3).Value = "missing"
            ws.Cells(r, 4).Value = ""
            ws.Cells(r, 5).Value = "FAIL"
            failures = failures + 1
        Else
            diff = Abs(CDbl(actual) - expected)
            ws.Cells(r, 3).Value = CDbl(actual)
            ws.Cells(r, 4).Value = diff
            If diff <= ABS_TOLERANCE + REL_TOLERANCE * Abs(expected) Then
                ws.Cells(r, 5).Value = "PASS"
            Else
                ws.Cells(r, 5).Value = "FAIL"
                failures = failures + 1
            End If
        End If
        r = r + 1
    Loop
    If failures = 0 And total > 0 Then
        ws.Cells(2, 1).Value = "Result: PASS (" & total & " items)"
    Else
        ws.Cells(2, 1).Value = "Result: FAIL (" & failures & " of " & total & " items)"
    End If
    ExecuteRegressionTest = failures
End Function

Private Function ActualValue(ByVal item As String) As Variant
    Dim parts As Variant, ws As Object, r As Long, v As Variant
    ActualValue = Empty
    parts = Split(item, "|")
    If UBound(parts) = 2 Then
        Set ws = GetSheet(SH_OUT_CLASS)
        r = 2
        Do While Not IsBlank(ws.Cells(r, 1).Value)
            If CStr(ws.Cells(r, 1).Value) = parts(0) And CStr(ws.Cells(r, 2).Value) = parts(1) _
               And CStr(ws.Cells(r, 3).Value) = parts(2) Then
                ActualValue = ws.Cells(r, 4).Value
                Exit Function
            End If
            r = r + 1
        Loop
    Else
        v = OutSummaryValue(item)
        If IsNumber(v) Then ActualValue = ToDouble(v, 0#)
    End If
End Function
