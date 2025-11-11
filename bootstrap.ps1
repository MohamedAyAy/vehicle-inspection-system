# Bootstrap script: orchestrates docker setup, waits for Postgres, runs migrations and checks
# Usage: .\bootstrap.ps1

Write-Host "Bootstrap: starting docker setup and migrations" -ForegroundColor Cyan

# Run docker-setup.ps1 which creates .env (if not present), builds, and starts containers
if (Test-Path "docker-setup.ps1") {
    Write-Host "Running docker-setup.ps1" -ForegroundColor Yellow
    & .\docker-setup.ps1
} else {
    Write-Host "docker-setup.ps1 not found, running docker compose build + up" -ForegroundColor Yellow
    docker compose build
    docker compose up -d
}

# Wait for postgres to be healthy
$maxAttempts = 20
$attempt = 0
Write-Host "Waiting for postgres to be ready (this may take 20-60s)" -ForegroundColor Yellow
while ($attempt -lt $maxAttempts) {
    try {
        $status = docker compose exec -T postgres pg_isready -U postgres 2>&1
        if ($status -match "accepting connections") {
            Write-Host "Postgres is ready" -ForegroundColor Green
            break
        }
    } catch {
        # ignore errors, keep waiting
    }
    Start-Sleep -Seconds 3
    $attempt++
}

if ($attempt -ge $maxAttempts) {
    Write-Host "Postgres did not become healthy in time. Check 'docker compose logs postgres'" -ForegroundColor Red
    exit 1
}

# Ensure init SQL has been applied (the compose mounts init-databases.sql into entrypoint). But if you need to force-run it:
if (Test-Path "init-databases.sql") {
    Write-Host "Applying init-databases.sql inside postgres (safe to run)" -ForegroundColor Yellow
    $cid = docker compose ps -q postgres
    if ($cid) {
        docker cp .\init-databases.sql $cid:/tmp/init-databases.sql
        docker compose exec -T postgres psql -U postgres -f /tmp/init-databases.sql
    } else {
        Write-Host "Could not find postgres container id" -ForegroundColor Red
    }
}

# Run migrations for services that include migrate_db.py (best-effort)
$servicesToMigrate = @("payment-service","appointment-service")
foreach ($svc in $servicesToMigrate) {
    Write-Host "Attempting migration for $svc (if migrate_db.py exists)" -ForegroundColor Yellow
    try {
        docker compose exec -T $svc bash -c "if [ -f migrate_db.py ]; then python migrate_db.py; else echo 'no migrate_db.py'; fi"
    } catch {
        Write-Host "Migration command for $svc failed or service not yet ready" -ForegroundColor Yellow
    }
}

# Run admin check (if helper exists)
if (Test-Path "check-admin.ps1") {
    Write-Host "Running admin check" -ForegroundColor Yellow
    & .\check-admin.ps1
}

Write-Host "Bootstrap complete. Check services with: docker compose ps" -ForegroundColor Green
Write-Host "Frontend: http://localhost:3000" -ForegroundColor Cyan
