Attribute VB_Name = "modUtil"
'==============================================================================
' modUtil
' Sheet access, tagged parameter tables, key lookup, numeric helpers and the
' run log. No regulatory logic lives here.
'
' Parameter sheets hold blocks introduced by a tag cell in column A, such as
' "[GIRR_RW]". The row below the tag is the header; data rows follow until the
' first blank cell in column A.
'==============================================================================
Option Explicit

Public Const ERR_APP As Long = 1000
Private Const TAG_SCAN_ROWS As Long = 1000

Private mLogRow As Long
Private mErrorCount As Long
Private mWarningCount As Long

'------------------------------------------------------------------------------
' Sheets
'------------------------------------------------------------------------------
Public Function SheetExists(ByVal sheetName As String) As Boolean
    Dim ws As Object
    Set ws = Nothing
    On Error Resume Next
    Set ws = ThisWorkbook.Worksheets(sheetName)
    Err.Clear
    On Error GoTo 0
    SheetExists = Not (ws Is Nothing)
End Function

Public Function GetSheet(ByVal sheetName As String) As Object
    If Not SheetExists(sheetName) Then
        Err.Raise vbObjectError + ERR_APP, "GetSheet", "Sheet not found: " & sheetName
    End If
    Set GetSheet = ThisWorkbook.Worksheets(sheetName)
End Function

Public Sub ClearSheet(ByVal sheetName As String)
    GetSheet(sheetName).Cells.Clear
End Sub

'------------------------------------------------------------------------------
' Tagged tables
'------------------------------------------------------------------------------
Public Function FindTagRow(ByVal ws As Object, ByVal tag As String) As Long
    Dim r As Long
    FindTagRow = 0
    For r = 1 To TAG_SCAN_ROWS
        If UCase$(Trim$(CStr(ws.Cells(r, 1).Value))) = "[" & UCase$(tag) & "]" Then
            FindTagRow = r
            Exit Function
        End If
    Next r
End Function

' Returns the data rows of a tagged table as a 1-based 2D array
' (rows x columns) and sets nRows/nCols. Raises an error if the tag is missing.
Public Function ReadTable(ByVal sheetName As String, ByVal tag As String, _
                          ByRef nRows As Long, ByRef nCols As Long) As Variant
    Dim ws As Object, tagRow As Long, r As Long, c As Long
    Dim data() As Variant

    Set ws = GetSheet(sheetName)
    tagRow = FindTagRow(ws, tag)
    If tagRow = 0 Then
        Err.Raise vbObjectError + ERR_APP, "ReadTable", _
                  "Table [" & tag & "] not found on sheet " & sheetName
    End If

    nCols = 0
    Do While Trim$(CStr(ws.Cells(tagRow + 1, nCols + 1).Value)) <> ""
        nCols = nCols + 1
    Loop
    nRows = 0
    Do While Trim$(CStr(ws.Cells(tagRow + 2 + nRows, 1).Value)) <> ""
        nRows = nRows + 1
    Loop

    If nRows = 0 Or nCols = 0 Then
        ReadTable = Empty
        Exit Function
    End If

    ReDim data(1 To nRows, 1 To nCols)
    For r = 1 To nRows
        For c = 1 To nCols
            data(r, c) = ws.Cells(tagRow + 1 + r, c).Value
        Next c
    Next r
    ReadTable = data
End Function

' Reads a two-column [TAG] Key | Value table into a Collection keyed by
' upper-case key.
Public Function ReadKeyValues(ByVal sheetName As String, ByVal tag As String) As Collection
    Dim t As Variant, nRows As Long, nCols As Long, r As Long
    Dim col As New Collection
    t = ReadTable(sheetName, tag, nRows, nCols)
    For r = 1 To nRows
        On Error Resume Next
        col.Add t(r, 2), UCase$(Trim$(CStr(t(r, 1))))
        If Err.Number <> 0 Then
            Err.Clear
            On Error GoTo 0
            LogMessage "WARN", sheetName, "Duplicate key ignored in [" & tag & "]: " & CStr(t(r, 1))
        End If
        On Error GoTo 0
    Next r
    Set ReadKeyValues = col
