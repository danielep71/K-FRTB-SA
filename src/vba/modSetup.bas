Attribute VB_Name = "modSetup"
'==============================================================================
' modSetup
' Builds the prototype workbook from scratch: sheets, default regulatory
' parameters (Basel MAR21-MAR23), a synthetic sample portfolio and the
' expected results used by the regression test.
'
'   Setup_BuildWorkbook  - rebuild every sheet (overwrites inputs!)
'   Setup_ResetParameters - rewrite the P_* sheets only
'   Setup_LoadSampleData - rewrite the In_* sheets only
'
' All parameter values below are defaults for review: verify them against
' the applicable regulatory text before relying on any result.
'==============================================================================
Option Explicit

Private Const HEADER_COLOR As Long = 14599344   ' RGB(176, 196, 222)
Private Const TAG_COLOR As Long = 15921906      ' RGB(242, 242, 242)

Public Sub Setup_BuildWorkbook()
    Dim names As Variant, i As Long
    SetAlerts False
    names = ManagedSheets()
    For i = LBound(names) To UBound(names)
        EnsureSheet CStr(names(i))
    Next i
    RemoveDefaultSheets

    BuildReadme
    BuildControl
    BuildResults
    BuildInputHeaders
    WriteParameters
    WriteSampleData
    WriteExpectedResults
    BuildOutputHeaders

    On Error Resume Next
    ThisWorkbook.Worksheets(SH_CONTROL).Activate
    On Error GoTo 0
    SetAlerts True
End Sub

Public Sub Setup_ResetParameters()
    SetAlerts False
    WriteParameters
    SetAlerts True
End Sub

Public Sub Setup_LoadSampleData()
    SetAlerts False
    BuildInputHeaders
    WriteSampleData
    SetAlerts True
End Sub

Public Function ManagedSheets() As Variant
    ManagedSheets = Array(SH_README, SH_CONTROL, SH_RESULTS, _
                          SH_IN_DELTA, SH_IN_VEGA, SH_IN_CURV, SH_IN_DRC, SH_IN_RRAO, _
                          SH_OUT_SUMMARY, SH_OUT_CLASS, SH_OUT_BUCKETS, SH_OUT_DRC, SH_LOG, _
                          SH_P_GENERAL, SH_P_GIRR, SH_P_CSR, SH_P_EQ, SH_P_COM, SH_P_FX, _
                          SH_P_DRC, SH_P_RRAO, SH_TEST)
End Function

'------------------------------------------------------------------------------
' Sheet helpers
'------------------------------------------------------------------------------
Private Sub SetAlerts(ByVal enabled As Boolean)
    On Error Resume Next
    Application.DisplayAlerts = enabled
    Application.ScreenUpdating = enabled
End Sub

Private Sub EnsureSheet(ByVal sheetName As String)
    Dim ws As Object, wb As Object
    Set wb = ThisWorkbook
    If SheetExists(sheetName) Then
        wb.Worksheets(sheetName).Cells.Clear
    Else
        Set ws = wb.Worksheets.Add(After:=wb.Worksheets(wb.Worksheets.Count))
        ws.Name = sheetName
    End If
End Sub

Private Function IsManaged(ByVal sheetName As String) As Boolean
    Dim names As Variant, i As Long
    names = ManagedSheets()
    IsManaged = False
    For i = LBound(names) To UBound(names)
        If UCase$(CStr(names(i))) = UCase$(sheetName) Then
            IsManaged = True
            Exit Function
        End If
    Next i
End Function

' Deletes blank sheets that are not part of the workbook layout (the default
' "Sheet1" of a new workbook). Sheets with content are never deleted.
Private Sub RemoveDefaultSheets()
    Dim i As Long, ws As Object
    For i = ThisWorkbook.Worksheets.Count To 1 Step -1
        Set ws = ThisWorkbook.Worksheets(i)
        If Not IsManaged(ws.Name) Then
            If IsBlank(ws.Cells(1, 1).Value) And IsBlank(ws.Cells(2, 1).Value) And IsBlank(ws.Cells(1, 2).Value) Then
                On Error Resume Next
                ws.Delete
                On Error GoTo 0
            End If
        End If
    Next i
End Sub

Private Sub PutRow(ByVal ws As Object, ByVal r As Long, ByVal values As Variant)
    Dim i As Long, c As Long
    c = 0
    For i = LBound(values) To UBound(values)
        c = c + 1
        ws.Cells(r, c).Value = values(i)
    Next i
End Sub

Private Sub StyleHeader(ByVal ws As Object, ByVal r As Long, ByVal nCols As Long)
    On Error Resume Next
    With ws.Range(ws.Cells(r, 1), ws.Cells(r, nCols))
        .Font.Bold = True
        .Interior.Color = HEADER_COLOR
    End With
End Sub

' Writes a tag line and a header line; returns the first data row.
Private Function PutTable(ByVal ws As Object, ByVal r As Long, ByVal tag As String, ByVal headers As Variant) As Long
    ws.Cells(r, 1).Value = "[" & tag & "]"
    On Error Resume Next
    ws.Cells(r, 1).Font.Bold = True
    ws.Cells(r, 1).Interior.Color = TAG_COLOR
    On Error GoTo 0
    PutRow ws, r + 1, headers
    StyleHeader ws, r + 1, UBound(headers) - LBound(headers) + 1
    PutTable = r + 2
End Function

Private Sub SetWidths(ByVal ws As Object, ByVal widths As Variant)
    Dim i As Long, c As Long
    On Error Resume Next
    c = 0
    For i = LBound(widths) To UBound(widths)
        c = c + 1
        ws.Columns(c).ColumnWidth = widths(i)
    Next i
End Sub

Private Sub AddButton(ByVal ws As Object, ByVal cellAddress As String, ByVal caption As String, ByVal macro As String)
    Dim btn As Object
    On Error Resume Next
    With ws.Range(cellAddress)
        Set btn = ws.Buttons.Add(.Left, .Top, 160, 24)
    End With
    If Not btn Is Nothing Then
        btn.Caption = caption
        btn.OnAction = macro
    End If
End Sub

