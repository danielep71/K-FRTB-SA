Attribute VB_Name = "TEST_Numeric"
'==============================================================================
' MODULE: TEST_Numeric
' PURPOSE
'   Assert numeric validation/conversion contracts with synthetic values.
' PUBLIC SURFACE
'   Test_NumericContracts_Silent: raise on any failed numeric contract.
' DEPENDENCIES
'   CORE_Util; development builds only, no worksheet state is modified.
' ERROR POLICY
'   A failed assertion raises an application error; no dialogs are shown.
' COMPATIBILITY
'   Excel VBA and LibreOffice VBA compatibility; no extra references.
'==============================================================================
Option Explicit

Public Sub Test_NumericContracts_Silent()
    Dim inputs As Variant, expected As Variant, invalid As Variant, item As Variant
    Dim i As Long, parsed As Double, captured As Long
    inputs = Array("0.5", ".5", "1.", "-1.25e2", "+2E-1", " 0.5 ")
    expected = Array(0.5, 0.5, 1#, -125#, 0.2, 0.5)
    For i = LBound(inputs) To UBound(inputs)
        If Not IsNumber(inputs(i)) Then Err.Raise vbObjectError + ERR_APP, "TEST_Numeric", "Valid text rejected"
        If Not NearlyEqual(ToDouble(inputs(i), -99#), expected(i)) Then
            Err.Raise vbObjectError + ERR_APP, "TEST_Numeric", "Numeric text amount changed"
        End If
    Next i
    If Not IsNumber(0.5) Or ToDouble(0.5, -99#) <> 0.5 Then
        Err.Raise vbObjectError + ERR_APP, "TEST_Numeric", "Typed numeric cell rejected"
    End If
    invalid = Array("abc", "0,5", "1,5", "1,000", "1.2junk", "1e", "1e309", "1 2", "$1", "NaN", "Infinity", "&H10", "1%")
    For Each item In invalid
        If IsNumber(item) Then Err.Raise vbObjectError + ERR_APP, "TEST_Numeric", "Invalid text accepted"
        On Error Resume Next
        parsed = ToDouble(item, -99#)
        captured = Err.Number
        Err.Clear
        On Error GoTo 0
        If captured = 0 Then Err.Raise vbObjectError + ERR_APP, "TEST_Numeric", "Invalid text converted"
    Next item
    invalid = Array("abc", "", Empty, Null, CVErr(2015), False)
    For Each item In invalid
        AssertInvalidRequired item
    Next item
    If IsNumber(True) Or IsNumber(Now) Then
        Err.Raise vbObjectError + ERR_APP, "TEST_Numeric", "Boolean or date accepted as number"
    End If
    If ToDouble(Empty, 99#) <> 99# Or ToDouble(CVErr(2015), 99#) <> 99# Then
        Err.Raise vbObjectError + ERR_APP, "TEST_Numeric", "Optional default changed"
    End If
End Sub


Private Sub AssertInvalidRequired(ByVal item As Variant)
    Dim kv As New Collection, parsed As Double, captured As Long, detail As String
    kv.Add item, "RW"
    On Error Resume Next
    parsed = KVNumber(kv, "RW", "NUMERIC_FIXTURE")
    captured = Err.Number
    detail = Err.Description
    Err.Clear
    On Error GoTo 0
    If captured = 0 Or InStr(detail, "RW") = 0 Or InStr(detail, "NUMERIC_FIXTURE") = 0 Then
        Err.Raise vbObjectError + ERR_APP, "TEST_Numeric", "Required parameter did not fail with context"
    End If
End Sub
