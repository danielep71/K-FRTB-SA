Attribute VB_Name = "modMain"
'==============================================================================
' modMain
' Calculation entry points and the Results / Out_Summary reports.
'   RunAll        - interactive run (message box at the end)
'   RunAllSilent  - same calculation without any dialog (automation, tests)
'   ClearOutputs  - empties every output sheet and the log
'==============================================================================
Option Explicit

Private mLastStatus As String

Public Sub RunAll()
    Dim ok As Boolean
    ok = ExecuteRun()
    If ok Then
        MsgBox "Calculation complete." & vbCrLf & _
               "Total capital: " & Format(OutSummaryValue("TOTAL"), "#,##0") & vbCrLf & _
               "Errors: " & LogErrorCount() & "   Warnings: " & LogWarningCount() & vbCrLf & _
               "See the Results and Log sheets.", vbInformation, APP_NAME
    Else
        MsgBox "Calculation failed: " & mLastStatus, vbCritical, APP_NAME
    End If
End Sub

Public Sub RunAllSilent()
    ExecuteRun
End Sub

Public Function LastRunStatus() As String
    LastRunStatus = mLastStatus
End Function

Private Function ExecuteRun() As Boolean
    On Error GoTo Failed
    SetScreenUpdating False
    ResetLog
    LogMessage "INFO", "RunAll", APP_NAME & " " & APP_VERSION & " started"
    LoadAllParameters
    RunSBM
    RunDRC
    RunRRAO
    WriteSummary
    LogMessage "INFO", "RunAll", "Finished with " & LogErrorCount() & " error(s) and " & LogWarningCount() & " warning(s)"
    mLastStatus = "OK"
    SetScreenUpdating True
    ExecuteRun = True
    Exit Function
Failed:
    mLastStatus = "Error " & Err.Number & ": " & Err.Description
    On Error Resume Next
    LogMessage "ERROR", "RunAll", mLastStatus
    SetScreenUpdating True
    ExecuteRun = False
End Function

Public Sub ClearOutputs()
    Dim names As Variant, i As Long
    names = Array(SH_OUT_CLASS, SH_OUT_BUCKETS, SH_OUT_DRC, SH_OUT_SUMMARY, SH_LOG)
    For i = LBound(names) To UBound(names)
        If SheetExists(CStr(names(i))) Then GetSheet(CStr(names(i))).Cells.Clear
    Next i
    If SheetExists(SH_RESULTS) Then GetSheet(SH_RESULTS).Range("A4:F40").ClearContents
End Sub

Private Sub SetScreenUpdating(ByVal enabled As Boolean)
    On Error Resume Next
    Application.ScreenUpdating = enabled
End Sub

'------------------------------------------------------------------------------
' Reports
'------------------------------------------------------------------------------
Private Sub WriteSummary()
    Dim ws As Object, wsR As Object, s As Long, best As Long, i As Long, c As Long, r As Long
    Dim sbm As Double, drc As Double, rrao As Double

    best = SCEN_LOW
    For s = SCEN_LOW To SCEN_HIGH
        If SbmScenarioTotal(s) > SbmScenarioTotal(best) Then best = s
    Next s
    sbm = SbmScenarioTotal(best)
    drc = DrcTotal()
    rrao = RraoTotal()

    Set ws = GetSheet(SH_OUT_SUMMARY)
    ws.Cells.Clear
    ws.Range("A1:B1").Value = Array("Item", "Value")
    ws.Range("A2:B2").Value = Array("SBM_LOW", SbmScenarioTotal(SCEN_LOW))
    ws.Range("A3:B3").Value = Array("SBM_MEDIUM", SbmScenarioTotal(SCEN_MEDIUM))
    ws.Range("A4:B4").Value = Array("SBM_HIGH", SbmScenarioTotal(SCEN_HIGH))
    ws.Range("A5:B5").Value = Array("SBM_SCENARIO", ScenarioName(best))
    ws.Range("A6:B6").Value = Array("SBM", sbm)
    ws.Range("A7:B7").Value = Array("DRC_NONSEC", drc)
    ws.Range("A8:B8").Value = Array("RRAO", rrao)
    ws.Range("A9:B9").Value = Array("TOTAL", sbm + drc + rrao)
    ws.Range("A10:B10").Value = Array("ERRORS", LogErrorCount())
    ws.Range("A11:B11").Value = Array("WARNINGS", LogWarningCount())

    ' Formatted view
    Set wsR = GetSheet(SH_RESULTS)
    wsR.Range("A4:F40").ClearContents
    wsR.Range("A4:E4").Value = Array("Risk class", "Component", "Low", "Medium", "High")
    r = 4
    For i = 1 To RC_COUNT
        For c = 1 To COMP_COUNT
            r = r + 1
            wsR.Cells(r, 1).Value = RiskClassCode(i)
            wsR.Cells(r, 2).Value = ComponentName(c)
            For s = SCEN_LOW To SCEN_HIGH
                wsR.Cells(r, 2 + s).Value = SbmCapital(i, c, s)
            Next s
        Next c
    Next i
    r = r + 1
    wsR.Cells(r, 1).Value = "SBM total"
    For s = SCEN_LOW To SCEN_HIGH
        wsR.Cells(r, 2 + s).Value = SbmScenarioTotal(s)
    Next s
    r = r + 2
    wsR.Cells(r, 1).Value = "Binding correlation scenario"
    wsR.Cells(r, 3).Value = ScenarioName(best)
    wsR.Cells(r + 1, 1).Value = "SBM capital"
    wsR.Cells(r + 1, 3).Value = sbm
    wsR.Cells(r + 2, 1).Value = "DRC (non-securitization)"
    wsR.Cells(r + 2, 3).Value = drc
    wsR.Cells(r + 3, 1).Value = "Residual risk add-on"
    wsR.Cells(r + 3, 3).Value = rrao
    wsR.Cells(r + 4, 1).Value = "Total capital requirement"
    wsR.Cells(r + 4, 3).Value = sbm + drc + rrao
    wsR.Cells(r + 6, 1).Value = "Last run"
    wsR.Cells(r + 6, 3).Value = Now
    wsR.Cells(r + 7, 1).Value = "Errors / warnings"
    wsR.Cells(r + 7, 3).Value = LogErrorCount() & " / " & LogWarningCount()

    On Error Resume Next
    wsR.Range(wsR.Cells(5, 3), wsR.Cells(r + 4, 5)).NumberFormat = "#,##0"
    wsR.Cells(r + 6, 3).NumberFormat = "yyyy-mm-dd hh:mm:ss"
    wsR.Range(wsR.Cells(r - 2, 1), wsR.Cells(r - 2, 5)).Font.Bold = True
    wsR.Range(wsR.Cells(r + 4, 1), wsR.Cells(r + 4, 3)).Font.Bold = True
End Sub

Public Function OutSummaryValue(ByVal item As String) As Variant
    Dim ws As Object, r As Long
    Set ws = GetSheet(SH_OUT_SUMMARY)
    OutSummaryValue = Empty
    r = 2
    Do While Not IsBlank(ws.Cells(r, 1).Value)
        If UCase$(CStr(ws.Cells(r, 1).Value)) = UCase$(item) Then
            OutSummaryValue = ws.Cells(r, 2).Value
            Exit Function
        End If
        r = r + 1
    Loop
End Function
