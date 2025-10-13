# Quick Fix Script - Apply Pydantic and FastAPI fixes to all services
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host "  Applying fixes to all services..." -ForegroundColor Yellow
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host ""

$services = @(
    "appointment-service",
    "payment-service",
    "inspection-service",
    "logging-service"
)

foreach ($service in $services) {
    Write-Host "Processing $service..." -ForegroundColor Green
    $mainPy = ".\backend\$service\main.py"
    
    if (Test-Path $mainPy) {
        # Read file
        $content = Get-Content $mainPy -Raw
        
        # Fix 1: Replace @validator with @field_validator
        $content = $content -replace 'from pydantic import (.*?)validator', 'from pydantic import $1field_validator'
        $content = $content -replace '@validator\(', '@field_validator('
        
        # Fix 2: Replace on_event with lifespan (this is more complex, manual fix recommended)
        
        # Write back
        Set-Content $mainPy -Value $content
        
        Write-Host "  [OK] $service updated" -ForegroundColor Green
    } else {
        Write-Host "  [SKIP] $mainPy not found" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host "  Fixes applied! Please review and test services." -ForegroundColor Green
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Note: Manual review recommended for complex fixes" -ForegroundColor Yellow
pause
