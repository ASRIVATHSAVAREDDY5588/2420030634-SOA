@echo off
setlocal
title AI EXPENSE TRACKING - Automated Test Suite
echo ===================================================
echo   AI EXPENSE TRACKING - Running Automated Tests
echo ===================================================
echo.

where node >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Node.js is not installed.
    exit /b 1
)

echo [1/2] Verifying production build & asset bundling...
call npm run build
if %ERRORLEVEL% neq 0 (
    echo [FAIL] Vite build failed!
    exit /b 1
)

echo [2/2] Verifying server syntax & handler integrity...
node -c server.js
if %ERRORLEVEL% neq 0 (
    echo [FAIL] server.js syntax verification failed!
    exit /b 1
)
node -c server/geminiHandler.js
if %ERRORLEVEL% neq 0 (
    echo [FAIL] server/geminiHandler.js syntax verification failed!
    exit /b 1
)

echo.
echo ===================================================
echo   [SUCCESS] All Automated Build & Syntax Tests Passed!
echo ===================================================
pause
