# Technician Vehicle Visibility Debugging Script

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Debugging Technician Vehicle Visibility" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check if services are running
Write-Host "Step 1: Checking Services..." -ForegroundColor Yellow
$services = @(
    @{Name="Auth"; Port=8001; URL="http://localhost:8001/health"},
    @{Name="Appointment"; Port=8002; URL="http://localhost:8002/health"},
    @{Name="Inspection"; Port=8004; URL="http://localhost:8004/health"}
)

$allRunning = $true
foreach ($service in $services) {
    try {
        $response = Invoke-WebRequest -Uri $service.URL -TimeoutSec 2 -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            Write-Host "  ✓ $($service.Name) Service: Running" -ForegroundColor Green
        }
    } catch {
        Write-Host "  ✗ $($service.Name) Service: NOT RUNNING" -ForegroundColor Red
        $allRunning = $false
    }
}

if (-not $allRunning) {
    Write-Host ""
    Write-Host "ERROR: Not all services are running!" -ForegroundColor Red
    Write-Host "Please start services first using: .\START_AND_TEST.ps1" -ForegroundColor Yellow
    exit
}

Write-Host ""
Write-Host "Step 2: Test Login and Get Token..." -ForegroundColor Yellow

# Test with default technician credentials
$testAccounts = @(
    @{Email="tech@example.com"; Password="Tech1234"; Role="Technician"},
    @{Email="admin@example.com"; Password="Admin123"; Role="Admin"}
)

$token = $null
$testUser = $null

foreach ($account in $testAccounts) {
    Write-Host "  Trying: $($account.Email)..." -ForegroundColor Gray
    try {
        $loginBody = @{
            email = $account.Email
            password = $account.Password
        } | ConvertTo-Json

        $response = Invoke-RestMethod -Uri "http://localhost:8001/login" `
            -Method Post `
            -Body $loginBody `
            -ContentType "application/json" `
            -TimeoutSec 5

        if ($response.access_token) {
            $token = $response.access_token
            $testUser = $account
            Write-Host "  ✓ Login successful as $($account.Role)" -ForegroundColor Green
            break
        }
    } catch {
        Write-Host "  ✗ Login failed for $($account.Email)" -ForegroundColor Gray
    }
}

if (-not $token) {
    Write-Host ""
    Write-Host "ERROR: Could not login with any test account!" -ForegroundColor Red
    Write-Host "Please create a technician account first." -ForegroundColor Yellow
    exit
}

Write-Host ""
Write-Host "Step 3: Check Appointments in Database..." -ForegroundColor Yellow

