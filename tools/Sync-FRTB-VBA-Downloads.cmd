@echo off
setlocal EnableExtensions
rem Imports into an existing FRTB-SA workbook only the repository modules
rem found in a folder, by default Downloads. Drag the .xlsm onto this file
rem or pass its path. The repository files are not changed.
set "REPO_ROOT=%~dp0.."
set "SCRIPT=%~dp0Sync-FRTB-VBA.ps1"
set "DEFAULT_SOURCE=%USERPROFILE%\Downloads"

if not exist "%SCRIPT%" (
    echo ERROR: PowerShell script not found:
    call :echovar SCRIPT
    echo.
    pause
    exit /b 1
)

set "WORKBOOK=%~1"
if not defined WORKBOOK (
    echo FRTB-SA VBA synchronization from a folder
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

echo FRTB-SA VBA synchronization from a folder
echo.
echo Imports only the repository modules found in the folder, for example
echo modules downloaded for a test. The repository files are not changed.
echo.

set "SOURCE="
set /p "SOURCE=Folder with the modules [%DEFAULT_SOURCE%]: "
if not defined SOURCE set "SOURCE=%DEFAULT_SOURCE%"
set "SOURCE=%SOURCE:"=%"
if not exist "%SOURCE%\" (
    echo.
    echo ERROR: Folder not found:
    call :echovar SOURCE
    echo.
    pause
    exit /b 1
)

echo.
echo Workbook:
call :echovar WORKBOOK
echo Folder:
call :echovar SOURCE
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%" -WorkbookPath "%WORKBOOK%" -RepoRoot "%REPO_ROOT%" -SourceDir "%SOURCE%"
set "RC=%ERRORLEVEL%"

echo.
if "%RC%"=="0" (
    echo SUCCESS: modules imported from the folder.
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
