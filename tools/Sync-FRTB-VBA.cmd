@echo off
setlocal EnableExtensions
rem Synchronizes the VBA modules of this repository checkout into an existing
rem FRTB-SA workbook. Drag the .xlsm onto this file or pass its path.
set "REPO_ROOT=%~dp0.."
set "SCRIPT=%~dp0Sync-FRTB-VBA.ps1"

if not exist "%SCRIPT%" (
    echo ERROR: PowerShell script not found:
    call :echovar SCRIPT
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
    call :echovar WORKBOOK
    echo.
    pause
    exit /b 1
)

echo FRTB-SA VBA synchronization from the repository checkout
echo.
echo Repository:
call :echovar REPO_ROOT
echo Workbook:
call :echovar WORKBOOK
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

:echovar
rem Prints the value of the named variable, indented. Delayed expansion
rem inserts the value after the line is parsed, so ampersands, pipes,
rem redirections and parentheses in a path are printed, never run.
setlocal EnableDelayedExpansion
echo(  !%~1!
endlocal
exit /b 0
