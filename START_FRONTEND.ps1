# Start Frontend Web Server
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host "  VEHICLE INSPECTION SYSTEM - Frontend Server" -ForegroundColor Yellow
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host ""

$frontendPath = "C:\Users\HP\Desktop\vehicle-inspection-system\frontend"
$port = 3000

Write-Host "Starting frontend web server on port $port..." -ForegroundColor Green
Write-Host "Frontend path: $frontendPath" -ForegroundColor Cyan
Write-Host ""

# Check if Python is available
$pythonVersion = python --version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Python not found!" -ForegroundColor Red
    pause
    exit
}

Write-Host "[OK] Found $pythonVersion" -ForegroundColor Green
Write-Host ""
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host "  Frontend will be available at:" -ForegroundColor Yellow
Write-Host "  http://localhost:$port" -ForegroundColor Green
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Gray
Write-Host ""

# Start Python HTTP server
Set-Location $frontendPath
python -m http.server $port
