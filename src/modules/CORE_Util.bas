Attribute VB_Name = "CORE_Util"
'==============================================================================
' MODULE: CORE_Util
'------------------------------------------------------------------------------
' PURPOSE
'   Provide sheet access, tagged parameter tables, keyed lookups, value
'   conversions, table formatting in the workbook palette and the run log.
'   No regulatory logic lives here.
'
' PUBLIC SURFACE
'   Sheets: SheetExists, GetSheet, TableCell, ClearTableArea.
'   Tagged tables: FindTagRow, ReadTable, ReadKeyValues, KVNumber, KVText,
'   KVBool. A tagged table starts with a heading cell in column C whose text
'   begins with "[TAG]"; the next row is the header and data rows follow
'   until the first blank cell in column C.
'   Keyed lookups on Collections: KeyExists, KeyIndex, AddKey.
'   Conversions: IsBlank, ToDouble, IsNumber, ToBool, ToText, BucketLabel,
'   MaxD, MinD, NearlyEqual, TenorKey, ParseNumberList, InNumberList.
'   Sorting: BucketLess, SortLabels.
'   Formatting: WriteTableHeader, FormatDataRows.
'   Log: ResetLog, LogMessage, LogErrorCount, LogWarningCount.
'
' DEPENDENCIES
'   CORE_Config for sheet names, layout and palette.
'
' STATE OWNERSHIP
'   Owns the log cursor and the error and warning counters of the current
'   run (mLogRow, mErrorCount, mWarningCount); ResetLog resets them.
'
' ERROR POLICY
'   GetSheet and ReadTable raise vbObjectError + ERR_APP for a missing sheet
'   or table. Formatting is cosmetic: a host that rejects a format property
'   leaves the cell unformatted instead of stopping the run.
'
' COMPATIBILITY
'   Excel VBA; also runs in LibreOffice Calc with VBA support for the
'   automated reconciliation. No references beyond the defaults.
'
' UPDATED  2026-10-17
'==============================================================================

'------------------------------------------------------------------------------
'                              MODULE SETTINGS
'------------------------------------------------------------------------------
Option Explicit
Option Private Module

'------------------------------------------------------------------------------
'                              MODULE CONSTANTS
'------------------------------------------------------------------------------
Public Const ERR_APP As Long = 2048                          'Offset from vbObjectError
Private Const TAG_SCAN_ROWS As Long = 1000                   'Rows searched for a table tag

'------------------------------------------------------------------------------
'                              MODULE STATE
'------------------------------------------------------------------------------
Private mLogRow As Long                                      'Last row written on the Log sheet
Private mErrorCount As Long                                  'ERROR lines of the current run
Private mWarningCount As Long                                'WARN lines of the current run

'------------------------------------------------------------------------------
'                                  SHEETS
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
        Err.Raise vbObjectError + ERR_APP, "CORE_Util.GetSheet", "Sheet not found: " & sheetName
    End If
    Set GetSheet = ThisWorkbook.Worksheets(sheetName)
End Function


' Cell in column k of a table that starts in LAYOUT_FIRST_COL (k = 1 is column C).
Public Function TableCell(ByVal ws As Object, ByVal r As Long, ByVal k As Long) As Object
    Set TableCell = ws.Cells(r, LAYOUT_FIRST_COL + k - 1)
End Function


' Clears everything from the table header row down, keeping the banner rows.
Public Sub ClearTableArea(ByVal ws As Object)
    ws.Range(ws.Cells(LAYOUT_HEADER_ROW, 1), ws.Cells(ws.Rows.Count, 60)).Clear
End Sub

'------------------------------------------------------------------------------
'                              TAGGED TABLES
'------------------------------------------------------------------------------
Public Function FindTagRow(ByVal ws As Object, ByVal tag As String) As Long
    Dim r As Long
    Dim marker As String
    marker = "[" & UCase$(tag) & "]"
    FindTagRow = 0
    For r = 1 To TAG_SCAN_ROWS
        If Left$(UCase$(Trim$(CStr(ws.Cells(r, LAYOUT_FIRST_COL).Value))), Len(marker)) = marker Then
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
        Err.Raise vbObjectError + ERR_APP, "CORE_Util.ReadTable", _
                  "Table [" & tag & "] not found on sheet " & sheetName
    End If

    nCols = 0
    Do While Trim$(CStr(TableCell(ws, tagRow + 1, nCols + 1).Value)) <> ""
        nCols = nCols + 1
    Loop
    nRows = 0
    Do While Trim$(CStr(TableCell(ws, tagRow + 2 + nRows, 1).Value)) <> ""
        nRows = nRows + 1
    Loop

    If nRows = 0 Or nCols = 0 Then
        ReadTable = Empty
        Exit Function
    End If

    ReDim data(1 To nRows, 1 To nCols)
    For r = 1 To nRows
        For c = 1 To nCols
            data(r, c) = TableCell(ws, tagRow + 1 + r, c).Value
        Next c
    Next r
    ReadTable = data
