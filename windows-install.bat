@echo off
setlocal enabledelayedexpansion

set savedDir=%CD%
echo current working directory: %CD%

:: Check if Python is installed and in PATH
where python >nul 2>nul
if !errorlevel! neq 0 (
    echo Python is not installed or not in PATH.
    goto InstallPython
)

:: Check Python version if installed
for /f "tokens=*" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i

:: Check if the version string actually contains "Python"
echo !PYTHON_VERSION! | find "Python" > nul
if !errorlevel! neq 0 (
    echo Python is not installed or you do not have python > 3.9 in PATH.
    goto InstallPython
)

:: Parse Python version
set PYTHON_VERSION=!PYTHON_VERSION:~7!
for /f "tokens=1,2,3 delims=." %%a in ("!PYTHON_VERSION!") do (
    set Major=%%a
    set Minor=%%b
    set Patch=%%c
)
echo Detected Python version: !Major!.!Minor!.!Patch!

:: Perform numerical comparison to check if version is adequate
if !Major! geq 3 (
    if !Major! gtr 3 (
        echo Python version is adequate.
        goto End
    ) else (
        if !Minor! geq 9 (
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
goto End

:End
:: Rest of your script starts here

:: Get the username dynamically
for /f "tokens=3 delims=\" %%i in ("!USERPROFILE!") do set username=%%i
:: Store the username in a global scope
endlocal & set "username=%username%"


:: Rest of your code
call :check_add_path "C:\Users\%username%\AppData\Roaming\Python\Python310\Scripts"
call :check_add_path "C:\Program Files\Python310\Lib\site-packages"
call :otherstuff

:: Function to check and add a given path to PATH
:check_add_path
    setlocal enabledelayedexpansion
    set "path_to_check=%~1"

    :: Initialize path_found as 0
    set "path_found=0"

    :: Check if path_to_check is empty
    if "!path_to_check!"=="" ( 
        goto function_end
    )

    set "path_copy=!PATH!"
    set "path_copy=!path_copy:;=; !"

    for %%p in (!path_copy!) do (
        if "%%~p"=="!path_to_check!" (
            set "path_found=1"
            goto function_end
        )
    )

    :function_end
    endlocal & set "path_found=%path_found%"
    if "%path_found%"=="0" (
        if not "%~1"=="" (
            powershell.exe -command "[Environment]::SetEnvironmentVariable('PATH', [Environment]::GetEnvironmentVariable('PATH', [EnvironmentVariableTarget]::User) + ';%~1', [EnvironmentVariableTarget]::User)"
            echo Added %~1 to PATH.
        )
    ) else (
        echo %~1 is already in PATH.
    )
goto :eof

: otherstuff
cd %savedDir%
REM Install Python dependencies from requirements.txt
pip install -r ./install/requirements.txt 2> error_log.txt
if %errorlevel% neq 0 (
    echo Failed to install Python dependencies from requirements.txt.
    echo Current Working Directory: %CD%
    echo Error details:
    type error_log.txt
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
goto :eof
pause
