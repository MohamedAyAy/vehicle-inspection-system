# Comprehensive Technician Endpoint Testing Script

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Testing Technician Endpoints" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Test credentials
$testCredentials = @(
    @{Email="tech@test.com"; Password="Test1234"; Label="Test Tech"},
    @{Email="admin@example.com"; Password="Admin123"; Label="Admin"}
)

$token = $null
$userEmail = $null

# Step 1: Login
Write-Host "Step 1: Attempting Login..." -ForegroundColor Yellow
foreach ($cred in $testCredentials) {
    try {
        Write-Host "  Trying: $($cred.Email)" -ForegroundColor Gray
        
        $loginBody = @{
            email = $cred.Email
            password = $cred.Password
        } | ConvertTo-Json

        $response = Invoke-RestMethod -Uri "http://localhost:8001/login" `
            -Method Post `
            -Body $loginBody `
            -ContentType "application/json" `
            -TimeoutSec 5 `
            -ErrorAction Stop

        if ($response.access_token) {
            $token = $response.access_token
            $userEmail = $cred.Email
            Write-Host "  ✓ Login successful as $($cred.Label)" -ForegroundColor Green
            Write-Host "  Token: $($token.Substring(0, 20))..." -ForegroundColor Gray
            break
        }
    } catch {
        Write-Host "  ✗ Login failed: $($_.Exception.Message)" -ForegroundColor Gray
    }
}

if (-not $token) {
    Write-Host ""
    Write-Host "ERROR: Could not login!" -ForegroundColor Red
    Write-Host "Please ensure:" -ForegroundColor Yellow
    Write-Host "  1. Auth service is running on port 8001" -ForegroundColor White
    Write-Host "  2. Account exists (tech@test.com or admin@example.com)" -ForegroundColor White
    exit 1
}

Write-Host ""
Write-Host "Step 2: Testing Appointment Service..." -ForegroundColor Yellow

try {
    $headers = @{
        "Authorization" = "Bearer $token"
    }
    
    # Test 1: Get ALL appointments (no filter)
    Write-Host "  Test 2a: GET /appointments/all (no filter)" -ForegroundColor Cyan
    $allAppointments = Invoke-RestMethod -Uri "http://localhost:8002/appointments/all" `
        -Headers $headers `
        -TimeoutSec 5 `
        -ErrorAction Stop
    
    Write-Host "    ✓ Response received" -ForegroundColor Green
    Write-Host "    Total appointments: $($allAppointments.Count)" -ForegroundColor Cyan
    
    if ($allAppointments.Count -eq 0) {
        Write-Host ""
        Write-Host "    ⚠ NO APPOINTMENTS IN DATABASE!" -ForegroundColor Red
        Write-Host "    This is why technician sees no vehicles!" -ForegroundColor Red
        Write-Host ""
        Write-Host "    Create appointments:" -ForegroundColor Yellow
        Write-Host "      1. Login as customer" -ForegroundColor White
        Write-Host "      2. Go to Appointments tab" -ForegroundColor White
        Write-Host "      3. Fill vehicle details and book" -ForegroundColor White
        Write-Host ""
    } else {
        Write-Host ""
        Write-Host "    Appointments found:" -ForegroundColor Green
        foreach ($apt in $allAppointments) {
            $status = $apt.status
            $statusIcon = if ($status -eq "confirmed") { "✓" } else { "⏳" }
            Write-Host "      $statusIcon ID: $($apt.id.Substring(0,8))..." -ForegroundColor White
            Write-Host "         Registration: $($apt.vehicle_info.registration)" -ForegroundColor Gray
            Write-Host "         Brand: $($apt.vehicle_info.brand) $($apt.vehicle_info.model)" -ForegroundColor Gray
            Write-Host "         Status: $status" -ForegroundColor $(if ($status -eq "confirmed") { "Green" } else { "Yellow" })
            Write-Host "         Date: $($apt.appointment_date)" -ForegroundColor Gray
            Write-Host ""
        }
    }
    
} catch {
    Write-Host "    ✗ Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "    Full error:" -ForegroundColor Red
    Write-Host "    $($_.Exception)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Step 3: Testing Inspection Service..." -ForegroundColor Yellow

try {
    Write-Host "  Test 3a: GET /inspections/vehicles-for-inspection" -ForegroundColor Cyan
    
    $inspectionResponse = Invoke-RestMethod -Uri "http://localhost:8004/inspections/vehicles-for-inspection" `
        -Headers $headers `
        -TimeoutSec 5 `
        -ErrorAction Stop
    
    Write-Host "    ✓ Response received" -ForegroundColor Green
    Write-Host "    Total vehicles: $($inspectionResponse.total_count)" -ForegroundColor Cyan
    Write-Host "    Vehicles array length: $($inspectionResponse.vehicles.Count)" -ForegroundColor Cyan
    
    if ($inspectionResponse.vehicles.Count -eq 0) {
        Write-Host ""
        Write-Host "    ⚠ INSPECTION SERVICE RETURNS EMPTY LIST!" -ForegroundColor Red
        
        if ($allAppointments.Count -gt 0) {
            Write-Host "    BUG IDENTIFIED:" -ForegroundColor Red
            Write-Host "      - Appointments exist in database: $($allAppointments.Count)" -ForegroundColor White
            Write-Host "      - But inspection service returns: 0" -ForegroundColor White
            Write-Host "      - This is the bug preventing vehicles from showing!" -ForegroundColor Yellow
        }
    } else {
        Write-Host ""
        Write-Host "    ✓ Vehicles found!" -ForegroundColor Green
        Write-Host ""
        foreach ($vehicle in $inspectionResponse.vehicles) {
            Write-Host "      Vehicle:" -ForegroundColor White
            Write-Host "        Registration: $($vehicle.vehicle_info.registration)" -ForegroundColor Cyan
            Write-Host "        Brand: $($vehicle.vehicle_info.brand) $($vehicle.vehicle_info.model)" -ForegroundColor Gray
            Write-Host "        Payment: $($vehicle.payment_status_display)" -ForegroundColor $(if ($vehicle.payment_status -eq "confirmed") { "Green" } else { "Yellow" })
            Write-Host "        Inspection: $($vehicle.status_display)" -ForegroundColor Gray
            Write-Host ""
        }
    }
    
    # Show breakdown
    if ($inspectionResponse.by_status) {
        Write-Host "    Status Breakdown:" -ForegroundColor Cyan
        Write-Host "      Not Checked: $($inspectionResponse.by_status.not_checked)" -ForegroundColor White
        Write-Host "      In Progress: $($inspectionResponse.by_status.in_progress)" -ForegroundColor White
        Write-Host "      Passed: $($inspectionResponse.by_status.passed)" -ForegroundColor White
        Write-Host "      Failed: $($inspectionResponse.by_status.failed)" -ForegroundColor White
    }
    
} catch {
    Write-Host "    ✗ Error calling inspection service:" -ForegroundColor Red
    Write-Host "    $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.Exception.Message -like "*403*") {
        Write-Host ""
        Write-Host "    403 FORBIDDEN - Permission error!" -ForegroundColor Yellow
        Write-Host "    User role may not have access to this endpoint" -ForegroundColor Yellow
    }
    
    if ($_.Exception.Message -like "*404*") {
        Write-Host ""
        Write-Host "    404 NOT FOUND - Endpoint doesn't exist!" -ForegroundColor Yellow
        Write-Host "    Check if inspection service is running on port 8004" -ForegroundColor Yellow
    }
    
    if ($_.Exception.Message -like "*500*") {
        Write-Host ""
        Write-Host "    500 SERVER ERROR - Backend error!" -ForegroundColor Yellow
        Write-Host "    Check inspection service logs for details" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Test Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Logged in as: $userEmail" -ForegroundColor White
Write-Host "Appointments in DB: $($allAppointments.Count)" -ForegroundColor White
Write-Host "Vehicles from inspection service: $($inspectionResponse.vehicles.Count)" -ForegroundColor White
Write-Host ""

if ($allAppointments.Count -gt 0 -and $inspectionResponse.vehicles.Count -eq 0) {
    Write-Host "⚠ BUG CONFIRMED!" -ForegroundColor Red
    Write-Host "Appointments exist but inspection service returns empty list" -ForegroundColor Red
    Write-Host ""
    Write-Host "Check inspection service logs for errors" -ForegroundColor Yellow
} elseif ($allAppointments.Count -eq 0) {
    Write-Host "ℹ No bug - just no appointments in database" -ForegroundColor Cyan
    Write-Host "Create appointments via frontend to test" -ForegroundColor Cyan
} else {
    Write-Host "✓ System working correctly!" -ForegroundColor Green
}

Write-Host ""