End Function


' Reads a [TAG] Key | Value table into a Collection keyed by upper-case key.
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


' Value of a required key; raises an error when missing or nonnumeric.
Public Function KVNumber(ByVal col As Collection, ByVal key As String, ByVal source As String) As Double
    Dim v As Variant
    If Not KeyExists(col, key) Then
        Err.Raise vbObjectError + ERR_APP, "CORE_Util.KVNumber", "Missing parameter " & key & " (" & source & ")"
    End If
    v = col.Item(UCase$(key))
    If Not IsNumber(v) Then
        Err.Raise vbObjectError + ERR_APP, "CORE_Util.KVNumber", _
                  "Invalid numeric parameter " & key & " (" & source & ")"
    End If
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
'                    COLLECTIONS AS KEY -> VALUE MAPS
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
'                          CONVERSIONS AND NUMERICS
'------------------------------------------------------------------------------
Public Function IsBlank(ByVal v As Variant) As Boolean
    If IsEmpty(v) Or IsNull(v) Then
        IsBlank = True
    ElseIf IsError(v) Then
        IsBlank = False
    Else
        IsBlank = (Trim$(CStr(v)) = "")
    End If
End Function


' Numeric cells retain their value. Text must match the complete invariant
' decimal grammar (optional sign, dot and E exponent); no grouping or comma.
' Blank/error optional values retain the caller's explicit default.
Public Function ToDouble(ByVal v As Variant, ByVal defaultValue As Double) As Double
    Dim parsed As Double
    If IsBlank(v) Or IsError(v) Then
        ToDouble = defaultValue
    ElseIf TryNumber(v, parsed) Then
        ToDouble = parsed
    Else
        Err.Raise vbObjectError + ERR_APP, "CORE_Util.ToDouble", _
                  "Invalid numeric value; use a numeric cell or dot-decimal text"
    End If
End Function


Public Function IsNumber(ByVal v As Variant) As Boolean
    Dim parsed As Double
    IsNumber = TryNumber(v, parsed)
End Function


' Shared validation/conversion path, independent of the host's text locale.
Private Function TryNumber(ByVal v As Variant, ByRef parsed As Double) As Boolean
    Dim s As String, pos As Long, digits As Long, ch As String
    On Error GoTo Invalid
    If IsEmpty(v) Or IsNull(v) Or IsError(v) Then Exit Function
    If VarType(v) = vbBoolean Or VarType(v) = vbDate Then Exit Function
    If VarType(v) = vbString Then
        s = Trim$(CStr(v))
        If Len(s) = 0 Then Exit Function
        pos = 1
        ch = Mid$(s, pos, 1)
        If ch = "+" Or ch = "-" Then pos = pos + 1
        digits = ReadDigits(s, pos)
        If Mid$(s, pos, 1) = "." Then
            pos = pos + 1
            digits = digits + ReadDigits(s, pos)
        End If
        If digits = 0 Then Exit Function
        If UCase$(Mid$(s, pos, 1)) = "E" Then
            pos = pos + 1
            ch = Mid$(s, pos, 1)
            If ch = "+" Or ch = "-" Then pos = pos + 1
            If ReadDigits(s, pos) = 0 Then Exit Function
        End If
        If pos <> Len(s) + 1 Then Exit Function
        parsed = Val(s)
    Else
        If Not IsNumeric(v) Then Exit Function
        parsed = CDbl(v)
    End If
    TryNumber = True
    Exit Function
Invalid:
    Err.Clear
    TryNumber = False
End Function


