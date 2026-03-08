@echo off
echo ====================================
echo Minecraft Client Installer
echo ====================================
echo.

REM ====================================
REM Configuration
REM ====================================
set REPO_URL=https://github.com/AnhNTSE183225/minecraft-client.git

REM ====================================
REM Setup Variables
REM ====================================
set TEMP_DIR=%TEMP%\minecraft_client_install_%RANDOM%

echo Repository: %REPO_URL%
echo Temporary Directory: %TEMP_DIR%
echo.

REM ====================================
REM Check for Git
REM ====================================
where git >nul 2>nul
if errorlevel 1 (
    echo ERROR: Git is not installed or not in PATH!
    echo.
    echo Please install Git from: https://git-scm.com/download/win
    echo After installing, restart this script.
    echo.
    pause
    exit /b 1
)

echo Git found: OK
echo.

REM ====================================
REM Check for Git LFS
REM ====================================
where git-lfs >nul 2>nul
if errorlevel 1 (
    echo Git LFS is not installed. Installing now...
    echo.
    
    set GIT_LFS_VERSION=3.5.1
    set GIT_LFS_INSTALLER=%TEMP%\git-lfs-windows-v%GIT_LFS_VERSION%.exe
    set GIT_LFS_URL=https://github.com/git-lfs/git-lfs/releases/download/v%GIT_LFS_VERSION%/git-lfs-windows-v%GIT_LFS_VERSION%.exe
    
    echo Downloading Git LFS v%GIT_LFS_VERSION%...
    echo From: %GIT_LFS_URL%
    echo.
    
    REM Download using PowerShell
    powershell -Command "try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%GIT_LFS_URL%' -OutFile '%GIT_LFS_INSTALLER%' -UseBasicParsing } catch { exit 1 }"
    
    if errorlevel 1 (
        echo.
        echo ERROR: Failed to download Git LFS installer.
        echo Please manually install Git LFS from: https://git-lfs.com/
        echo After installing, restart this script.
        echo.
        pause
        exit /b 1
    )
    
    echo Installing Git LFS...
    echo.
    
    REM Run installer silently
    "%GIT_LFS_INSTALLER%" /VERYSILENT /NORESTART
    
    if errorlevel 1 (
        echo.
        echo ERROR: Failed to install Git LFS.
        echo Please manually install Git LFS from: https://git-lfs.com/
        echo After installing, restart this script.
        echo.
        pause
        exit /b 1
    )
    
    REM Clean up installer
    del "%GIT_LFS_INSTALLER%" >nul 2>nul
    
    echo Git LFS installation completed!
    echo.
    
    REM Refresh PATH in current session
    call :RefreshEnv
)

REM Initialize Git LFS (this sets up the git filters)
echo Initializing Git LFS...
git lfs install
if errorlevel 1 (
    echo.
    echo ERROR: Failed to initialize Git LFS.
    echo Please try running 'git lfs install' manually.
    echo.
    pause
    exit /b 1
)

echo Git LFS is ready: OK
echo.

REM ====================================
REM Clone Repository to Temp
REM ====================================
echo Cloning repository...
echo This may take a few minutes if there are large files...
echo.

git clone "%REPO_URL%" "%TEMP_DIR%"

if errorlevel 1 (
    echo.
    echo ERROR: Failed to clone repository.
    echo Please check:
    echo 1. The repository URL is correct
    echo 2. The repository is public or you have access
    echo 3. You have an internet connection
    echo.
    pause
    exit /b 1
)

cd /d "%TEMP_DIR%"
echo Clone completed!

echo.

REM ====================================
REM Run Sync Script
REM ====================================
echo.
echo ====================================
echo Running Minecraft Sync...
echo ====================================
echo.

if exist "%TEMP_DIR%\sync-mods.bat" (
    call sync-mods.bat
    set SYNC_SUCCESS=%ERRORLEVEL%
) else (
    echo ERROR: sync-mods.bat not found!
    echo Repository may be incomplete.
    pause
    exit /b 1
)

REM ====================================
REM Cleanup Temporary Directory
REM ====================================
echo.
echo Cleaning up temporary files...
cd /d "%USERPROFILE%"
rmdir /s /q "%TEMP_DIR%"

if %SYNC_SUCCESS% EQU 0 (
    echo.
    echo ====================================
    echo Installation Complete!
    echo ====================================
    echo.
    echo Mods and resource packs have been synced to your Minecraft installation.
    echo You can now launch Minecraft!
    echo.
    echo To update in the future, just run this install script again.
    echo.
) else (
    echo.
    echo WARNING: Sync may have encountered issues.
    echo Please check the output above.
    echo.
)
pause
exit /b 0

REM ====================================
REM Helper Function: Refresh Environment
REM ====================================
:RefreshEnv
REM Refresh PATH from registry to current session
for /f "tokens=2*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v PATH 2^>nul') do set "SYS_PATH=%%b"
for /f "tokens=2*" %%a in ('reg query "HKCU\Environment" /v PATH 2^>nul') do set "USER_PATH=%%b"
set "PATH=%SYS_PATH%;%USER_PATH%"
exit /b 0