'------------------------------------------------------------------------------
' README, Control, Results
'------------------------------------------------------------------------------
Private Sub BuildReadme()
    Dim ws As Object, lines As Variant, i As Long
    Set ws = GetSheet(SH_README)
    lines = Array( _
        APP_NAME & " " & APP_VERSION, _
        "Prototype of the FRTB standardized approach for market risk (Basel MAR21-MAR23).", _
        "", _
        "Scope: sensitivities-based method (delta, vega, curvature) for GIRR, CSR non-securitization,", _
        "equity, commodity and FX; default risk charge for non-securitizations; residual risk add-on.", _
        "Not implemented: CSR securitization (non-CTP and CTP), DRC securitization and CTP.", _
        "", _
        "How to use:", _
        "1. Review the settings on the Control sheet.", _
        "2. Enter sensitivities on In_Delta, In_Vega and In_Curvature, positions on In_DRC and In_RRAO.", _
        "3. Run RunAll (button on Control). Results, Out_* and Log are rewritten on every run.", _
        "4. Parameters are on the P_* sheets; edit them only after checking the regulatory text.", _
        "", _
        "Regression test: load the sample data (Setup_LoadSampleData), run RunAll, then RunRegressionTest.", _
        "", _
        "This workbook is a prototype. Results are not validated for regulatory reporting.")
    For i = LBound(lines) To UBound(lines)
        ws.Cells(i + 1, 1).Value = lines(i)
    Next i
    On Error Resume Next
    ws.Cells(1, 1).Font.Bold = True
    ws.Cells(1, 1).Font.Size = 14
    ws.Columns(1).ColumnWidth = 110
End Sub

Private Sub BuildControl()
    Dim ws As Object, r As Long
    Set ws = GetSheet(SH_CONTROL)
    ws.Cells(1, 1).Value = APP_NAME & " - Control"
    ws.Cells(2, 1).Value = "Run settings. Keys in column A are read by the engine; do not rename them."
    r = PutTable(ws, 4, "SETTINGS", Array("Key", "Value", "Description"))
    PutRow ws, r, Array("REPORTING_CCY", "EUR", "Reporting currency (FX sensitivities are against this currency)")
    PutRow ws, r + 1, Array("GIRR_SPECIFIED_CCY_DISCRETION", False, "TRUE: divide GIRR yield risk weights by sqrt(2) for specified currencies and the reporting currency (MAR21.44)")
    PutRow ws, r + 2, Array("FX_SPECIFIED_PAIR_DISCRETION", False, "TRUE: divide the FX risk weight by sqrt(2) for specified currency pairs (MAR21.88)")
    PutRow ws, r + 3, Array("FX_CURVATURE_DIVISOR", False, "TRUE: divide FX curvature CVRs by 1.5 (MAR21.98, subject to supervisory approval)")
    SetWidths ws, Array(34, 14, 100)
    On Error Resume Next
    ws.Cells(1, 1).Font.Bold = True
    ws.Cells(1, 1).Font.Size = 14
    On Error GoTo 0
    On Error Resume Next
    ws.Buttons.Delete
    On Error GoTo 0
    AddButton ws, "A12", "Run calculation", "RunAll"
    AddButton ws, "A14", "Run regression test", "RunRegressionTest"
    AddButton ws, "A16", "Clear outputs", "ClearOutputs"
End Sub

Private Sub BuildResults()
    Dim ws As Object
    Set ws = GetSheet(SH_RESULTS)
    ws.Cells(1, 1).Value = APP_NAME & " - Capital requirement summary"
    ws.Cells(2, 1).Value = "Amounts in reporting currency. SBM = max over correlation scenarios of the sum across risk classes (MAR21.7)."
    SetWidths ws, Array(30, 14, 16, 16, 16)
    On Error Resume Next
    ws.Cells(1, 1).Font.Bold = True
    ws.Cells(1, 1).Font.Size = 14
End Sub

'------------------------------------------------------------------------------
' Input and output headers
'------------------------------------------------------------------------------
Private Sub BuildInputHeaders()
    Dim ws As Object
    Set ws = GetSheet(SH_IN_DELTA)
    ws.Cells.Clear
    PutRow ws, 1, Array("ID", "RiskClass", "Bucket", "Qualifier", "SubType", "Tenor", "Sensitivity", "Comment")
    StyleHeader ws, 1, 8
    SetWidths ws, Array(10, 11, 9, 18, 11, 8, 16, 40)

    Set ws = GetSheet(SH_IN_VEGA)
    ws.Cells.Clear
    PutRow ws, 1, Array("ID", "RiskClass", "Bucket", "Qualifier", "SubType", "OptionMaturity", "UnderlyingMaturity", "Sensitivity", "Comment")
    StyleHeader ws, 1, 9
    SetWidths ws, Array(10, 11, 9, 18, 11, 15, 18, 16, 40)

    Set ws = GetSheet(SH_IN_CURV)
    ws.Cells.Clear
    PutRow ws, 1, Array("ID", "RiskClass", "Bucket", "Qualifier", "SubType", "CVR_Up", "CVR_Down", "Comment")
    StyleHeader ws, 1, 8
    SetWidths ws, Array(10, 11, 9, 18, 11, 14, 14, 40)

    Set ws = GetSheet(SH_IN_DRC)
    ws.Cells.Clear
    PutRow ws, 1, Array("ID", "Obligor", "Bucket", "CreditQuality", "Seniority", "Notional", "MarketValue", "Maturity", "LGD", "Comment")
    StyleHeader ws, 1, 10
    SetWidths ws, Array(10, 16, 9, 14, 13, 14, 14, 10, 8, 40)

    Set ws = GetSheet(SH_IN_RRAO)
    ws.Cells.Clear
    PutRow ws, 1, Array("ID", "Category", "GrossNotional", "Comment")
    StyleHeader ws, 1, 4
    SetWidths ws, Array(10, 11, 16, 50)
End Sub

