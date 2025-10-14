# Quick Test Script for Vehicle Inspection System V2.0
# Tests all services and frontend accessibility

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Vehicle Inspection System V2.0 Test  " -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Test all service health
Write-Host "Testing Services..." -ForegroundColor Yellow
Write-Host "-------------------" -ForegroundColor Yellow

$services = @(
    @{name="Auth Service"; port=8001},
    @{name="Appointment Service"; port=8002},
    @{name="Payment Service"; port=8003},
    @{name="Inspection Service"; port=8004},
    @{name="Logging Service"; port=8005},
    @{name="Notification Service"; port=8006; new=$true},
    @{name="File Service"; port=8007; new=$true}
)

$allHealthy = $true

foreach ($svc in $services) {
    try {
        $response = Invoke-RestMethod "http://localhost:$($svc.port)/health" -TimeoutSec 2
        $marker = if ($svc.new) { " (NEW)" } else { "" }
        Write-Host "✓ $($svc.name)$marker (Port $($svc.port)): " -NoNewline -ForegroundColor Green
        Write-Host "$($response.status)" -ForegroundColor White
    } catch {
        Write-Host "✗ $($svc.name) (Port $($svc.port)): " -NoNewline -ForegroundColor Red
        Write-Host "NOT RUNNING" -ForegroundColor Red
        $allHealthy = $false
    }
}

Write-Host ""

# Test frontend
Write-Host "Testing Frontend..." -ForegroundColor Yellow
Write-Host "------------------" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest "http://localhost:3000" -TimeoutSec 2 -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "✓ Frontend (Port 3000): " -NoNewline -ForegroundColor Green
        Write-Host "Accessible" -ForegroundColor White
    }
} catch {
    Write-Host "✗ Frontend (Port 3000): " -NoNewline -ForegroundColor Red
    Write-Host "NOT ACCESSIBLE" -ForegroundColor Red
    $allHealthy = $false
}

Write-Host ""

# Summary
Write-Host "========================================" -ForegroundColor Cyan
if ($allHealthy) {
    Write-Host "  ✅ ALL SERVICES HEALTHY!  " -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "🎉 System is ready!" -ForegroundColor Green
    Write-Host "Open browser: http://localhost:3000" -ForegroundColor White
    Write-Host ""
    Write-Host "Test the new features:" -ForegroundColor Yellow
    Write-Host "  1. Click bell icon 🔔 in header" -ForegroundColor White
    Write-Host "  2. Register → See welcome notification" -ForegroundColor White
    Write-Host "  3. Book appointment → See booking notification" -ForegroundColor White
    Write-Host "  4. Pay → See payment notification" -ForegroundColor White
    Write-Host "  5. Login as technician → Upload photos" -ForegroundColor White
    Write-Host "  6. Submit inspection → See inspection notification" -ForegroundColor White
} else {
    Write-Host "  ⚠️  SOME SERVICES NOT RUNNING  " -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "To start all services:" -ForegroundColor Yellow
    Write-Host "  .\START_COMPLETE_SYSTEM.ps1" -ForegroundColor White
    Write-Host ""
    Write-Host "To create new databases (if not created):" -ForegroundColor Yellow
    Write-Host "  psql -U postgres -f SETUP_NEW_DATABASES.sql" -ForegroundColor White
}

Write-Host ""
