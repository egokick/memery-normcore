@echo off
setlocal enabledelayedexpansion

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
    echo Python is not installed or not you do not have python > 3.9 in PATH.
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
            goto End
        )
    )
)

echo Python version is not adequate.
goto InstallPython

:InstallPython
echo Installing Python 3.10.6...
REM Note: Internet access is required for this part, and it's disabled in this session. Make sure you're connected.
REM Check if Python installer already exists
if not exist "%CD%\python-3.10.6-amd64.exe" (
    REM Download Python 3.10.6 using curl.
    curl -O https://www.python.org/ftp/python/3.10.6/python-3.10.6-amd64.exe
)
start /wait python-3.10.6-amd64.exe InstallAllUsers=1 PrependPath=1
if %errorlevel% neq 0 (
    echo Failed to install Python.
    exit /b 1
)
echo Python has been installed, run the install script again.
echo This will refresh the environment variables, ensure all other command windows are closed.
pause


:End
ENDLOCAL
 
REM Check path


:: Get the username dynamically
for /f "tokens=3 delims=\" %%i in ("!USERPROFILE!") do set username=%%i

:: Define the paths to be checked/added
set "path1_to_check=C:\Users\!username!\AppData\Roaming\Python\Python310\Scripts"
set "path2_to_check=C:\Program Files\Python310\Lib\site-packages"

:: Check and add path1_to_check
call :check_add_path "!path1_to_check!"

:: Check and add path2_to_check
call :check_add_path "!path2_to_check!"

:: Your additional batch commands go here
echo This is an additional command.



REM Install Python dependencies from requirements.txt
pip install -r ./install/requirements.txt
if %errorlevel% neq 0 (
    echo Failed to install Python dependencies from requirements.txt.
    pause
)

REM Check if Poetry is installed and in PATH
where poetry >nul 2>nul
if %errorlevel% neq 0 (
    echo Poetry is not installed or not in PATH.
    pause
)

REM Run 'poetry install' to install dependencies via Poetry
poetry install
if %errorlevel% neq 0 (
    echo Failed to install Python dependencies via Poetry.
    pause
)

REM Use local build folder
echo Use local build folder
pip install -e .

REM Run the Python script
python ./install/windows-install.py

REM Check the exit code of the Python script
if %errorlevel% neq 0 (
    echo Failed to execute Python script.
    pause
)
echo Success Installed.
pause


:: Return to the original state
endlocal
goto :eof

:: Function to check and add a given path to PATH
:check_add_path
    set "path_to_check=%~1"
    set "path_copy=!PATH!"
    set "path_copy=!path_copy:;=; !"
    set "path_found=0"
    for %%p in (!path_copy!) do (
        if "%%~p"=="!path_to_check!" (
            set "path_found=1"
            goto function_end
        )
    )
    :function_end
    if "!path_found!"=="0" (
        powershell.exe -command "[Environment]::SetEnvironmentVariable('PATH', [Environment]::GetEnvironmentVariable('PATH', [EnvironmentVariableTarget]::User) + ';!path_to_check!', [EnvironmentVariableTarget]::User)"
        echo Added !path_to_check! to PATH.
    ) else (
        echo !path_to_check! is already in PATH.
    )
goto :eof