Private Sub BuildOutputHeaders()
    Dim ws As Object
    Set ws = GetSheet(SH_LOG)
    PutRow ws, 1, Array("Level", "Source", "Message")
    SetWidths ws, Array(8, 22, 100)
    Set ws = GetSheet(SH_OUT_SUMMARY)
    PutRow ws, 1, Array("Item", "Value")
    SetWidths ws, Array(16, 18)
    Set ws = GetSheet(SH_OUT_CLASS)
    PutRow ws, 1, Array("RiskClass", "Component", "Scenario", "Capital", "Buckets", "AltSbUsed")
    SetWidths ws, Array(11, 12, 10, 16, 9, 10)
    Set ws = GetSheet(SH_OUT_BUCKETS)
    PutRow ws, 1, Array("RiskClass", "Component", "Scenario", "Bucket", "Kb", "Sb", "RiskFactors", "Note")
    SetWidths ws, Array(11, 12, 10, 8, 16, 16, 11, 14)
    Set ws = GetSheet(SH_OUT_DRC)
    PutRow ws, 1, Array("Obligor", "Bucket", "CreditQuality", "RW", "NetLong", "NetShort")
    SetWidths ws, Array(16, 8, 13, 8, 14, 14, 3, 3, 8, 14, 14, 8, 14, 14, 14)
End Sub

'------------------------------------------------------------------------------
' Parameters
'------------------------------------------------------------------------------
Private Sub WriteParameters()
    WriteParamGeneral
    WriteParamGirr
    WriteParamCsr
    WriteParamEquity
    WriteParamCommodity
    WriteParamFx
    WriteParamDrc
    WriteParamRrao
End Sub

Private Sub WriteParamGeneral()
    Dim ws As Object, r As Long
    Set ws = GetSheet(SH_P_GENERAL)
    ws.Cells.Clear
    r = PutTable(ws, 1, "CORR_SCENARIOS", Array("Key", "Value", "Reference"))
    PutRow ws, r, Array("HIGH_MULTIPLIER", 1.25, "MAR21.6(1): rho_high = min(1.25 x rho, 100%)")
    PutRow ws, r + 1, Array("LOW_MULTIPLIER", 0.75, "MAR21.6(3): rho_low = max(2 x rho - 100%, 75% x rho)")

    r = PutTable(ws, r + 3, "VEGA", Array("Key", "Value", "Reference"))
    PutRow ws, r, Array("RW_SIGMA", 0.55, "MAR21.92: RW = min(RW_sigma x sqrt(LH) / sqrt(10), 100%)")
    PutRow ws, r + 1, Array("ALPHA", 0.01, "MAR21.93: option maturity correlation parameter")

    r = PutTable(ws, r + 3, "VEGA_LH", Array("RiskClass", "Bucket", "LH", "Reference"))
    PutRow ws, r, Array("GIRR", "*", 60, "MAR21.92")
    PutRow ws, r + 1, Array("CSR_NS", "*", 120, "MAR21.92")
    PutRow ws, r + 2, Array("EQ", "*", 20, "MAR21.92 large cap (buckets 1-8, 12)")
    PutRow ws, r + 3, Array("EQ", 9, 60, "MAR21.92 small cap")
    PutRow ws, r + 4, Array("EQ", 10, 60, "MAR21.92 small cap")
    PutRow ws, r + 5, Array("EQ", 11, 60, "MAR21.92 other")
    PutRow ws, r + 6, Array("EQ", 13, 60, "MAR21.92 other indices")
    PutRow ws, r + 7, Array("COM", "*", 120, "MAR21.92")
    PutRow ws, r + 8, Array("FX", "*", 40, "MAR21.92")

    r = PutTable(ws, r + 10, "VERTICES", Array("Key", "Value", "Reference"))
    PutRow ws, r, Array("GIRR_TENORS", "0.25,0.5,1,2,3,5,10,15,20,30", "MAR21.8(1)")
    PutRow ws, r + 1, Array("CSR_TENORS", "0.5,1,3,5,10", "MAR21.8(2)")
    PutRow ws, r + 2, Array("COM_TENORS", "0,0.25,0.5,1,2,3,5,10,15,20,30", "MAR21.8(6)")
    PutRow ws, r + 3, Array("VEGA_MATURITIES", "0.5,1,3,5,10", "MAR21.9")
    SetWidths ws, Array(18, 30, 10, 60)
End Sub

Private Sub WriteParamGirr()
    Dim ws As Object, r As Long, i As Long, tenors As Variant, rws As Variant, ccys As Variant
    Set ws = GetSheet(SH_P_GIRR)
    ws.Cells.Clear
    tenors = Array(0.25, 0.5, 1, 2, 3, 5, 10, 15, 20, 30)
    rws = Array(0.017, 0.017, 0.016, 0.013, 0.012, 0.011, 0.011, 0.011, 0.011, 0.011)
    r = PutTable(ws, 1, "GIRR_RW", Array("Tenor", "RW"))
    For i = 0 To 9
        PutRow ws, r + i, Array(tenors(i), rws(i))
    Next i

    r = PutTable(ws, r + 11, "GIRR_PARAMS", Array("Key", "Value", "Reference"))
    PutRow ws, r, Array("THETA", 0.03, "MAR21.46")
    PutRow ws, r + 1, Array("RHO_FLOOR", 0.4, "MAR21.46")
    PutRow ws, r + 2, Array("RHO_DIFF_CURVE", 0.999, "MAR21.47-48")
    PutRow ws, r + 3, Array("RHO_INFLATION", 0.4, "MAR21.49")
    PutRow ws, r + 4, Array("RHO_XCCY", 0, "MAR21.50")
    PutRow ws, r + 5, Array("RW_INFLATION", 0.016, "MAR21.43")
    PutRow ws, r + 6, Array("RW_XCCY", 0.016, "MAR21.43")
    PutRow ws, r + 7, Array("GAMMA", 0.5, "MAR21.50")
    PutRow ws, r + 8, Array("SPECIFIED_DIVISOR", Sqr(2), "MAR21.44")

    ccys = Array("EUR", "USD", "GBP", "AUD", "JPY", "SEK", "CAD")
    r = PutTable(ws, r + 10, "GIRR_SPECIFIED_CCY", Array("Currency"))
    For i = 0 To UBound(ccys)
        ws.Cells(r + i, 1).Value = ccys(i)
    Next i
    SetWidths ws, Array(20, 12, 20)
End Sub

