@echo off
setlocal
title AI EXPENSE TRACKING - Launch Server
echo ===================================================
echo   AI EXPENSE TRACKING - Launching Application
echo ===================================================
echo.

where node >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Node.js is not installed or not in PATH.
    echo Please install Node.js 18+ from https://nodejs.org/
    pause
    exit /b 1
)

if not exist .env (
    if exist .env.example (
        echo [INFO] Creating .env from .env.example...
        copy .env.example .env >nul
        echo [NOTICE] Please edit .env with your Gemini API key if you want AI features.
    )
)

if not exist node_modules (
    echo [INFO] Installing project dependencies...
    call npm install
)

if not exist dist\index.html (
    echo [INFO] Building production bundle...
    call npm run build
)

echo [INFO] Starting AI EXPENSE TRACKING server at http://127.0.0.1:3000
start "" http://127.0.0.1:3000
node server.js
pause
