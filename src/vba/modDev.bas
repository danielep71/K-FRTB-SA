Attribute VB_Name = "modDev"
'==============================================================================
' modDev
' Developer utility for Excel: exports every standard module of this workbook
' to a folder so that changes made in the VBA editor can be committed as
' text under src/vba. Requires "Trust access to the VBA project object model".
'==============================================================================
Option Explicit

Private Const VBEXT_STD_MODULE As Long = 1

Public Sub Dev_ExportModules()
    Dim folder As String, comp As Object, n As Long
    Dim sep As String
    sep = Application.PathSeparator
    ' The build script saves the workbook in dist/, one level below the root
    folder = ThisWorkbook.Path & sep & "src" & sep & "vba"
    If Dir(folder, vbDirectory) = "" Then folder = ThisWorkbook.Path & sep & ".." & sep & "src" & sep & "vba"
    If Dir(folder, vbDirectory) = "" Then
        MsgBox "Folder src\vba not found next to or above " & ThisWorkbook.Path, vbExclamation, APP_NAME
        Exit Sub
    End If
    n = 0
    For Each comp In ThisWorkbook.VBProject.VBComponents
        If comp.Type = VBEXT_STD_MODULE Then
            comp.Export folder & Application.PathSeparator & comp.Name & ".bas"
            n = n + 1
        End If
    Next comp
    MsgBox n & " module(s) exported to " & folder, vbInformation, APP_NAME
End Sub
