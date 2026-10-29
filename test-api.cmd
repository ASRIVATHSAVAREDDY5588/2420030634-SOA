@echo off
setlocal
title AI EXPENSE TRACKING - API Verification
powershell -ExecutionPolicy Bypass -File "%~dp0test-api.ps1"
pause