Private Sub WriteParamCsr()
    Dim ws As Object, r As Long, i As Long, j As Long, groups As Variant, m As Variant
    Set ws = GetSheet(SH_P_CSR)
    ws.Cells.Clear
    r = PutTable(ws, 1, "CSR_BUCKETS", Array("Bucket", "Description", "Quality", "SectorGroup", "Type", "RW"))
    PutRow ws, r, Array(1, "Sovereigns incl. central banks, MDBs", "IG", 1, "NAME", 0.005)
    PutRow ws, r + 1, Array(2, "Local government, government-backed non-financials, education, public administration", "IG", 2, "NAME", 0.01)
    PutRow ws, r + 2, Array(3, "Financials incl. government-backed financials", "IG", 3, "NAME", 0.05)
    PutRow ws, r + 3, Array(4, "Basic materials, energy, industrials, agriculture, manufacturing, mining", "IG", 4, "NAME", 0.03)
    PutRow ws, r + 4, Array(5, "Consumer goods and services, transportation and storage, administrative services", "IG", 5, "NAME", 0.03)
    PutRow ws, r + 5, Array(6, "Technology, telecommunications", "IG", 6, "NAME", 0.02)
    PutRow ws, r + 6, Array(7, "Health care, utilities, professional and technical activities", "IG", 7, "NAME", 0.015)
    PutRow ws, r + 7, Array(8, "Covered bonds", "IG", 8, "NAME", 0.025)
    PutRow ws, r + 8, Array(9, "Sovereigns incl. central banks, MDBs", "HY", 1, "NAME", 0.02)
    PutRow ws, r + 9, Array(10, "Local government, government-backed non-financials, education, public administration", "HY", 2, "NAME", 0.04)
    PutRow ws, r + 10, Array(11, "Financials incl. government-backed financials", "HY", 3, "NAME", 0.12)
    PutRow ws, r + 11, Array(12, "Basic materials, energy, industrials, agriculture, manufacturing, mining", "HY", 4, "NAME", 0.07)
    PutRow ws, r + 12, Array(13, "Consumer goods and services, transportation and storage, administrative services", "HY", 5, "NAME", 0.085)
    PutRow ws, r + 13, Array(14, "Technology, telecommunications", "HY", 6, "NAME", 0.055)
    PutRow ws, r + 14, Array(15, "Health care, utilities, professional and technical activities", "HY", 7, "NAME", 0.05)
    PutRow ws, r + 15, Array(16, "Other sector", "NA", "OTHER", "OTHER", 0.12)
    PutRow ws, r + 16, Array(17, "IG indices", "IG", 17, "INDEX", 0.015)
    PutRow ws, r + 17, Array(18, "HY indices", "HY", 18, "INDEX", 0.05)

    r = PutTable(ws, r + 19, "CSR_PARAMS", Array("Key", "Value", "Reference"))
    PutRow ws, r, Array("RHO_NAME", 0.35, "MAR21.54")
    PutRow ws, r + 1, Array("RHO_NAME_INDEX", 0.8, "MAR21.55 (buckets 17-18)")
    PutRow ws, r + 2, Array("RHO_TENOR", 0.65, "MAR21.54")
    PutRow ws, r + 3, Array("RHO_BASIS", 0.999, "MAR21.54")
    PutRow ws, r + 4, Array("GAMMA_RATING", 0.5, "MAR21.57")

    ' Sector component of the cross-bucket correlation (MAR21.57); symmetric
    groups = Array(1, 2, 3, 4, 5, 6, 7, 8, 17, 18)
    m = Array( _
        Array(1, 0.75, 0.1, 0.2, 0.25, 0.2, 0.15, 0.1, 0, 0.45), _
        Array(0.75, 1, 0.05, 0.15, 0.2, 0.15, 0.1, 0.1, 0, 0.45), _
        Array(0.1, 0.05, 1, 0.05, 0.15, 0.2, 0.05, 0.2, 0, 0.45), _
        Array(0.2, 0.15, 0.05, 1, 0.2, 0.25, 0.05, 0.05, 0, 0.45), _
        Array(0.25, 0.2, 0.15, 0.2, 1, 0.25, 0.05, 0.15, 0, 0.45), _
        Array(0.2, 0.15, 0.2, 0.25, 0.25, 1, 0.05, 0.2, 0, 0.45), _
        Array(0.15, 0.1, 0.05, 0.05, 0.05, 0.05, 1, 0.05, 0, 0.45), _
        Array(0.1, 0.1, 0.2, 0.05, 0.15, 0.2, 0.05, 1, 0, 0.45), _
        Array(0, 0, 0, 0, 0, 0, 0, 0, 1, 0.75), _
        Array(0.45, 0.45, 0.45, 0.45, 0.45, 0.45, 0.45, 0.45, 0.75, 1))
    r = PutTable(ws, r + 6, "CSR_GAMMA_SECTOR", Array("Group", 1, 2, 3, 4, 5, 6, 7, 8, 17, 18))
    For i = 0 To 9
        ws.Cells(r + i, 1).Value = groups(i)
        For j = 0 To 9
            ws.Cells(r + i, j + 2).Value = m(i)(j)
        Next j
    Next i
    SetWidths ws, Array(14, 70, 9, 12, 9, 9, 9, 9, 9, 9, 9)
End Sub

