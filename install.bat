@echo off
setlocal EnableExtensions
echo ====================================
echo Minecraft Client Installer
echo ====================================
echo.

REM ====================================
REM Configuration
REM ====================================
set REPO_URL=https://github.com/AnhNTSE183225/minecraft-client.git
set REPO_BRANCH=main

REM ====================================
REM Setup Variables
REM ====================================
set CACHE_ROOT=%TEMP%\minecraft_client_cache
set TEMP_DIR=%CACHE_ROOT%\repo
set LOCK_DIR=%CACHE_ROOT%\.lock
set LOCK_ACQUIRED=

echo Repository: %REPO_URL%
echo Cache Directory: %TEMP_DIR%
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
REM Acquire Lock For Safe Multi-Instance Execution
REM ====================================
echo Acquiring install lock...
call :AcquireLock
if errorlevel 1 (
    echo.
    echo ERROR: Failed to acquire install lock.
    pause
    exit /b 1
)

REM ====================================
REM Prepare Repository Cache
REM ====================================
if not exist "%CACHE_ROOT%" mkdir "%CACHE_ROOT%"

set NEED_RECLONE=
if exist "%TEMP_DIR%\.git" (
    echo Reusing existing cache and updating from %REPO_BRANCH%...
    cd /d "%TEMP_DIR%"

    set HAS_REMOTE=
    for /f "delims=" %%i in ('git remote get-url origin 2^>nul') do (
        set HAS_REMOTE=1
        if /i not "%%i"=="%REPO_URL%" set NEED_RECLONE=1
    )
    if not defined HAS_REMOTE set NEED_RECLONE=1
    if defined NEED_RECLONE echo Remote URL changed or missing. Recreating cache...

    if not defined NEED_RECLONE (
        git checkout %REPO_BRANCH% >nul 2>nul
        if errorlevel 1 (
            git fetch origin %REPO_BRANCH%
            if errorlevel 1 set NEED_RECLONE=1
            if not errorlevel 1 git checkout -b %REPO_BRANCH% origin/%REPO_BRANCH%
        )

        if not defined NEED_RECLONE (
            git pull --ff-only origin %REPO_BRANCH%
            if errorlevel 1 set NEED_RECLONE=1
        )
    )
) else (
    set NEED_RECLONE=1
)

if defined NEED_RECLONE (
    echo Cloning repository into cache...
    echo This may take a few minutes if there are large files...
    echo.

    if exist "%TEMP_DIR%" rmdir /s /q "%TEMP_DIR%"
    git clone --branch %REPO_BRANCH% "%REPO_URL%" "%TEMP_DIR%"
    if errorlevel 1 (
        echo.
        echo ERROR: Failed to clone repository.
        echo Please check:
        echo 1. The repository URL is correct
        echo 2. The repository is public or you have access
        echo 3. You have an internet connection
        echo.
        call :ReleaseLock
        pause
        exit /b 1
    )
)

cd /d "%TEMP_DIR%"

echo Pulling Git LFS content...
git lfs pull
if errorlevel 1 (
    echo.
    echo ERROR: Failed to pull Git LFS content.
    echo Please verify your Git LFS installation and network access.
    echo.
    call :ReleaseLock
    pause
    exit /b 1
)

echo Repository cache is ready.
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
    call :ReleaseLock
    pause
    exit /b 1
)

REM ====================================
REM Release Lock
REM ====================================
call :ReleaseLock

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
REM Helper Function: Acquire Lock
REM ====================================
:AcquireLock
set /a LOCK_WAIT=0
:AcquireLockTry
mkdir "%LOCK_DIR%" >nul 2>nul
if not errorlevel 1 (
    set LOCK_ACQUIRED=1
    exit /b 0
)
set /a LOCK_WAIT+=1
if %LOCK_WAIT% GEQ 180 (
    echo Timeout waiting for another installer instance to finish.
    exit /b 1
)
echo Another install.bat instance is running. Waiting for cache lock...
timeout /t 2 /nobreak >nul
goto AcquireLockTry

REM ====================================
REM Helper Function: Release Lock
REM ====================================
:ReleaseLock
if defined LOCK_ACQUIRED (
    rmdir "%LOCK_DIR%" >nul 2>nul
    set LOCK_ACQUIRED=
)
exit /b 0

REM ====================================
REM Helper Function: Refresh Environment
REM ====================================
:RefreshEnv
REM Refresh PATH from registry to current session
set "ORIGINAL_PATH=%PATH%"
set "SYS_PATH="
set "USER_PATH="
for /f "tokens=2*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v PATH 2^>nul') do set "SYS_PATH=%%b"
for /f "tokens=2*" %%a in ('reg query "HKCU\Environment" /v PATH 2^>nul') do set "USER_PATH=%%b"
set "NEW_PATH="
if defined SYS_PATH (
    set "NEW_PATH=%SYS_PATH%"
)
if defined USER_PATH (
    if defined NEW_PATH (
        set "NEW_PATH=%NEW_PATH%;%USER_PATH%"
    ) else (
        set "NEW_PATH=%USER_PATH%"
    )
)
if defined NEW_PATH (
    set "PATH=%NEW_PATH%"
) else (
    set "PATH=%ORIGINAL_PATH%"
)
exit /b 0
