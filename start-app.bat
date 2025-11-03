@echo off
echo ========================================
echo  Vindhya School Management System
echo  Quick Start Script
echo ========================================
echo.

REM Stop any running Node.js processes
echo Stopping old backend servers...
taskkill /F /IM node.exe >nul 2>&1

REM Start backend server in new window
echo Starting backend server...
start "Backend Server" cmd /k "cd /d d:\Vindhya\backend && node server.js"

REM Wait for backend to start
echo Waiting for server to initialize...
timeout /t 5 /nobreak >nul

REM Start Flutter app
echo.
echo Starting Flutter app on your phone...
echo This will take 1-2 minutes...
echo.
cd /d d:\Vindhya\frontend
flutter run -d TCQOXGYTLF8HUC9T

pause