Private Sub WriteParamEquity()
    Dim ws As Object, r As Long, b As Long, c As Long, g As Double
    Set ws = GetSheet(SH_P_EQ)
    ws.Cells.Clear
    r = PutTable(ws, 1, "EQ_BUCKETS", Array("Bucket", "Description", "Type", "RW_SPOT", "RW_REPO", "RHO_NAME"))
    PutRow ws, r, Array(1, "Large cap, EM: consumer goods/services, transportation, admin, health care, utilities", "NAME", 0.55, 0.0055, 0.15)
    PutRow ws, r + 1, Array(2, "Large cap, EM: telecommunications, industrials", "NAME", 0.6, 0.006, 0.15)
    PutRow ws, r + 2, Array(3, "Large cap, EM: basic materials, energy, agriculture, manufacturing, mining", "NAME", 0.45, 0.0045, 0.15)
    PutRow ws, r + 3, Array(4, "Large cap, EM: financials, real estate, technology", "NAME", 0.55, 0.0055, 0.15)
    PutRow ws, r + 4, Array(5, "Large cap, AE: consumer goods/services, transportation, admin, health care, utilities", "NAME", 0.3, 0.003, 0.25)
    PutRow ws, r + 5, Array(6, "Large cap, AE: telecommunications, industrials", "NAME", 0.35, 0.0035, 0.25)
    PutRow ws, r + 6, Array(7, "Large cap, AE: basic materials, energy, agriculture, manufacturing, mining", "NAME", 0.4, 0.004, 0.25)
    PutRow ws, r + 7, Array(8, "Large cap, AE: financials, real estate, technology", "NAME", 0.5, 0.005, 0.25)
    PutRow ws, r + 8, Array(9, "Small cap, EM: all sectors", "NAME", 0.7, 0.007, 0.075)
    PutRow ws, r + 9, Array(10, "Small cap, AE: all sectors", "NAME", 0.5, 0.005, 0.125)
    PutRow ws, r + 10, Array(11, "Other sector", "OTHER", 0.7, 0.007, 0)
    PutRow ws, r + 11, Array(12, "Large cap, AE indices", "INDEX", 0.15, 0.0015, 0.8)
    PutRow ws, r + 12, Array(13, "Other indices", "INDEX", 0.25, 0.0025, 0.8)

    r = PutTable(ws, r + 14, "EQ_PARAMS", Array("Key", "Value", "Reference"))
    PutRow ws, r, Array("RHO_SPOT_REPO", 0.999, "MAR21.78")

    ' Cross-bucket correlations (MAR21.80)
    r = PutTable(ws, r + 2, "EQ_GAMMA", Array("Bucket", 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13))
    For b = 1 To 13
        ws.Cells(r + b - 1, 1).Value = b
        For c = 1 To 13
            If b = c Then
                g = 1
            ElseIf b = 11 Or c = 11 Then
                g = 0
            ElseIf b >= 12 And c >= 12 Then
                g = 0.75
            ElseIf b >= 12 Or c >= 12 Then
                g = 0.45
            Else
                g = 0.15
            End If
            ws.Cells(r + b - 1, c + 1).Value = g
        Next c
    Next b
    SetWidths ws, Array(14, 80, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9)
End Sub

Private Sub WriteParamCommodity()
    Dim ws As Object, r As Long, b As Long, c As Long, g As Double
    Set ws = GetSheet(SH_P_COM)
    ws.Cells.Clear
    r = PutTable(ws, 1, "COM_BUCKETS", Array("Bucket", "Description", "RW", "RHO_CTY"))
    PutRow ws, r, Array(1, "Energy - solid combustibles", 0.3, 0.55)
    PutRow ws, r + 1, Array(2, "Energy - liquid combustibles", 0.35, 0.95)
    PutRow ws, r + 2, Array(3, "Energy - electricity and carbon trading", 0.6, 0.4)
    PutRow ws, r + 3, Array(4, "Freight", 0.8, 0.8)
    PutRow ws, r + 4, Array(5, "Metals - non-precious", 0.4, 0.6)
    PutRow ws, r + 5, Array(6, "Gaseous combustibles", 0.45, 0.65)
    PutRow ws, r + 6, Array(7, "Precious metals (including gold)", 0.2, 0.55)
    PutRow ws, r + 7, Array(8, "Grains and oilseed", 0.35, 0.45)
    PutRow ws, r + 8, Array(9, "Livestock and dairy", 0.25, 0.15)
    PutRow ws, r + 9, Array(10, "Softs and other agriculturals", 0.35, 0.4)
    PutRow ws, r + 10, Array(11, "Other commodity", 0.5, 0.15)

    r = PutTable(ws, r + 12, "COM_PARAMS", Array("Key", "Value", "Reference"))
    PutRow ws, r, Array("RHO_TENOR", 0.99, "MAR21.83")
    PutRow ws, r + 1, Array("RHO_BASIS", 0.999, "MAR21.83")

    ' Cross-bucket correlations (MAR21.85)
    r = PutTable(ws, r + 3, "COM_GAMMA", Array("Bucket", 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11))
    For b = 1 To 11
        ws.Cells(r + b - 1, 1).Value = b
        For c = 1 To 11
            If b = c Then
                g = 1
            ElseIf b = 11 Or c = 11 Then
                g = 0
            Else
                g = 0.2
            End If
            ws.Cells(r + b - 1, c + 1).Value = g
        Next c
    Next b
    SetWidths ws, Array(14, 45, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9)
End Sub

Private Sub WriteParamFx()
    Dim ws As Object, r As Long, i As Long, pairs As Variant
    Set ws = GetSheet(SH_P_FX)
    ws.Cells.Clear
    r = PutTable(ws, 1, "FX_PARAMS", Array("Key", "Value", "Reference"))
    PutRow ws, r, Array("RW", 0.15, "MAR21.87")
    PutRow ws, r + 1, Array("GAMMA", 0.6, "MAR21.89")
    PutRow ws, r + 2, Array("SPECIFIED_DIVISOR", Sqr(2), "MAR21.88")
    PutRow ws, r + 3, Array("CURVATURE_DIVISOR", 1.5, "MAR21.98")

    pairs = Array("USD/EUR", "USD/JPY", "USD/GBP", "USD/AUD", "USD/CAD", "USD/CHF", "USD/MXN", "USD/CNY", _
                  "USD/NZD", "USD/RUB", "USD/HKD", "USD/SGD", "USD/TRY", "USD/KRW", "USD/SEK", "USD/ZAR", _
                  "USD/INR", "USD/NOK", "USD/BRL", "EUR/JPY", "EUR/GBP", "EUR/CHF", "JPY/AUD")
    r = PutTable(ws, r + 5, "FX_SPECIFIED_PAIRS", Array("Pair"))
    For i = 0 To UBound(pairs)
        ws.Cells(r + i, 1).Value = pairs(i)
    Next i
    SetWidths ws, Array(20, 12, 14)
End Sub

