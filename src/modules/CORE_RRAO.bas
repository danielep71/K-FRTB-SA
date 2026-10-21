Attribute VB_Name = "CORE_RRAO"
'==============================================================================
' MODULE: CORE_RRAO
'------------------------------------------------------------------------------
' PURPOSE
'   Calculate the residual risk add-on: gross notional times the risk
'   weight of the residual risk category (exotic or other).
'
' PUBLIC SURFACE
'   RunRRAO; RraoTotal.
'
' DEPENDENCIES
'   CORE_Config, CORE_Util, CORE_Params (parameters must be loaded).
'
' STATE OWNERSHIP
'   Owns the total of the last run. Reads In_RRAO and logs rejected rows.
'
' ERROR POLICY
'   Invalid rows are logged as ERROR and skipped.
'
' REFERENCE
'   Basel Framework MAR23.8.
'
' COMPATIBILITY
'   Excel VBA; also runs in LibreOffice Calc with VBA support for the
'   automated tests. No references beyond the defaults.
'==============================================================================

'------------------------------------------------------------------------------
'                              MODULE SETTINGS
'------------------------------------------------------------------------------
Option Explicit
Option Private Module

'------------------------------------------------------------------------------
'                               MODULE STATE
'------------------------------------------------------------------------------
Private mTotal As Double                                     'RRAO of the last run

Public Function RraoTotal() As Double
    RraoTotal = mTotal
End Function

Public Sub RunRRAO()
    Dim ws As Object, r As Long, src As String, category As String
    Dim rw As Double, found As Boolean
    mTotal = 0#
    Set ws = GetSheet(SH_IN_RRAO)
    r = LAYOUT_FIRST_DATA_ROW
    Do While Not (IsBlank(TableCell(ws, r, 1).Value) And IsBlank(TableCell(ws, r, 2).Value))
        src = SH_IN_RRAO & " row " & r
        category = ToText(TableCell(ws, r, 2).Value)
        rw = RraoRiskWeight(category, found)
        If Not found Then
            LogMessage "ERROR", src, "Unknown RRAO category '" & category & "'; row skipped"
        ElseIf Not IsNumber(TableCell(ws, r, 3).Value) Then
            LogMessage "ERROR", src, "Gross notional is not numeric; row skipped"
        ElseIf ToDouble(TableCell(ws, r, 3).Value, 0#) < 0# Then
            LogMessage "ERROR", src, "Gross notional must be non-negative; row skipped"
        Else
            mTotal = mTotal + rw * ToDouble(TableCell(ws, r, 3).Value, 0#)
        End If
        r = r + 1
    Loop
End Sub