Private Function ReadDigits(ByVal s As String, ByRef pos As Long) As Long
    Dim first As Long, ch As String
    first = pos
    Do While pos <= Len(s)
        ch = Mid$(s, pos, 1)
        If ch < "0" Or ch > "9" Then Exit Do
        pos = pos + 1
    Loop
    ReadDigits = pos - first
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
' A non-integral number is returned as a label no bucket matches, so that
' 8.6 is rejected instead of being rounded into bucket 9.
Public Function BucketLabel(ByVal v As Variant) As String
    Dim x As Double
    If IsNumber(v) Then
        x = ToDouble(v, 0#)
        If x = Int(x) Then
            BucketLabel = CStr(CLng(x))
        Else
            BucketLabel = "NON-INTEGER " & CStr(v)
        End If
    Else
        BucketLabel = ToText(v)
    End If
End Function


' True for a blank cell or a number: optional numeric inputs (tenor,
' maturity, LGD override) must not read text as zero.
Public Function IsBlankOrNumber(ByVal v As Variant) As Boolean
    IsBlankOrNumber = IsBlank(v) Or IsNumber(v)
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
'          SORTING OF BUCKET LABELS (NUMERIC WHEN BOTH ARE NUMBERS)
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
'                    TABLE FORMATTING IN THE WORKBOOK PALETTE
'------------------------------------------------------------------------------
' Writes a header row starting at column C and formats it: white bold text
' on headerColor (COLOR_INPUT_HEADER for inputs, COLOR_OUTPUT_HEADER for
' outputs).
Public Sub WriteTableHeader(ByVal ws As Object, ByVal r As Long, ByVal headers As Variant, _
                            ByVal headerColor As Long)
    Dim i As Long, k As Long
    k = 0
    For i = LBound(headers) To UBound(headers)
        k = k + 1
        TableCell(ws, r, k).Value = headers(i)
    Next i
    On Error Resume Next
    With ws.Range(TableCell(ws, r, 1), TableCell(ws, r, k))
        .Font.Bold = True
        .Font.Color = COLOR_WHITE
        .Interior.Color = headerColor
        .VerticalAlignment = -4108                           'xlCenter
        .HorizontalAlignment = -4108
        .WrapText = True
    End With
    TableCell(ws, r, 1).HorizontalAlignment = -4131          'xlLeft for the key column
    ws.Rows(r).RowHeight = 30
    On Error GoTo 0
End Sub


' Formats rows r1..r2 of a table of nCols columns: thin grey borders, 10 pt,
' an optional number format for columns firstNumCol..nCols, and the input
' fill when the cells are meant to be edited.
Public Sub FormatDataRows(ByVal ws As Object, ByVal r1 As Long, ByVal r2 As Long, ByVal nCols As Long, _
                          ByVal firstNumCol As Long, ByVal numberFormat As String, ByVal isInput As Boolean)
    If r2 < r1 Then Exit Sub
    On Error Resume Next
    With ws.Range(TableCell(ws, r1, 1), TableCell(ws, r2, nCols))
        .Font.Size = 10
        .Borders.LineStyle = 1                               'xlContinuous
        .Borders.Color = COLOR_GRID
        If isInput Then .Interior.Color = COLOR_INPUT_CELL
    End With
    If firstNumCol > 0 And numberFormat <> "" Then
        ws.Range(TableCell(ws, r1, firstNumCol), TableCell(ws, r2, nCols)).NumberFormat = numberFormat
    End If
    On Error GoTo 0
End Sub

'------------------------------------------------------------------------------
'                                 RUN LOG
'------------------------------------------------------------------------------
Public Sub ResetLog()
    Dim ws As Object
    Set ws = GetSheet(SH_LOG)
    ClearTableArea ws
    WriteTableHeader ws, LAYOUT_HEADER_ROW, Array("Level", "Source", "Message"), COLOR_OUTPUT_HEADER
    mLogRow = LAYOUT_HEADER_ROW
    mErrorCount = 0
    mWarningCount = 0
End Sub


Public Sub LogMessage(ByVal level As String, ByVal source As String, ByVal message As String)
    Dim ws As Object
    If mLogRow < LAYOUT_HEADER_ROW Then mLogRow = LAYOUT_HEADER_ROW
    Set ws = GetSheet(SH_LOG)
    mLogRow = mLogRow + 1
    TableCell(ws, mLogRow, 1).Value = level
    TableCell(ws, mLogRow, 2).Value = source
    TableCell(ws, mLogRow, 3).Value = message
    FormatDataRows ws, mLogRow, mLogRow, 3, 0, "", False
    On Error Resume Next
    Select Case level
        Case "ERROR"
            TableCell(ws, mLogRow, 1).Interior.Color = COLOR_FAIL_FILL
            TableCell(ws, mLogRow, 1).Font.Color = COLOR_FAIL_TEXT
        Case "WARN"
            TableCell(ws, mLogRow, 1).Interior.Color = COLOR_WARN_FILL
            TableCell(ws, mLogRow, 1).Font.Color = COLOR_WARN_TEXT
    End Select
    On Error GoTo 0
    If level = "ERROR" Then mErrorCount = mErrorCount + 1
    If level = "WARN" Then mWarningCount = mWarningCount + 1
End Sub


Public Function LogErrorCount() As Long
    LogErrorCount = mErrorCount
End Function


Public Function LogWarningCount() As Long
    LogWarningCount = mWarningCount
End Function
