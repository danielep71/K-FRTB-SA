@echo off
setlocal EnableExtensions
rem Synchronizes the VBA modules of this repository checkout into an existing
rem FRTB-SA workbook. Drag the .xlsm onto this file or pass its path.
set "REPO_ROOT=%~dp0.."
set "SCRIPT=%~dp0Sync-FRTB-VBA.ps1"

if not exist "%SCRIPT%" (
    echo ERROR: PowerShell script not found:
    echo   %SCRIPT%
    echo.
    pause
    exit /b 1
)

set "WORKBOOK=%~1"
if not defined WORKBOOK (
    echo FRTB-SA VBA synchronization
    echo.
    echo No workbook given. Drag the .xlsm workbook onto this file, or run:
    echo   %~nx0 ^<path to workbook^>
    echo.
    pause
    exit /b 1
)
if not exist "%WORKBOOK%" (
    echo ERROR: Workbook not found:
    echo   %WORKBOOK%
    echo.
    pause
    exit /b 1
)

echo FRTB-SA VBA synchronization from the repository checkout
echo.
echo Repository:
echo   %REPO_ROOT%
echo Workbook:
echo   %WORKBOOK%
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%" -WorkbookPath "%WORKBOOK%" -RepoRoot "%REPO_ROOT%"
set "RC=%ERRORLEVEL%"

echo.
if "%RC%"=="0" (
    echo SUCCESS: VBA synchronized.
) else if "%RC%"=="2" (
    echo CANCELLED: the workbook was not changed.
) else (
    echo FAILED: the synchronization returned exit code %RC%.
)
echo.
pause
exit /b %RC%
