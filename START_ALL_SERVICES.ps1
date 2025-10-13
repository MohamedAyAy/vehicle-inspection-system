# PowerShell Script to Start All Microservices
# Run this script to start all services in separate windows

Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host "  VEHICLE INSPECTION SYSTEM - Service Starter" -ForegroundColor Yellow
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host ""

# Check if PostgreSQL is running
Write-Host "[1/6] Checking PostgreSQL status..." -ForegroundColor Green
$pgService = Get-Service -Name "postgresql*" -ErrorAction SilentlyContinue
if ($pgService -eq $null) {
    Write-Host "   WARNING: PostgreSQL service not found! Please install PostgreSQL first." -ForegroundColor Red
    Write-Host "   Download from: https://www.postgresql.org/download/windows/" -ForegroundColor Yellow
    pause
    exit
} elseif ($pgService.Status -ne 'Running') {
    Write-Host "   PostgreSQL is not running. Attempting to start..." -ForegroundColor Yellow
    try {
        Start-Service -Name $pgService.Name -ErrorAction Stop
        Write-Host "   [OK] PostgreSQL started successfully" -ForegroundColor Green
    } catch {
        Write-Host "   [ERROR] Could not start PostgreSQL. Please start it manually." -ForegroundColor Red
        pause
        exit
    }
} else {
    Write-Host "   [OK] PostgreSQL is running" -ForegroundColor Green
}

# Check if databases exist
Write-Host "[2/6] Checking databases..." -ForegroundColor Green
$env:PGPASSWORD = "azerty5027"
$dbCheck = & "psql" -U postgres -h localhost -lqt 2>&1 | Select-String -Pattern "auth_db|appointments_db|payments_db|inspections_db|logs_db"
if ($dbCheck) {
    Write-Host "   [OK] Databases found" -ForegroundColor Green
} else {
    Write-Host "   [WARNING] Some databases may be missing. Creating them..." -ForegroundColor Yellow
    Write-Host "   Please ensure PostgreSQL credentials are correct in .env file" -ForegroundColor Yellow
}

# Change to project directory
$projectPath = "C:\Users\HP\Desktop\vehicle-inspection-system"
Set-Location $projectPath

Write-Host "[3/6] Checking Python and dependencies..." -ForegroundColor Green
# Check Python version
$pythonVersion = python --version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "   [ERROR] Python not found. Please install Python 3.9+" -ForegroundColor Red
    pause
    exit
}
Write-Host "   [OK] Found $pythonVersion" -ForegroundColor Green

# Start services in separate windows
Write-Host "[4/6] Starting Logging Service..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$projectPath\backend\logging-service'; Write-Host '=== LOGGING SERVICE (Port 8005) ===' -ForegroundColor Magenta; python main.py"
Start-Sleep -Seconds 2

Write-Host "[5/6] Starting Core Services..." -ForegroundColor Green

Write-Host "   - Auth Service (Port 8001)..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$projectPath\backend\auth-service'; Write-Host '=== AUTH SERVICE (Port 8001) ===' -ForegroundColor Cyan; python main.py"
Start-Sleep -Seconds 2

Write-Host "   - Appointment Service (Port 8002)..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$projectPath\backend\appointment-service'; Write-Host '=== APPOINTMENT SERVICE (Port 8002) ===' -ForegroundColor Green; python main.py"
Start-Sleep -Seconds 2

Write-Host "   - Payment Service (Port 8003)..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$projectPath\backend\payment-service'; Write-Host '=== PAYMENT SERVICE (Port 8003) ===' -ForegroundColor Yellow; python main.py"
Start-Sleep -Seconds 2

Write-Host "   - Inspection Service (Port 8004)..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$projectPath\backend\inspection-service'; Write-Host '=== INSPECTION SERVICE (Port 8004) ===' -ForegroundColor Blue; python main.py"

Write-Host "[6/6] Waiting for services to start..." -ForegroundColor Green
Start-Sleep -Seconds 8

# Check if services are responding
Write-Host ""
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host "  Testing Service Health..." -ForegroundColor Yellow
Write-Host "==============================================================" -ForegroundColor Cyan

$services = @(
    @{Name="Logging Service"; URL="http://localhost:8005/health"},
    @{Name="Auth Service"; URL="http://localhost:8001/health"},
    @{Name="Appointment Service"; URL="http://localhost:8002/health"},
    @{Name="Payment Service"; URL="http://localhost:8003/health"},
    @{Name="Inspection Service"; URL="http://localhost:8004/health"}
)

foreach ($service in $services) {
    try {
        $response = Invoke-WebRequest -Uri $service.URL -TimeoutSec 5 -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            Write-Host "   [OK] $($service.Name): HEALTHY" -ForegroundColor Green
        } else {
            Write-Host "   [WARN] $($service.Name): Response code $($response.StatusCode)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "   [ERROR] $($service.Name): NOT RESPONDING" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host "  All services have been started!" -ForegroundColor Green
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "API Documentation URLs:" -ForegroundColor Yellow
Write-Host "  - Auth Service:        http://localhost:8001/docs" -ForegroundColor Cyan
Write-Host "  - Appointment Service: http://localhost:8002/docs" -ForegroundColor Cyan
Write-Host "  - Payment Service:     http://localhost:8003/docs" -ForegroundColor Cyan
Write-Host "  - Inspection Service:  http://localhost:8004/docs" -ForegroundColor Cyan
Write-Host "  - Logging Service:     http://localhost:8005/docs" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press any key to keep this window open..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
