<#
.SYNOPSIS
    Builds the FRTB-SA prototype workbook (.xlsm) from the VBA sources.

.DESCRIPTION
    Starts Excel through COM, creates a new workbook, imports the modules of
    src\core, src\workbook and (unless -Production) tests\modules, runs
    M_Setup.BuildWorkbook to create the sheets, parameters and sample data,
    and saves the result as a macro-enabled workbook. With -RunTests it also
    runs the calculation and the in-workbook regression test and fails when
    the test does not pass.

    Requirements: Windows with desktop Excel, and "Trust access to the VBA
    project object model" enabled (File > Options > Trust Center > Trust
    Center Settings > Macro Settings).

.PARAMETER OutputPath
    Target .xlsm path. Defaults to dist\K-FRTB-SA.xlsm under the
    repository root.

.PARAMETER RunTests
    Run RunFRTB_Silent and Test_RunRegression_Silent after the build and check
    the result on the Test_Expected sheet.

.PARAMETER Template
    Save the built workbook as a macro-free template instead, by default
    dist\FRTB_Template.xlsx, with personal information removed. Review it
    before copying it to the reserved path src\workbook\FRTB_Template.xlsx.
    Cannot be combined with -RunTests.

.PARAMETER Production
    Leave out the test modules of tests\modules (the "Run regression test"
    button then has no macro). Cannot be combined with -RunTests.

.PARAMETER Force
    Overwrite an existing output file.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File tools\Build-Workbook.ps1 -RunTests
#>
[CmdletBinding()]
param(
    [string]$OutputPath,
    [switch]$RunTests,
    [switch]$Production,
    [switch]$Template,
    [switch]$Force
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceDirs = @((Join-Path $repoRoot 'src\core'), (Join-Path $repoRoot 'src\workbook'))
if (-not $Production) {
    $sourceDirs += (Join-Path $repoRoot 'tests\modules')
}
if ($Production -and $RunTests) {
    throw '-RunTests needs the test modules; do not combine it with -Production'
}
if ($Template -and $RunTests) {
    throw '-Template saves the workbook before any run; do not combine it with -RunTests'
}
if (-not $OutputPath) {
    if ($Template) {
        $OutputPath = Join-Path $repoRoot 'dist\FRTB_Template.xlsx'
    } else {
        $OutputPath = Join-Path $repoRoot 'dist\K-FRTB-SA.xlsm'
    }
}
$OutputPath = [System.IO.Path]::GetFullPath($OutputPath)

if ((Test-Path $OutputPath) -and -not $Force) {
    throw "Output exists: $OutputPath (use -Force to overwrite)"
}
$modules = @(foreach ($dir in $sourceDirs) { Get-ChildItem -Path $dir -Filter '*.bas' | Sort-Object Name })
if ($modules.Count -eq 0) {
    throw "No .bas modules found in $($sourceDirs -join ', ')"
}
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $OutputPath) | Out-Null

# The VBA editor expects CRLF line endings; normalize into a temporary folder
$staging = Join-Path ([System.IO.Path]::GetTempPath()) ("frtb-sa-build-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $staging | Out-Null
$encoding = [System.Text.Encoding]::GetEncoding(1252)
foreach ($m in $modules) {
    $text = [System.IO.File]::ReadAllText($m.FullName, $encoding)
    $text = ($text -replace "`r`n", "`n") -replace "`n", "`r`n"
    [System.IO.File]::WriteAllText((Join-Path $staging $m.Name), $text, $encoding)
}

$excel = $null
$workbook = $null
$exitCode = 0
try {
    $excel = New-Object -ComObject Excel.Application
    $excel.Visible = $false
    $excel.DisplayAlerts = $false
    $workbook = $excel.Workbooks.Add()

    try {
        $components = $workbook.VBProject.VBComponents
    } catch {
        throw "Excel denied access to the VBA project. Enable 'Trust access to the VBA project object model' and retry."
    }
    foreach ($m in $modules) {
        [void]$components.Import((Join-Path $staging $m.Name))
        Write-Host "Imported $($m.Name)"
    }

    $prefix = "'" + $workbook.Name + "'!"
    [void]$excel.Run($prefix + 'BuildWorkbook')
    Write-Host 'Workbook layout, parameters and sample data created'

    if ($RunTests) {
        [void]$excel.Run($prefix + 'RunFRTB_Silent')
        [void]$excel.Run($prefix + 'Test_RunRegression_Silent')
        $result = [string]$workbook.Worksheets.Item('Test_Expected').Range('C3').Value2
        Write-Host "Regression test: $result"
        if (-not $result.StartsWith('Result: PASS')) {
            $exitCode = 1
        }
    }

    if ($Template) {
        # 51 = xlOpenXMLWorkbook: the saved file carries no VBA project
        $workbook.RemovePersonalInformation = $true
        $workbook.SaveAs($OutputPath, 51)
    } else {
        # 52 = xlOpenXMLWorkbookMacroEnabled
        $workbook.SaveAs($OutputPath, 52)
    }
    Write-Host "Saved $OutputPath"
} finally {
    if ($workbook -ne $null) {
        $workbook.Close($false)
        [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($workbook)
    }
    if ($excel -ne $null) {
        $excel.Quit()
        [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($excel)
    }
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
    Remove-Item -Recurse -Force $staging -ErrorAction SilentlyContinue
}
exit $exitCode