Private Sub WriteParamDrc()
    Dim ws As Object, r As Long
    Set ws = GetSheet(SH_P_DRC)
    ws.Cells.Clear
    r = PutTable(ws, 1, "DRC_RW", Array("CreditQuality", "RW"))
    PutRow ws, r, Array("AAA", 0.005)
    PutRow ws, r + 1, Array("AA", 0.02)
    PutRow ws, r + 2, Array("A", 0.03)
    PutRow ws, r + 3, Array("BBB", 0.06)
    PutRow ws, r + 4, Array("BB", 0.15)
    PutRow ws, r + 5, Array("B", 0.3)
    PutRow ws, r + 6, Array("CCC", 0.5)
    PutRow ws, r + 7, Array("UNRATED", 0.15)
    PutRow ws, r + 8, Array("DEFAULTED", 1)

    ' Rank: 1 = most junior. A short may offset a long of the same or a more senior rank.
    r = PutTable(ws, r + 10, "DRC_SENIORITY", Array("Seniority", "Rank", "LGD", "Reference"))
    PutRow ws, r, Array("EQUITY", 1, 1, "MAR22.13")
    PutRow ws, r + 1, Array("NON_SENIOR", 2, 1, "MAR22.13")
    PutRow ws, r + 2, Array("SENIOR", 3, 0.75, "MAR22.13")
    PutRow ws, r + 3, Array("COVERED", 4, 0.25, "MAR22.13")

    r = PutTable(ws, r + 5, "DRC_PARAMS", Array("Key", "Value", "Reference"))
    PutRow ws, r, Array("MIN_MATURITY", 0.25, "MAR22.17: floor of three months")
    PutRow ws, r + 1, Array("MAX_MATURITY", 1, "MAR22.17: one-year capital horizon")

    r = PutTable(ws, r + 3, "DRC_BUCKETS", Array("Bucket", "Description"))
    PutRow ws, r, Array("CORP", "Corporates")
    PutRow ws, r + 1, Array("SOV", "Sovereigns")
    PutRow ws, r + 2, Array("LGM", "Local governments and municipalities")
    SetWidths ws, Array(16, 10, 8, 40)
End Sub

Private Sub WriteParamRrao()
    Dim ws As Object, r As Long
    Set ws = GetSheet(SH_P_RRAO)
    ws.Cells.Clear
    r = PutTable(ws, 1, "RRAO_RW", Array("Category", "RW", "Reference"))
    PutRow ws, r, Array("EXOTIC", 0.01, "MAR23.8(1): exotic underlying")
    PutRow ws, r + 1, Array("OTHER", 0.001, "MAR23.8(2): other residual risks")
    SetWidths ws, Array(12, 8, 40)
End Sub

'------------------------------------------------------------------------------
' Synthetic sample portfolio (amounts in reporting currency)
'------------------------------------------------------------------------------
Private Sub WriteSampleData()
    WriteSampleDelta
    WriteSampleVega
    WriteSampleCurvature
    WriteSampleDrc
    WriteSampleRrao
End Sub

Private Sub WriteSampleDelta()
    Dim ws As Object
    Set ws = GetSheet(SH_IN_DELTA)
    PutRow ws, 2, Array("D001", "GIRR", "EUR", "ESTR", "YIELD", 1, 5000000, "Swap book")
    PutRow ws, 3, Array("D002", "GIRR", "EUR", "ESTR", "YIELD", 5, -12000000, "Swap book")
    PutRow ws, 4, Array("D003", "GIRR", "EUR", "ESTR", "YIELD", 10, 8000000, "Swap book")
    PutRow ws, 5, Array("D004", "GIRR", "EUR", "EURIBOR6M", "YIELD", 5, 3000000, "Basis swaps")
    PutRow ws, 6, Array("D005", "GIRR", "EUR", "EURIBOR6M", "YIELD", 10, -1500000, "Basis swaps")
    PutRow ws, 7, Array("D006", "GIRR", "EUR", "HICP", "INFLATION", "", 400000, "Inflation swaps")
    PutRow ws, 8, Array("D007", "GIRR", "USD", "SOFR", "YIELD", 2, -4000000, "UST hedge")
    PutRow ws, 9, Array("D008", "GIRR", "USD", "SOFR", "YIELD", 10, 2000000, "UST hedge")
    PutRow ws, 10, Array("D009", "GIRR", "USD", "SOFR", "YIELD", 10, 500000, "Netted with D008")
    PutRow ws, 11, Array("D010", "GIRR", "USD", "USD-EUR", "XCCY", "", 1000000, "Cross-currency swaps")
    PutRow ws, 12, Array("D011", "CSR_NS", 1, "ITALY", "BOND", 5, 3000000, "BTP")
    PutRow ws, 13, Array("D012", "CSR_NS", 1, "SPAIN", "BOND", 5, 3000000, "Bono")
    PutRow ws, 14, Array("D013", "CSR_NS", 1, "ITALY", "CDS", 5, 500000, "Sovereign CDS protection sold")
    PutRow ws, 15, Array("D014", "CSR_NS", 2, "REGION_X", "BOND", 3, -2000000, "Regional bond short")
    PutRow ws, 16, Array("D015", "CSR_NS", 2, "REGION_Y", "BOND", 5, -1800000, "Regional bond short")
    PutRow ws, 17, Array("D016", "CSR_NS", 3, "BANK_A", "BOND", 3, 1500000, "Senior bond")
    PutRow ws, 18, Array("D017", "CSR_NS", 3, "BANK_A", "CDS", 3, -1400000, "CDS hedge")
    PutRow ws, 19, Array("D018", "CSR_NS", 11, "BANK_Z", "BOND", 1, 100000, "HY financial")
    PutRow ws, 20, Array("D019", "CSR_NS", 16, "MISC_CO", "BOND", 5, 200000, "Other sector")
    PutRow ws, 21, Array("D020", "CSR_NS", 16, "MISC_CO2", "BOND", 5, -150000, "Other sector")
    PutRow ws, 22, Array("D021", "CSR_NS", 17, "ITRAXX_MAIN", "CDS", 5, -800000, "Index protection")
    PutRow ws, 23, Array("D022", "EQ", 8, "BANK_A", "SPOT", "", 2000000, "Shares")
    PutRow ws, 24, Array("D023", "EQ", 8, "BANK_B", "SPOT", "", -1200000, "Short shares")
    PutRow ws, 25, Array("D024", "EQ", 8, "BANK_A", "REPO", "", 50000, "Securities lending")
    PutRow ws, 26, Array("D025", "EQ", 5, "CONSUMER_X", "SPOT", "", 900000, "Shares")
    PutRow ws, 27, Array("D026", "EQ", 12, "EUROSTOXX50", "SPOT", "", -1500000, "Index future short")
    PutRow ws, 28, Array("D027", "EQ", 11, "OTHER_EQ", "SPOT", "", 100000, "Other sector")
    PutRow ws, 29, Array("D028", "COM", 2, "BRENT", "ROTTERDAM", 0.5, 800000, "Futures")
    PutRow ws, 30, Array("D029", "COM", 2, "BRENT", "ROTTERDAM", 1, -500000, "Futures")
    PutRow ws, 31, Array("D030", "COM", 2, "WTI", "CUSHING", 1, 300000, "Futures")
    PutRow ws, 32, Array("D031", "COM", 7, "GOLD", "LONDON", 0, 1000000, "Spot gold")
    PutRow ws, 33, Array("D032", "COM", 3, "POWER_DE", "EEX", 0.25, 200000, "Power forward")
    PutRow ws, 34, Array("D033", "FX", "USD", "USD", "", "", 3000000, "USD exposure")
    PutRow ws, 35, Array("D034", "FX", "GBP", "GBP", "", "", -1500000, "GBP exposure")
    PutRow ws, 36, Array("D035", "FX", "JPY", "JPY", "", "", 800000, "JPY exposure")
    PutRow ws, 37, Array("D036", "FX", "CHF", "CHF", "", "", -400000, "CHF exposure")
