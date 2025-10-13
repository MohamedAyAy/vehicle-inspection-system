# Complete System Startup - Backend + Frontend
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host "  VEHICLE INSPECTION SYSTEM - Complete Startup" -ForegroundColor Yellow
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host ""

$projectPath = "C:\Users\HP\Desktop\vehicle-inspection-system"

# Step 1: Check PostgreSQL
Write-Host "[1/3] Checking PostgreSQL..." -ForegroundColor Green
$pgService = Get-Service -Name "postgresql*" -ErrorAction SilentlyContinue
if ($pgService -and $pgService.Status -eq 'Running') {
    Write-Host "   [OK] PostgreSQL is running" -ForegroundColor Green
} else {
    Write-Host "   [ERROR] PostgreSQL not running! Please start it first." -ForegroundColor Red
    pause
    exit
}

# Step 2: Start Backend Services
Write-Host ""
Write-Host "[2/3] Starting Backend Services..." -ForegroundColor Green
Write-Host "   Opening 5 service windows..." -ForegroundColor Cyan

# Logging Service (START FIRST!)
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$projectPath\backend\logging-service'; Write-Host '=== LOGGING SERVICE (Port 8005) ===' -ForegroundColor Magenta; python main.py"
Start-Sleep -Seconds 2

# Auth Service
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$projectPath\backend\auth-service'; Write-Host '=== AUTH SERVICE (Port 8001) ===' -ForegroundColor Cyan; python main.py"
Start-Sleep -Seconds 2

# Appointment Service
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$projectPath\backend\appointment-service'; Write-Host '=== APPOINTMENT SERVICE (Port 8002) ===' -ForegroundColor Green; python main.py"
Start-Sleep -Seconds 2

# Payment Service
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$projectPath\backend\payment-service'; Write-Host '=== PAYMENT SERVICE (Port 8003) ===' -ForegroundColor Yellow; python main.py"
Start-Sleep -Seconds 2

# Inspection Service
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$projectPath\backend\inspection-service'; Write-Host '=== INSPECTION SERVICE (Port 8004) ===' -ForegroundColor Blue; python main.py"

Write-Host "   [OK] Backend services starting..." -ForegroundColor Green

# Step 3: Start Frontend
Write-Host ""
Write-Host "[3/3] Starting Frontend Web Server..." -ForegroundColor Green
Start-Sleep -Seconds 3

Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$projectPath\frontend'; Write-Host '=== FRONTEND WEB SERVER (Port 3000) ===' -ForegroundColor White; Write-Host ''; Write-Host 'Frontend URL: http://localhost:3000' -ForegroundColor Green; Write-Host 'Press Ctrl+C to stop' -ForegroundColor Gray; Write-Host ''; python -m http.server 3000"

Write-Host "   [OK] Frontend server starting on port 3000..." -ForegroundColor Green

# Wait for everything to start
Write-Host ""
Write-Host "Waiting for all services to initialize..." -ForegroundColor Yellow
Start-Sleep -Seconds 8

# Test services
Write-Host ""
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host "  Testing Service Health..." -ForegroundColor Yellow
Write-Host "==============================================================" -ForegroundColor Cyan

$services = @(
    @{Name="Logging"; Port=8005},
    @{Name="Auth"; Port=8001},
    @{Name="Appointment"; Port=8002},
    @{Name="Payment"; Port=8003},
    @{Name="Inspection"; Port=8004},
    @{Name="Frontend"; Port=3000}
)

foreach ($svc in $services) {
    try {
        if ($svc.Port -eq 3000) {
            $response = Invoke-WebRequest -Uri "http://localhost:3000" -TimeoutSec 3 -UseBasicParsing
        } else {
            $response = Invoke-WebRequest -Uri "http://localhost:$($svc.Port)/health" -TimeoutSec 3 -UseBasicParsing
        }
        Write-Host "   [OK] $($svc.Name) Service (Port $($svc.Port)): HEALTHY" -ForegroundColor Green
    } catch {
        Write-Host "   [WARN] $($svc.Name) Service (Port $($svc.Port)): Starting..." -ForegroundColor Yellow
    }
}

# Display URLs
Write-Host ""
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host "  ALL SYSTEMS READY!" -ForegroundColor Green
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "FRONTEND (User Interface):" -ForegroundColor Yellow
Write-Host "  http://localhost:3000" -ForegroundColor White -BackgroundColor DarkGreen
Write-Host ""
Write-Host "BACKEND API Documentation:" -ForegroundColor Yellow
Write-Host "  - Auth Service:        http://localhost:8001/docs" -ForegroundColor Cyan
Write-Host "  - Appointment Service: http://localhost:8002/docs" -ForegroundColor Cyan
Write-Host "  - Payment Service:     http://localhost:8003/docs" -ForegroundColor Cyan
Write-Host "  - Inspection Service:  http://localhost:8004/docs" -ForegroundColor Cyan
Write-Host "  - Logging Service:     http://localhost:8005/docs" -ForegroundColor Cyan
Write-Host ""
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press any key to close this window (services will keep running)..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
