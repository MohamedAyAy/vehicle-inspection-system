# Install dependencies for new services

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Installing New Services Dependencies" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

$baseDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Install notification service dependencies
Write-Host "[1/2] Installing Notification Service dependencies..." -ForegroundColor Yellow
cd "$baseDir\backend\notification-service"
pip install -r requirements.txt
Write-Host "  ✓ Notification Service dependencies installed" -ForegroundColor Green
Write-Host ""

# Install file service dependencies  
Write-Host "[2/2] Installing File Service dependencies..." -ForegroundColor Yellow
cd "$baseDir\backend\file-service"
pip install -r requirements.txt
Write-Host "  ✓ File Service dependencies installed" -ForegroundColor Green
Write-Host ""

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Installation Complete!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Create databases: psql -U postgres -f SETUP_NEW_DATABASES.sql" -ForegroundColor White
Write-Host "2. Start services: .\START_COMPLETE_SYSTEM.ps1" -ForegroundColor White
Write-Host ""