End Sub

Private Sub WriteSampleVega()
    Dim ws As Object
    Set ws = GetSheet(SH_IN_VEGA)
    PutRow ws, 2, Array("V001", "GIRR", "EUR", "", "", 1, 5, 400000, "Swaptions")
    PutRow ws, 3, Array("V002", "GIRR", "EUR", "", "", 5, 10, -250000, "Swaptions")
    PutRow ws, 4, Array("V003", "GIRR", "USD", "", "", 3, 10, 200000, "Swaptions")
    PutRow ws, 5, Array("V004", "CSR_NS", 1, "ITALY", "BOND", 1, "", 60000, "Bond options")
    PutRow ws, 6, Array("V005", "EQ", 8, "BANK_A", "", 0.5, "", 300000, "Single-stock options")
    PutRow ws, 7, Array("V006", "EQ", 8, "BANK_A", "", 1, "", -100000, "Single-stock options")
    PutRow ws, 8, Array("V007", "EQ", 12, "EUROSTOXX50", "", 1, "", -500000, "Index options")
    PutRow ws, 9, Array("V008", "COM", 2, "BRENT", "ROTTERDAM", 1, "", 120000, "Oil options")
    PutRow ws, 10, Array("V009", "FX", "USD", "USD", "", 1, "", 150000, "FX options")
    PutRow ws, 11, Array("V010", "FX", "GBP", "GBP", "", 0.5, "", -80000, "FX options")
End Sub

Private Sub WriteSampleCurvature()
    Dim ws As Object
    Set ws = GetSheet(SH_IN_CURV)
    PutRow ws, 2, Array("C001", "GIRR", "EUR", "", "", -50000, 30000, "Swaptions")
    PutRow ws, 3, Array("C002", "GIRR", "USD", "", "", 10000, -20000, "Swaptions")
    PutRow ws, 4, Array("C003", "CSR_NS", 1, "ITALY", "BOND", -15000, 5000, "Bond options")
    PutRow ws, 5, Array("C004", "EQ", 8, "BANK_A", "", -80000, 40000, "Single-stock options")
    PutRow ws, 6, Array("C005", "EQ", 8, "BANK_B", "", 20000, -60000, "Single-stock options")
    PutRow ws, 7, Array("C006", "EQ", 12, "EUROSTOXX50", "", 30000, -10000, "Index options")
    PutRow ws, 8, Array("C007", "COM", 2, "BRENT", "ROTTERDAM", -25000, 10000, "Oil options")
    PutRow ws, 9, Array("C008", "FX", "USD", "USD", "", -40000, -35000, "FX options")
    PutRow ws, 10, Array("C009", "FX", "GBP", "GBP", "", 15000, 12000, "FX options")
End Sub

Private Sub WriteSampleDrc()
    Dim ws As Object
    Set ws = GetSheet(SH_IN_DRC)
    PutRow ws, 2, Array("J001", "ITALY", "SOV", "BBB", "SENIOR", 10000000, 9800000, 5, "", "BTP long")
    PutRow ws, 3, Array("J002", "GERMANY", "SOV", "AAA", "SENIOR", -5000000, -5100000, 10, "", "Bund short")
    PutRow ws, 4, Array("J003", "BANK_A", "CORP", "A", "SENIOR", 4000000, 4050000, 3, "", "Senior bond")
    PutRow ws, 5, Array("J004", "BANK_A", "CORP", "A", "EQUITY", 2000000, 2000000, 1, "", "Shares")
    PutRow ws, 6, Array("J005", "BANK_A", "CORP", "A", "SENIOR", -3000000, -3020000, 0.5, "", "Short senior bond")
    PutRow ws, 7, Array("J006", "BANK_B", "CORP", "BBB", "NON_SENIOR", -1500000, -1450000, 2, "", "Short subordinated")
    PutRow ws, 8, Array("J007", "CONSUMER_X", "CORP", "BB", "SENIOR", 1000000, 950000, 0.1, "", "Short-dated bond")
    PutRow ws, 9, Array("J008", "REGION_X", "LGM", "AA", "SENIOR", 2000000, 2010000, 4, "", "Regional bond")
    PutRow ws, 10, Array("J009", "MISC_CO", "CORP", "UNRATED", "SENIOR", 500000, 480000, 2, "", "Unrated bond")
    PutRow ws, 11, Array("J010", "BANK_Z", "CORP", "CCC", "COVERED", 800000, 700000, 1.5, "", "Covered bond")
End Sub