try {
    $headers = @{
        "Authorization" = "Bearer $token"
    }
    
    # Get all appointments
    $allAppointments = Invoke-RestMethod -Uri "http://localhost:8002/appointments/all" `
        -Headers $headers `
        -TimeoutSec 5
    
    Write-Host "  Total Appointments: $($allAppointments.Count)" -ForegroundColor Cyan
    
    # Get confirmed appointments
    $confirmedAppointments = Invoke-RestMethod -Uri "http://localhost:8002/appointments/all?status=confirmed" `
        -Headers $headers `
        -TimeoutSec 5
    
    Write-Host "  Confirmed Appointments: $($confirmedAppointments.Count)" -ForegroundColor Cyan
    
    if ($allAppointments.Count -eq 0) {
        Write-Host ""
        Write-Host "  ⚠ NO APPOINTMENTS EXIST IN DATABASE" -ForegroundColor Red
        Write-Host "  This is why technician sees no vehicles!" -ForegroundColor Red
        Write-Host ""
        Write-Host "  Solution: Create appointment as customer:" -ForegroundColor Yellow
        Write-Host "    1. Register/Login as customer" -ForegroundColor White
        Write-Host "    2. Click 'Appointments'" -ForegroundColor White
        Write-Host "    3. Fill vehicle details and book" -ForegroundColor White
        Write-Host "    4. Click 'Pay Now' to confirm appointment" -ForegroundColor White
        Write-Host "    5. Then login as technician - vehicles will appear" -ForegroundColor White
        exit
    }
    
    if ($confirmedAppointments.Count -eq 0) {
        Write-Host ""
        Write-Host "  ⚠ NO CONFIRMED APPOINTMENTS" -ForegroundColor Yellow
        Write-Host "  Found $($allAppointments.Count) appointments but NONE are confirmed (paid)" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  Appointment Statuses:" -ForegroundColor Cyan
        foreach ($apt in $allAppointments) {
            Write-Host "    - ID: $($apt.id.Substring(0,8))... Status: $($apt.status)" -ForegroundColor White
        }
        Write-Host ""
        Write-Host "  Solution: Pay for appointments:" -ForegroundColor Yellow
        Write-Host "    1. Login as customer who created appointment" -ForegroundColor White
        Write-Host "    2. Go to 'Your Appointments'" -ForegroundColor White
        Write-Host "    3. Click 'Pay Now' button" -ForegroundColor White
        Write-Host "    4. Confirm payment (simulated)" -ForegroundColor White
        Write-Host "    5. Status will change to 'confirmed'" -ForegroundColor White
        Write-Host "    6. Then technician can see the vehicle" -ForegroundColor White
        exit
    }
    
    Write-Host ""
    Write-Host "  ✓ Found $($confirmedAppointments.Count) confirmed appointment(s)" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Confirmed Appointments Details:" -ForegroundColor Cyan
    foreach ($apt in $confirmedAppointments) {
        Write-Host "    ---" -ForegroundColor Gray
        Write-Host "    ID: $($apt.id)" -ForegroundColor White
        Write-Host "    Registration: $($apt.vehicle_info.registration)" -ForegroundColor White
        Write-Host "    Vehicle: $($apt.vehicle_info.brand) $($apt.vehicle_info.model)" -ForegroundColor White
        Write-Host "    Date: $($apt.appointment_date)" -ForegroundColor White
    }
    
} catch {
    Write-Host "  ✗ Error fetching appointments: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Full Error: $($_.Exception)" -ForegroundColor Red
    exit
}

Write-Host ""
Write-Host "Step 4: Test Inspection Service Endpoint..." -ForegroundColor Yellow

try {
    $vehicles = Invoke-RestMethod -Uri "http://localhost:8004/inspections/vehicles-for-inspection" `
        -Headers $headers `
        -TimeoutSec 5
    
    Write-Host "  ✓ Inspection Service Response Received" -ForegroundColor Green
    Write-Host "  Total Vehicles: $($vehicles.total_count)" -ForegroundColor Cyan
    Write-Host "  Vehicles Array Length: $($vehicles.vehicles.Count)" -ForegroundColor Cyan
    
    if ($vehicles.vehicles.Count -eq 0) {
        Write-Host ""
        Write-Host "  ⚠ INSPECTION SERVICE RETURNS EMPTY LIST" -ForegroundColor Red
        Write-Host "  Even though confirmed appointments exist!" -ForegroundColor Red
        Write-Host ""
        Write-Host "  This indicates a BUG in the inspection service logic" -ForegroundColor Yellow
        Write-Host "  The service is not properly processing confirmed appointments" -ForegroundColor Yellow
    } else {
        Write-Host ""
        Write-Host "  ✓ Vehicles are visible to technician!" -ForegroundColor Green
        Write-Host ""
        Write-Host "  Vehicle List:" -ForegroundColor Cyan
        foreach ($vehicle in $vehicles.vehicles) {
            Write-Host "    ---" -ForegroundColor Gray
            Write-Host "    Appointment ID: $($vehicle.appointment_id)" -ForegroundColor White
            Write-Host "    Registration: $($vehicle.vehicle_info.registration)" -ForegroundColor White
            Write-Host "    Vehicle: $($vehicle.vehicle_info.brand) $($vehicle.vehicle_info.model)" -ForegroundColor White
            Write-Host "    Status: $($vehicle.status) - $($vehicle.status_display)" -ForegroundColor White
            Write-Host "    Can Start: $($vehicle.can_start)" -ForegroundColor White
        }
    }
    
} catch {
    Write-Host "  ✗ Error calling inspection service: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Full Error:" -ForegroundColor Red
    Write-Host "  $($_.Exception)" -ForegroundColor Red
    
    if ($_.Exception.Message -like "*403*") {
        Write-Host ""
        Write-Host "  PERMISSION ERROR: User role may not have access" -ForegroundColor Yellow
        Write-Host "  Current role: $($testUser.Role)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Debugging Complete" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Debug complete. Check output above for issues." -ForegroundColor Cyan
