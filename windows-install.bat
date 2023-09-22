@echo off
SETLOCAL

REM Check if Python is installed and in PATH
where python >nul 2>nul
if %errorlevel% neq 0 (
    echo Python is not installed or not in PATH.
    goto InstallPython
)

REM Check Python version if installed
for /f "tokens=*" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i

REM Check if the version string actually contains "Python"
echo %PYTHON_VERSION% | find "Python" > nul
if %errorlevel% neq 0 (
    echo Python is not properly installed or a different executable is being called.
    goto InstallPython
)

set PYTHON_VERSION=%PYTHON_VERSION:~7%
for /f "tokens=1,2,3 delims=." %%a in ("%PYTHON_VERSION%") do (
    set Major=%%a
    set Minor=%%b
    set Patch=%%c
)
echo Detected Python version: %Major%.%Minor%.%Patch%

REM Perform numerical comparison to check if version is adequate
if %Major% geq 3 (
    if %Major% gtr 3 (
        echo Python version is adequate.
        goto End
    ) else (
        if %Minor% geq 9 (
            echo Python version is adequate.
	    call ./install/windows-install-part2.bat
            goto End
        )
    )
)

echo Python version is not adequate.
goto InstallPython

:InstallPython
echo Installing Python 3.10.6...
REM Note: Internet access is required for this part, and it's disabled in this session. Make sure you're connected.
REM Download and install Python 3.10.6.
bitsadmin /transfer downloadPython /download /priority normal https://www.python.org/ftp/python/3.10.6/python-3.10.6-amd64.exe %CD%\python-3.10.6-amd64.exe
start /wait python-3.10.6-amd64.exe /quiet InstallAllUsers=1 PrependPath=1
if %errorlevel% neq 0 (
    echo Failed to install Python.
    exit /b 1
)
REM Refresh environment variables by starting a new Command Prompt session
start cmd.exe /k
echo Python 3.10.6 installed successfully.
call ./install/windows-install-part2.bat

:End
ENDLOCAL

exit /b 0
