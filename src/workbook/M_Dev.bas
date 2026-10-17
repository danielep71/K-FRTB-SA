Attribute VB_Name = "M_Dev"
'==============================================================================
' MODULE: M_Dev
'------------------------------------------------------------------------------
' PURPOSE
'   Export the standard modules of this workbook back to the repository so
'   that changes made in the VBA editor can be reviewed and committed as
'   text: CORE_* to src/core, TEST_* to tests/modules, the others to
'   src/workbook.
'
' PUBLIC SURFACE
'   Dev_ExportModules.
'
' DEPENDENCIES
'   CORE_Config for APP_NAME. Needs "Trust access to the VBA project
'   object model".
'
' STATE OWNERSHIP
'   Writes .bas files; changes nothing in the workbook.
'
' ERROR POLICY
'   Shows a message and exits when the repository folders are not found
'   next to or above the workbook.
'
' COMPATIBILITY
'   Excel for Windows only (VBIDE object model, late bound).
'
' UPDATED  2026-10-17
'==============================================================================

'------------------------------------------------------------------------------
'                              MODULE SETTINGS
'------------------------------------------------------------------------------
Option Explicit

'------------------------------------------------------------------------------
'                              MODULE CONSTANTS
'------------------------------------------------------------------------------
Private Const VBEXT_STD_MODULE As Long = 1                   'vbext_ct_StdModule

'------------------------------------------------------------------------------
'                              PUBLIC MACROS
'------------------------------------------------------------------------------
Public Sub Dev_ExportModules()
    Dim root As String, sep As String, comp As Object, n As Long, target As String
    sep = Application.PathSeparator
    ' The build script saves the workbook in dist/, one level below the root
    root = ThisWorkbook.Path
    If Dir(root & sep & "src" & sep & "core", vbDirectory) = "" Then root = root & sep & ".."
    If Dir(root & sep & "src" & sep & "core", vbDirectory) = "" Then
        MsgBox "Folder src\core not found next to or above " & ThisWorkbook.Path, vbExclamation, APP_NAME
        Exit Sub
    End If
    n = 0
    For Each comp In ThisWorkbook.VBProject.VBComponents
        If comp.Type = VBEXT_STD_MODULE Then
            If Left$(comp.Name, 5) = "CORE_" Then
                target = root & sep & "src" & sep & "core"
            ElseIf Left$(comp.Name, 5) = "TEST_" Then
                target = root & sep & "tests" & sep & "modules"
            Else
                target = root & sep & "src" & sep & "workbook"
            End If
            comp.Export target & sep & comp.Name & ".bas"
            n = n + 1
        End If
    Next comp
    MsgBox n & " module(s) exported under " & root, vbInformation, APP_NAME
End Sub
