@echo off
:: Force the working directory to this script's directory
cd /d "%~dp0"

:: Launch PowerShell installer with ExecutionPolicy Bypass
PowerShell -NoProfile -ExecutionPolicy Bypass -File "install.ps1"

if %ERRORLEVEL% neq 0 (
    echo.
    echo [ERROR] Installation or update encountered an issue.
    pause
)