# AI EXPENSE TRACKING - Quick Launch Script for PowerShell
Write-Host "===================================================" -ForegroundColor Cyan
Write-Host "  AI EXPENSE TRACKING - Launching Application" -ForegroundColor Cyan
Write-Host "===================================================" -ForegroundColor Cyan
Write-Host ""

if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] Node.js is not installed or not in PATH." -ForegroundColor Red
    Write-Host "Please install Node.js 18+ from https://nodejs.org/" -ForegroundColor Yellow
    exit 1
}

if (-not (Test-Path .env)) {
    if (Test-Path .env.example) {
        Write-Host "[INFO] Creating .env from .env.example..." -ForegroundColor Green
        Copy-Item .env.example .env
        Write-Host "[NOTICE] You can update .env with your Gemini API key from https://aistudio.google.com/" -ForegroundColor Yellow
    }
}

if (-not (Test-Path node_modules)) {
    Write-Host "[INFO] Installing dependencies..." -ForegroundColor Green
    npm install
}

if (-not (Test-Path dist/index.html)) {
    Write-Host "[INFO] Building application bundle..." -ForegroundColor Green
    npm run build
}

Write-Host "[INFO] Starting server on http://127.0.0.1:3000..." -ForegroundColor Green
Start-Process "http://127.0.0.1:3000"
node server.js
