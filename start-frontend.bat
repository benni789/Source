@echo off
setlocal
title Ninja Saga Frontend Launcher

set "ROOT_DIR=%~dp0"
set "CLIENT_DIR=%ROOT_DIR%client"
set "PHP_EXE=C:\xampp\php\php.exe"
set "PORT=5500"

if not exist "%CLIENT_DIR%\index.html" (
  echo [ERROR] Folder client tidak ditemukan: "%CLIENT_DIR%"
  pause
  exit /b 1
)

if not exist "%PHP_EXE%" (
  echo [ERROR] PHP tidak ditemukan di: "%PHP_EXE%"
  echo Pastikan XAMPP terpasang di C:\xampp
  pause
  exit /b 1
)

echo ==========================================
echo   Ninja Saga Frontend - One Click Start
echo ==========================================
echo CLIENT : %CLIENT_DIR%
echo URL    : http://localhost:%PORT%
echo.
echo Biarkan jendela ini tetap terbuka selama frontend dipakai.
echo.

cd /d "%CLIENT_DIR%"
"%PHP_EXE%" -S 0.0.0.0:%PORT%

echo.
echo Frontend berhenti. Tekan tombol apa saja untuk menutup.
pause >nul
endlocal
