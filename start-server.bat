@echo off
setlocal
title Ninja Saga Backend Launcher

set "ROOT_DIR=%~dp0"
set "SERVER_DIR=%ROOT_DIR%server"
set "MAVEN_CMD=%ROOT_DIR%tools\apache-maven-3.9.9\bin\mvn.cmd"
set "JDK_DIR=C:\Program Files\Eclipse Adoptium\jdk-17.0.19.10-hotspot"

if not exist "%SERVER_DIR%\pom.xml" (
  echo [ERROR] Folder server tidak ditemukan: "%SERVER_DIR%"
  pause
  exit /b 1
)

if not exist "%MAVEN_CMD%" (
  echo [ERROR] Maven lokal tidak ditemukan: "%MAVEN_CMD%"
  echo Pastikan folder tools\apache-maven-3.9.9 sudah ada.
  pause
  exit /b 1
)

if not exist "%JDK_DIR%\bin\java.exe" (
  echo [ERROR] JDK 17 tidak ditemukan di:
  echo         "%JDK_DIR%"
  echo Install dulu Eclipse Temurin JDK 17.
  pause
  exit /b 1
)

set "JAVA_HOME=%JDK_DIR%"
set "Path=%JAVA_HOME%\bin;%Path%"

echo ==========================================
echo   Ninja Saga Backend - One Click Start
echo ==========================================
echo JAVA_HOME: %JAVA_HOME%
echo SERVER   : %SERVER_DIR%
echo.

cd /d "%SERVER_DIR%"
call "%MAVEN_CMD%" spring-boot:run

echo.
echo Server berhenti. Tekan tombol apa saja untuk menutup.
pause >nul
endlocal