Private Sub WriteSampleRrao()
    Dim ws As Object
    Set ws = GetSheet(SH_IN_RRAO)
    PutRow ws, 2, Array("R001", "EXOTIC", 5000000, "Weather derivative")
    PutRow ws, 3, Array("R002", "OTHER", 20000000, "Correlation basket option")
    PutRow ws, 4, Array("R003", "OTHER", 7500000, "Behavioral prepayment option")
End Sub

'------------------------------------------------------------------------------
' Expected results of the sample portfolio for the regression test.
' Values come from the independent reference implementation under tests/.
'------------------------------------------------------------------------------
Private Sub WriteExpectedResults()
    Dim ws As Object, r As Long
    Set ws = GetSheet(SH_TEST)
    ws.Cells.Clear
    ws.Cells(1, 1).Value = "Expected results for the sample portfolio (default parameters and settings)."
    r = PutTable(ws, 3, "EXPECTED", Array("Item", "Expected", "Actual", "AbsDiff", "Status"))
    WriteExpectedRows ws, r
    SetWidths ws, Array(28, 18, 18, 12, 8)
End Sub

Private Sub WriteExpectedRows(ByVal ws As Object, ByVal r As Long)
    ' BEGIN GENERATED EXPECTED VALUES
    PutRow ws, r + 0, Array("SBM_LOW", 3165829.401811)
    PutRow ws, r + 1, Array("SBM_MEDIUM", 3045916.244041)
    PutRow ws, r + 2, Array("SBM_HIGH", 2937122.155251)
    PutRow ws, r + 3, Array("SBM", 3165829.401811)
    PutRow ws, r + 4, Array("DRC_NONSEC", 636589.396433)
    PutRow ws, r + 5, Array("RRAO", 77500)
    PutRow ws, r + 6, Array("TOTAL", 3879918.798243)
    PutRow ws, r + 7, Array("GIRR|DELTA|LOW", 60423.50359)
    PutRow ws, r + 8, Array("GIRR|DELTA|MEDIUM", 56980.229937)
    PutRow ws, r + 9, Array("GIRR|DELTA|HIGH", 53315.039354)
    PutRow ws, r + 10, Array("GIRR|VEGA|LOW", 323277.327073)
    PutRow ws, r + 11, Array("GIRR|VEGA|MEDIUM", 319771.9736)
    PutRow ws, r + 12, Array("GIRR|VEGA|HIGH", 316227.766017)
    PutRow ws, r + 13, Array("GIRR|CURVATURE|LOW", 33354.16016)
    PutRow ws, r + 14, Array("GIRR|CURVATURE|MEDIUM", 33911.649916)
    PutRow ws, r + 15, Array("GIRR|CURVATURE|HIGH", 34460.12188)
    PutRow ws, r + 16, Array("CSR_NS|DELTA|LOW", 64970.476976)
    PutRow ws, r + 17, Array("CSR_NS|DELTA|MEDIUM", 54782.752051)
    PutRow ws, r + 18, Array("CSR_NS|DELTA|HIGH", 65138.541154)
    PutRow ws, r + 19, Array("CSR_NS|VEGA|LOW", 60000)
    PutRow ws, r + 20, Array("CSR_NS|VEGA|MEDIUM", 60000)
    PutRow ws, r + 21, Array("CSR_NS|VEGA|HIGH", 60000)
    PutRow ws, r + 22, Array("CSR_NS|CURVATURE|LOW", 5000)
    PutRow ws, r + 23, Array("CSR_NS|CURVATURE|MEDIUM", 5000)
    PutRow ws, r + 24, Array("CSR_NS|CURVATURE|HIGH", 5000)
    PutRow ws, r + 25, Array("EQ|DELTA|LOW", 1156963.1261)
    PutRow ws, r + 26, Array("EQ|DELTA|MEDIUM", 1109540.409267)
    PutRow ws, r + 27, Array("EQ|DELTA|HIGH", 1059848.3154)
    PutRow ws, r + 28, Array("EQ|VEGA|LOW", 367878.895929)
    PutRow ws, r + 29, Array("EQ|VEGA|MEDIUM", 348369.331364)
    PutRow ws, r + 30, Array("EQ|VEGA|HIGH", 327700.320415)
    PutRow ws, r + 31, Array("EQ|CURVATURE|LOW", 45746.584572)
    PutRow ws, r + 32, Array("EQ|CURVATURE|MEDIUM", 44237.992721)
    PutRow ws, r + 33, Array("EQ|CURVATURE|HIGH", 42676.105727)
    PutRow ws, r + 34, Array("COM|DELTA|LOW", 352784.668318)
    PutRow ws, r + 35, Array("COM|DELTA|MEDIUM", 366440.324064)
    PutRow ws, r + 36, Array("COM|DELTA|HIGH", 379605.057922)
    PutRow ws, r + 37, Array("COM|VEGA|LOW", 120000)
    PutRow ws, r + 38, Array("COM|VEGA|MEDIUM", 120000)
    PutRow ws, r + 39, Array("COM|VEGA|HIGH", 120000)
    PutRow ws, r + 40, Array("COM|CURVATURE|LOW", 10000)
    PutRow ws, r + 41, Array("COM|CURVATURE|MEDIUM", 10000)
    PutRow ws, r + 42, Array("COM|CURVATURE|HIGH", 10000)
    PutRow ws, r + 43, Array("FX|DELTA|LOW", 430894.418622)
    PutRow ws, r + 44, Array("FX|DELTA|MEDIUM", 396465.635333)
    PutRow ws, r + 45, Array("FX|DELTA|HIGH", 358747.822293)
    PutRow ws, r + 46, Array("FX|VEGA|LOW", 134536.240471)
    PutRow ws, r + 47, Array("FX|VEGA|MEDIUM", 120415.945788)
    PutRow ws, r + 48, Array("FX|VEGA|HIGH", 104403.065089)
    PutRow ws, r + 49, Array("FX|CURVATURE|LOW", 0)
    PutRow ws, r + 50, Array("FX|CURVATURE|MEDIUM", 0)
    PutRow ws, r + 51, Array("FX|CURVATURE|HIGH", 0)
    ' END GENERATED EXPECTED VALUES
End Sub
