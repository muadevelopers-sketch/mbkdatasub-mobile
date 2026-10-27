@echo off
title MBKDATASUB - Flutter Environment Setup
color 0B
echo =====================================================================
echo          MBKDATASUB MOBILE APP - LOCAL FLUTTER INSTALLER
echo =====================================================================
echo.
echo This script will set up Flutter, Java 17, and Dart on your computer
echo in a portable directory (no Administrator rights needed).
echo.
echo Recommended: If you want your APK right now without waiting for 
echo heavy gigabyte downloads, use the GitHub Actions Cloud Build or FlutterFlow!
echo.
set /p choice="Do you want to proceed with local setup? (y/n): "
if /i not "%choice%"=="y" goto cancel

set TARGET_DIR=%USERPROFILE%\development
if not exist "%TARGET_DIR%" mkdir "%TARGET_DIR%"

echo.
echo [1/3] Downloading Git Portable...
powershell -Command "Invoke-WebRequest -Uri 'https://github.com/git-for-windows/git/releases/download/v2.44.0.windows.1/MinGit-2.44.0-64-bit.zip' -OutFile '%TARGET_DIR%\mingit.zip'"
powershell -Command "Expand-Archive -Path '%TARGET_DIR%\mingit.zip' -DestinationPath '%TARGET_DIR%\mingit' -Force"
del "%TARGET_DIR%\mingit.zip"

echo.
echo [2/3] Cloning Flutter Stable SDK...
set PATH=%TARGET_DIR%\mingit\cmd;%PATH%
"%TARGET_DIR%\mingit\cmd\git.exe" clone https://github.com/flutter/flutter.git -b stable "%TARGET_DIR%\flutter"

echo.
echo [3/3] Setting User Environment PATH...
powershell -Command "[Environment]::SetEnvironmentVariable('Path', [Environment]::GetEnvironmentVariable('Path', 'User') + ';%TARGET_DIR%\flutter\bin;%TARGET_DIR%\mingit\cmd', 'User')"

set PATH=%TARGET_DIR%\flutter\bin;%PATH%

echo.
echo =====================================================================
echo Flutter setup complete! Verifying installation...
echo =====================================================================
call flutter doctor

pause
exit /b 0

:cancel
echo Setup cancelled.
pause
exit /b 0
