# Vehicle Inspection System - Startup and Testing Script
# This script helps you start all services and test the system

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Vehicle Inspection System v2.0" -ForegroundColor Cyan
Write-Host "Startup and Testing Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Function to test if a port is in use
function Test-Port {
    param($Port)
    $connection = Test-NetConnection -ComputerName localhost -Port $Port -InformationLevel Quiet -WarningAction SilentlyContinue
    return $connection
}

# Function to start a service in a new window
function Start-Service {
    param($Name, $Path, $Port)
    
    Write-Host "Starting $Name on port $Port..." -ForegroundColor Yellow
    
    if (Test-Port -Port $Port) {
        Write-Host "  ⚠ Port $Port is already in use. Service may already be running." -ForegroundColor Red
        return $false
    }
    
    $scriptBlock = "cd '$Path'; python main.py"
    Start-Process powershell -ArgumentList "-NoExit", "-Command", $scriptBlock -WindowStyle Normal
    Start-Sleep -Seconds 2
    return $true
}

# Get the current directory
$baseDir = $PSScriptRoot

Write-Host "Step 1: Starting Backend Services..." -ForegroundColor Green
Write-Host "-------------------------------------" -ForegroundColor Green

# Start all backend services
$services = @(
    @{Name="Auth Service"; Path="$baseDir\backend\auth-service"; Port=8001},
    @{Name="Appointment Service"; Path="$baseDir\backend\appointment-service"; Port=8002},
    @{Name="Payment Service"; Path="$baseDir\backend\payment-service"; Port=8003},
    @{Name="Inspection Service"; Path="$baseDir\backend\inspection-service"; Port=8004},
    @{Name="Logging Service"; Path="$baseDir\backend\logging-service"; Port=8005}
)

foreach ($service in $services) {
    Start-Service -Name $service.Name -Path $service.Path -Port $service.Port
}

Write-Host ""
Write-Host "Step 2: Starting Frontend..." -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor Green

if (Test-Port -Port 3000) {
    Write-Host "  ⚠ Port 3000 is already in use. Frontend may already be running." -ForegroundColor Red
} else {
    Write-Host "Starting Frontend on port 3000..." -ForegroundColor Yellow
    $scriptBlock = "cd '$baseDir\frontend'; python -m http.server 3000"
    Start-Process powershell -ArgumentList "-NoExit", "-Command", $scriptBlock -WindowStyle Normal
    Start-Sleep -Seconds 2
}

Write-Host ""
Write-Host "Step 3: Waiting for services to initialize..." -ForegroundColor Green
Write-Host "-----------------------------------------------" -ForegroundColor Green
Start-Sleep -Seconds 5

Write-Host ""
Write-Host "Step 4: Testing Service Health..." -ForegroundColor Green
Write-Host "-----------------------------------" -ForegroundColor Green

$healthEndpoints = @(
    @{Name="Auth Service"; URL="http://localhost:8001/health"},
    @{Name="Appointment Service"; URL="http://localhost:8002/health"},
    @{Name="Payment Service"; URL="http://localhost:8003/health"},
    @{Name="Inspection Service"; URL="http://localhost:8004/health"},
    @{Name="Logging Service"; URL="http://localhost:8005/health"}
)

$allHealthy = $true

foreach ($endpoint in $healthEndpoints) {
    try {
        $response = Invoke-WebRequest -Uri $endpoint.URL -TimeoutSec 3 -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            Write-Host "  ✓ $($endpoint.Name): Healthy" -ForegroundColor Green
        } else {
            Write-Host "  ✗ $($endpoint.Name): Unhealthy (Status: $($response.StatusCode))" -ForegroundColor Red
            $allHealthy = $false
        }
    } catch {
        Write-Host "  ✗ $($endpoint.Name): Not responding" -ForegroundColor Red
        $allHealthy = $false
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Service Status Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if ($allHealthy) {
    Write-Host "✓ All services are running!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next Steps:" -ForegroundColor Yellow
    Write-Host "1. Open your browser: http://localhost:3000" -ForegroundColor White
    Write-Host "2. Register a new account (all fields are optional)" -ForegroundColor White
    Write-Host "3. Login and test the system" -ForegroundColor White
    Write-Host ""
    Write-Host "Default Admin Credentials (if created):" -ForegroundColor Yellow
    Write-Host "  Email: admin@example.com" -ForegroundColor White
    Write-Host "  Password: Admin123" -ForegroundColor White
    Write-Host ""
    Write-Host "Browser opening in 3 seconds..." -ForegroundColor Yellow
    Start-Sleep -Seconds 3
    Start-Process "http://localhost:3000"
} else {
    Write-Host "⚠ Some services failed to start!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "1. Check if PostgreSQL is running" -ForegroundColor White
    Write-Host "2. Verify database credentials in .env files" -ForegroundColor White
    Write-Host "3. Check service terminal windows for errors" -ForegroundColor White
    Write-Host "4. Ensure ports 8001-8005 and 3000 are available" -ForegroundColor White
}

Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