End Function

' Value of a required key; raises an error when missing.
Public Function KVNumber(ByVal col As Collection, ByVal key As String, ByVal source As String) As Double
    Dim v As Variant
    If Not KeyExists(col, key) Then
        Err.Raise vbObjectError + ERR_APP, "KVNumber", "Missing parameter " & key & " (" & source & ")"
    End If
    v = col.Item(UCase$(key))
    KVNumber = ToDouble(v, 0#)
End Function

Public Function KVText(ByVal col As Collection, ByVal key As String, ByVal defaultValue As String) As String
    If KeyExists(col, key) Then
        KVText = Trim$(CStr(col.Item(UCase$(key))))
    Else
        KVText = defaultValue
    End If
End Function

Public Function KVBool(ByVal col As Collection, ByVal key As String, ByVal defaultValue As Boolean) As Boolean
    If KeyExists(col, key) Then
        KVBool = ToBool(col.Item(UCase$(key)), defaultValue)
    Else
        KVBool = defaultValue
    End If
End Function

'------------------------------------------------------------------------------
' Collections used as key -> value maps (keys are case-insensitive)
'------------------------------------------------------------------------------
Public Function KeyExists(ByVal col As Collection, ByVal key As String) As Boolean
    Dim v As Variant
    On Error GoTo Missing
    v = col.Item(UCase$(key))
    KeyExists = True
    Exit Function
Missing:
    KeyExists = False
End Function

' Index stored under key, or 0 when the key is absent.
Public Function KeyIndex(ByVal col As Collection, ByVal key As String) As Long
    Dim v As Variant
    On Error GoTo Missing
    v = col.Item(UCase$(key))
    KeyIndex = CLng(v)
    Exit Function
Missing:
    KeyIndex = 0
End Function

Public Sub AddKey(ByVal col As Collection, ByVal key As String, ByVal value As Variant)
    col.Add value, UCase$(key)
End Sub

'------------------------------------------------------------------------------
' Conversions and numerics
'------------------------------------------------------------------------------
Public Function IsBlank(ByVal v As Variant) As Boolean
    If IsEmpty(v) Then
        IsBlank = True
    ElseIf IsError(v) Then
        IsBlank = False
    Else
        IsBlank = (Trim$(CStr(v)) = "")
    End If
End Function

' Converts a cell value to Double. Strings are parsed with Val so that "0.5"
' is read the same way under every regional setting.
Public Function ToDouble(ByVal v As Variant, ByVal defaultValue As Double) As Double
    If IsBlank(v) Or IsError(v) Then
        ToDouble = defaultValue
    ElseIf VarType(v) = vbString Then
        ToDouble = Val(Trim$(CStr(v)))
    Else
        ToDouble = CDbl(v)
    End If
End Function

Public Function IsNumber(ByVal v As Variant) As Boolean
    If IsBlank(v) Or IsError(v) Then
        IsNumber = False
    ElseIf VarType(v) = vbString Then
        IsNumber = IsNumeric(Trim$(CStr(v)))
    Else
        IsNumber = IsNumeric(v)
    End If
End Function

Public Function ToBool(ByVal v As Variant, ByVal defaultValue As Boolean) As Boolean
    Dim s As String
    If IsBlank(v) Or IsError(v) Then
        ToBool = defaultValue
        Exit Function
    End If
    If VarType(v) = vbBoolean Then
        ToBool = CBool(v)
        Exit Function
    End If
    s = UCase$(Trim$(CStr(v)))
    Select Case s
        Case "TRUE", "YES", "Y", "1", "-1"
            ToBool = True
        Case "FALSE", "NO", "N", "0"
            ToBool = False
        Case Else
            ToBool = defaultValue
    End Select
End Function

Public Function ToText(ByVal v As Variant) As String
    If IsBlank(v) Or IsError(v) Then
        ToText = ""
    Else
        ToText = UCase$(Trim$(CStr(v)))
    End If
End Function

' Bucket label: integers for numbered risk classes, upper-case text otherwise.
Public Function BucketLabel(ByVal v As Variant) As String
    If IsNumber(v) Then
        BucketLabel = CStr(CLng(ToDouble(v, 0#)))
    Else
        BucketLabel = ToText(v)
    End If
End Function

Public Function MaxD(ByVal a As Double, ByVal b As Double) As Double
    If a > b Then MaxD = a Else MaxD = b
End Function

Public Function MinD(ByVal a As Double, ByVal b As Double) As Double
    If a < b Then MinD = a Else MinD = b
End Function

Public Function NearlyEqual(ByVal a As Double, ByVal b As Double) As Boolean
    NearlyEqual = (Abs(a - b) <= 0.0000001 * MaxD(1#, MaxD(Abs(a), Abs(b))))
End Function

' Locale-independent key for a maturity or tenor in years.
Public Function TenorKey(ByVal t As Double) As String
    TenorKey = CStr(CLng(Round(t * 10000#, 0)))
End Function

' Parses "0.25,0.5,1" into a 1-based Double array; returns the count.
Public Function ParseNumberList(ByVal s As String, ByRef values() As Double) As Long
    Dim parts As Variant, i As Long, n As Long
    n = 0
    If Trim$(s) = "" Then
        ReDim values(1 To 1)
        ParseNumberList = 0
        Exit Function
    End If
    parts = Split(s, ",")
    ReDim values(1 To UBound(parts) - LBound(parts) + 1)
    For i = LBound(parts) To UBound(parts)
        If Trim$(CStr(parts(i))) <> "" Then
            n = n + 1
            values(n) = Val(Trim$(CStr(parts(i))))
        End If
    Next i
    ParseNumberList = n
End Function

Public Function InNumberList(ByVal x As Double, ByRef values() As Double, ByVal n As Long) As Boolean
    Dim i As Long
    InNumberList = False
    For i = 1 To n
        If Abs(values(i) - x) < 0.000001 Then
            InNumberList = True
            Exit Function
        End If
    Next i
End Function

'------------------------------------------------------------------------------
' Sorting of bucket labels (numeric when both labels are numbers)
'------------------------------------------------------------------------------
Public Function BucketLess(ByVal a As String, ByVal b As String) As Boolean
    If IsNumeric(a) And IsNumeric(b) Then
        BucketLess = (Val(a) < Val(b))
    Else
        BucketLess = (a < b)
    End If
End Function

Public Sub SortLabels(ByRef labels() As String, ByVal n As Long)
    Dim i As Long, j As Long, tmp As String
    For i = 2 To n
        tmp = labels(i)
        j = i - 1
        Do While j >= 1
            If Not BucketLess(tmp, labels(j)) Then Exit Do
            labels(j + 1) = labels(j)
            j = j - 1
        Loop
        labels(j + 1) = tmp
    Next i
End Sub

'------------------------------------------------------------------------------
' Run log
'------------------------------------------------------------------------------
Public Sub ResetLog()
    Dim ws As Object
    Set ws = GetSheet(SH_LOG)
    ws.Cells.Clear
    ws.Cells(1, 1).Value = "Level"
    ws.Cells(1, 2).Value = "Source"
    ws.Cells(1, 3).Value = "Message"
    mLogRow = 1
    mErrorCount = 0
    mWarningCount = 0
End Sub

Public Sub LogMessage(ByVal level As String, ByVal source As String, ByVal message As String)
    Dim ws As Object
    If mLogRow < 1 Then mLogRow = 1
    Set ws = GetSheet(SH_LOG)
    mLogRow = mLogRow + 1
    ws.Cells(mLogRow, 1).Value = level
    ws.Cells(mLogRow, 2).Value = source
    ws.Cells(mLogRow, 3).Value = message
    If level = "ERROR" Then mErrorCount = mErrorCount + 1
    If level = "WARN" Then mWarningCount = mWarningCount + 1
End Sub

Public Function LogErrorCount() As Long
    LogErrorCount = mErrorCount
End Function

Public Function LogWarningCount() As Long
    LogWarningCount = mWarningCount
End Function
