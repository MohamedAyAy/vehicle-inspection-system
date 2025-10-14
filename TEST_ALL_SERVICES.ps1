# Comprehensive Test Script for All Services

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Testing All Services" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Test each service health endpoint
$services = @(
    @{Name="Auth Service"; Port=8001},
    @{Name="Appointment Service"; Port=8002},
    @{Name="Payment Service"; Port=8003},
    @{Name="Inspection Service"; Port=8004},
    @{Name="Logging Service"; Port=8005},
    @{Name="Notification Service"; Port=8006},
    @{Name="File Service"; Port=8007}
)

$allHealthy = $true

foreach ($service in $services) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:$($service.Port)/health" -TimeoutSec 3 -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            Write-Host "  ✓ $($service.Name): Healthy" -ForegroundColor Green
        } else {
            Write-Host "  ✗ $($service.Name): Unhealthy (Status: $($response.StatusCode))" -ForegroundColor Red
            $allHealthy = $false
        }
    } catch {
        Write-Host "  ✗ $($service.Name): NOT RUNNING" -ForegroundColor Red
        $allHealthy = $false
    }
}

Write-Host ""

if ($allHealthy) {
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "All Services Healthy!" -ForegroundColor Green
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "System ready for use at: http://localhost:3000" -ForegroundColor White
} else {
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "Some Services Have Issues" -ForegroundColor Red
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Please check:" -ForegroundColor Yellow
    Write-Host "1. All services are started" -ForegroundColor White
    Write-Host "2. Databases are created" -ForegroundColor White
    Write-Host "3. Dependencies are installed" -ForegroundColor White
}

Write-Host ""
