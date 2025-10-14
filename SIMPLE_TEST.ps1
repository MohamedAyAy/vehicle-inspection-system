# Simple Technician Test Script

Write-Host "Testing Technician Endpoints..." -ForegroundColor Cyan
Write-Host ""

# Try to login
$loginBody = '{"email":"admin@example.com","password":"Admin123"}'

try {
    Write-Host "1. Logging in..." -ForegroundColor Yellow
    $response = Invoke-RestMethod -Uri "http://localhost:8001/login" -Method Post -Body $loginBody -ContentType "application/json"
    $token = $response.access_token
    Write-Host "   Login successful!" -ForegroundColor Green
    Write-Host ""
    
    $headers = @{"Authorization" = "Bearer $token"}
    
    # Test appointments
    Write-Host "2. Fetching appointments..." -ForegroundColor Yellow
    $appointments = Invoke-RestMethod -Uri "http://localhost:8002/appointments/all" -Headers $headers
    Write-Host "   Total appointments: $($appointments.Count)" -ForegroundColor Cyan
    
    if ($appointments.Count -gt 0) {
        foreach ($apt in $appointments) {
            Write-Host "   - $($apt.vehicle_info.registration) | Status: $($apt.status)" -ForegroundColor White
        }
    } else {
        Write-Host "   WARNING: No appointments found!" -ForegroundColor Red
    }
    Write-Host ""
    
    # Test inspection service
    Write-Host "3. Fetching vehicles from inspection service..." -ForegroundColor Yellow
    $vehicles = Invoke-RestMethod -Uri "http://localhost:8004/inspections/vehicles-for-inspection" -Headers $headers
    Write-Host "   Total vehicles: $($vehicles.total_count)" -ForegroundColor Cyan
    Write-Host "   Vehicles count: $($vehicles.vehicles.Count)" -ForegroundColor Cyan
    
    if ($vehicles.vehicles.Count -gt 0) {
        Write-Host "   Vehicles found:" -ForegroundColor Green
        foreach ($v in $vehicles.vehicles) {
            Write-Host "   - $($v.vehicle_info.registration)" -ForegroundColor White
        }
    } else {
        Write-Host "   WARNING: No vehicles returned!" -ForegroundColor Red
        if ($appointments.Count -gt 0) {
            Write-Host "   BUG: Appointments exist but vehicles not returned!" -ForegroundColor Red
        }
    }
    
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Test complete." -ForegroundColor Cyan
