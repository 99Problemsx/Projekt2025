@echo off
REM ===============================================================================
REM XVLAUNCHER TEST - Starte Launcher lokal
REM ===============================================================================

color 0B
title XVLauncher Test für Projekt2025

echo.
echo ╔══════════════════════════════════════════════════════════════════╗
echo ║                                                                  ║
echo ║          🎮 XVLAUNCHER TEST - Projekt2025                        ║
echo ║                                                                  ║
echo ╚══════════════════════════════════════════════════════════════════╝
echo.

cd "%~dp0"

echo [1/3] Prüfe Voraussetzungen...
echo.

REM Prüfe Visual Studio
where msbuild >nul 2>&1
if errorlevel 1 (
    echo ❌ MSBuild nicht gefunden!
    echo.
    echo Bitte Visual Studio Developer Command Prompt verwenden:
    echo    Start ^> Visual Studio 2022 ^> Developer Command Prompt
    echo.
    pause
    exit /b 1
)
echo    ✅ Visual Studio gefunden
echo.

REM Prüfe Game.exe
if not exist "Game\Game.exe" (
    echo ❌ Game\Game.exe nicht gefunden!
    echo    Bitte zuerst Release erstellen:
    echo    cd Game
    echo    ruby create_graphics_pack.rb
    echo    ruby create_release.rb
    echo    copy Release\Game.exe .
    echo.
    pause
    exit /b 1
)
echo    ✅ Game\Game.exe vorhanden

if not exist "Game\Graphics.pack" (
    echo ⚠️  Game\Graphics.pack nicht gefunden!
    echo    Launcher wird ohne Graphics Encryption laufen
    echo.
) else (
    echo    ✅ Game\Graphics.pack vorhanden (verschlüsselt)
)
echo.

echo ═══════════════════════════════════════════════════════════════════
echo.

echo [2/3] Baue XVLauncher...
echo.

REM NuGet Restore
echo    📦 Restore NuGet Packages...
nuget restore XVLauncher.sln >nul 2>&1
if errorlevel 1 (
    echo    ⚠️  NuGet restore fehlgeschlagen (eventuell OK)
)

REM Build Solution
echo    🔨 Kompiliere Launcher...
msbuild XVLauncher.sln /p:Configuration=Debug /p:Platform="Any CPU" /verbosity:minimal
if errorlevel 1 (
    echo.
    echo ❌ Build fehlgeschlagen!
    echo.
    pause
    exit /b 1
)
echo.
echo    ✅ XVLauncher kompiliert
echo.

echo ═══════════════════════════════════════════════════════════════════
echo.

echo [3/3] Starte Launcher...
echo.

REM Finde Build Output
set LAUNCHER_EXE=bin\Debug\XVLauncher.exe
if not exist "%LAUNCHER_EXE%" (
    set LAUNCHER_EXE=bin\x86\Debug\XVLauncher.exe
)
if not exist "%LAUNCHER_EXE%" (
    echo ❌ Launcher exe nicht gefunden!
    echo    Erwartet: bin\Debug\XVLauncher.exe
    pause
    exit /b 1
)

echo Starte: %LAUNCHER_EXE%
echo.
start "" "%LAUNCHER_EXE%"

echo ✅ Launcher gestartet!
echo.
echo TEST CHECKLISTE:
echo   □ Launcher Fenster erscheint
echo   □ "SPIELEN" Button verfügbar
echo   □ Click "SPIELEN"
echo   □ Graphics werden entschlüsselt (10-15 Sek)
echo   □ Pokemon Spiel startet
echo   □ Graphics sind sichtbar
echo.

pause
