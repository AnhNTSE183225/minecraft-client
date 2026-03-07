@echo off
echo ====================================
echo Minecraft Mods and Resource Packs Sync Script
echo ====================================
echo.
REM Get the script directory (Client folder)
set SCRIPT_DIR=%~dp0
set CLIENT_MODS=%SCRIPT_DIR%mods
set MINECRAFT_MODS=%APPDATA%\.minecraft\mods
set CLIENT_RESOURCEPACKS=%SCRIPT_DIR%resourcepacks
set MINECRAFT_RESOURCEPACKS=%APPDATA%\.minecraft\resourcepacks
set OPTIONS_FILE=%APPDATA%\.minecraft\options.txt
set OVERRIDES_FILE=%SCRIPT_DIR%minecraft-overrides.txt

echo Mods Source: %CLIENT_MODS%
echo Mods Target: %MINECRAFT_MODS%
echo Resource Packs Source: %CLIENT_RESOURCEPACKS%
echo Resource Packs Target: %MINECRAFT_RESOURCEPACKS%
echo.
REM Check if mods folder exists in Client directory
if not exist "%CLIENT_MODS%" (
    echo ERROR: mods folder not found in Client directory!
    echo Please make sure the mods folder exists next to this script.
    pause
    exit /b 1
)

REM Remove old mods folder if it exists
if exist "%MINECRAFT_MODS%" (
    echo Removing old mods folder...
    rmdir /s /q "%MINECRAFT_MODS%"
    if errorlevel 1 (
        echo ERROR: Failed to remove old mods folder.
        echo Make sure Minecraft is closed and try again.
        pause
        exit /b 1
    )
    echo Old mods folder removed successfully.
    echo.
)

REM Create .minecraft directory if it doesn't exist
if not exist "%APPDATA%\.minecraft" (
    echo Creating .minecraft directory...
    mkdir "%APPDATA%\.minecraft"
)

REM Copy new mods folder
echo Copying new mods folder...
xcopy "%CLIENT_MODS%" "%MINECRAFT_MODS%" /E /I /H /Y
if errorlevel 1 (
    echo ERROR: Failed to copy mods folder.
    pause
    exit /b 1
)

REM ====================================
REM Sync Resource Packs
REM ====================================
echo.
echo Syncing resource packs...
echo.
REM Check if resourcepacks folder exists in Client directory
if not exist "%CLIENT_RESOURCEPACKS%" (
    echo WARNING: resourcepacks folder not found in Client directory!
    echo Skipping resource packs sync...
    echo.
) else (
    REM Remove old resourcepacks folder if it exists
    if exist "%MINECRAFT_RESOURCEPACKS%" (
        echo Removing old resourcepacks folder...
        rmdir /s /q "%MINECRAFT_RESOURCEPACKS%"
        if errorlevel 1 (
            echo ERROR: Failed to remove old resourcepacks folder.
            echo Make sure Minecraft is closed and try again.
            pause
            exit /b 1
        )
        echo Old resourcepacks folder removed successfully.
        echo.
    )

    REM Copy new resourcepacks folder
    echo Copying new resourcepacks folder...
    xcopy "%CLIENT_RESOURCEPACKS%" "%MINECRAFT_RESOURCEPACKS%" /E /I /H /Y
    if errorlevel 1 (
        echo ERROR: Failed to copy resourcepacks folder.
        pause
        exit /b 1
    )
    echo Resource packs synced successfully!
    echo.
)

REM ====================================
REM Apply Minecraft Options Overrides
REM ====================================
echo.
echo Applying Minecraft options overrides...
if not exist "%OVERRIDES_FILE%" (
    echo WARNING: minecraft-overrides.txt not found.
    echo Skipping options overrides...
) else if not exist "%OPTIONS_FILE%" (
    echo WARNING: options.txt not found.
    echo Please launch the game at least once to generate it, then run this script again.
) else (
    REM Using PowerShell to read overrides file and apply each line to options.txt
    powershell -Command "$overridesFile = '%OVERRIDES_FILE%'; $optionsFile = '%OPTIONS_FILE%'; $content = Get-Content $optionsFile; $overrides = Get-Content $overridesFile | Where-Object { $_ -notmatch '^\s*#' -and $_ -match '\S' }; foreach ($override in $overrides) { if ($override -match '^([^:]+):(.*)$') { $key = $matches[1]; $value = $matches[2]; $pattern = '^' + [regex]::Escape($key) + ':.*'; $replacement = $key + ':' + $value; $content = $content -replace $pattern, $replacement } }; $content | Set-Content $optionsFile"
    
    if errorlevel 1 (
        echo ERROR: Failed to apply options overrides.
    ) else (
        echo Options overrides applied successfully.
    )
)

echo.
echo ====================================
echo Sync completed successfully!
echo ====================================
echo.
echo You can now launch Minecraft.
echo.
pause