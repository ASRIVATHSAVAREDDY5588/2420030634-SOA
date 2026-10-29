# AI EXPENSE TRACKING - Automated Test Suite for PowerShell
Write-Host "===================================================" -ForegroundColor Cyan
Write-Host "  AI EXPENSE TRACKING - Automated Test Suite" -ForegroundColor Cyan
Write-Host "===================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[1/2] Verifying production build & asset bundling..." -ForegroundColor Yellow
npm run build
if ($LASTEXITCODE -ne 0) {
    Write-Host "[FAIL] Vite build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "[2/2] Verifying server syntax & handler integrity..." -ForegroundColor Yellow
node -c server.js
if ($LASTEXITCODE -ne 0) {
    Write-Host "[FAIL] server.js syntax verification failed!" -ForegroundColor Red
    exit 1
}
node -c server/geminiHandler.js
if ($LASTEXITCODE -ne 0) {
    Write-Host "[FAIL] server/geminiHandler.js syntax verification failed!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "===================================================" -ForegroundColor Green
Write-Host "  [SUCCESS] All Automated Build & Syntax Tests Passed!" -ForegroundColor Green
Write-Host "===================================================" -ForegroundColor Green
