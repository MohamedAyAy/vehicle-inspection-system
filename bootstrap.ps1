# Bootstrap script: orchestrates docker setup, waits for Postgres, runs migrations and checks
# Usage: .\bootstrap.ps1 [-ProjectName <string>]

Param(
    [string]$ProjectName = ""
)

if (-not $ProjectName) {
    # default base project name (can be overridden by caller)
    $ProjectName = "vehicle-inspection"
}

function Get-UniqueProjectName($base) {
    # generate a short random suffix (alphanumeric) to avoid collisions
    $chars = ((65..90) + (97..122) + (48..57))
    $suffix = -join (1..4 | ForEach-Object { [char]($chars | Get-Random) })
    return "$base-$suffix"
}

Write-Host "Bootstrap: starting docker setup and migrations" -ForegroundColor Cyan
Write-Host "Requested COMPOSE_PROJECT_NAME (base): $ProjectName" -ForegroundColor Cyan

# Normalize Dockerfile names: some copies mistakenly use 'DockerFile' (capital F).
# Docker expects 'Dockerfile' by convention; some environments are case-sensitive.
Write-Host "Checking for non-standard Dockerfile names (DockerFile) and normalizing..." -ForegroundColor Yellow
$badFiles = Get-ChildItem -Path . -Recurse -Filter "DockerFile" -File -ErrorAction SilentlyContinue
if ($badFiles) {
    foreach ($bf in $badFiles) {
        $newPath = Join-Path $bf.DirectoryName "Dockerfile"
        if (-not (Test-Path $newPath)) {
            Write-Host "Renaming $($bf.FullName) -> $newPath" -ForegroundColor Cyan
            Rename-Item -Path $bf.FullName -NewName "Dockerfile"
        } else {
            Write-Host "Target Dockerfile already exists at $newPath; skipping rename of $($bf.FullName)" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "No non-standard Dockerfile names found." -ForegroundColor Green
}

# Before running any compose steps, set the COMPOSE_PROJECT_NAME to avoid collisions.
$env:COMPOSE_PROJECT_NAME = $ProjectName

# If a container that would conflict with "$env:COMPOSE_PROJECT_NAME-postgres" already exists,
# switch to a generated unique project name (non-destructive).
$conflictName = "$env:COMPOSE_PROJECT_NAME-postgres"
try {
    $existing = docker ps -a --filter "name=$conflictName" --format "{{.Names}}" 2>$null
} catch {
    $existing = ""
}
if ($existing) {
    # Use subexpression to avoid PowerShell parsing errors when a variable is adjacent to punctuation
    Write-Host "Detected existing container(s) matching $($conflictName): $($existing)" -ForegroundColor Yellow
    Write-Host "Auto-generating a unique COMPOSE_PROJECT_NAME to avoid conflict..." -ForegroundColor Yellow
    $unique = Get-UniqueProjectName $ProjectName
    Write-Host "Switching to project name: $($unique)" -ForegroundColor Cyan
    $env:COMPOSE_PROJECT_NAME = $unique
}

# Run docker-setup.ps1 which creates .env (if not present), builds, and starts containers
if (Test-Path "docker-setup.ps1") {
    Write-Host "Running docker-setup.ps1 (COMPOSE_PROJECT_NAME=$env:COMPOSE_PROJECT_NAME)" -ForegroundColor Yellow
    & .\docker-setup.ps1
} else {
    Write-Host "docker-setup.ps1 not found, running docker compose build + up" -ForegroundColor Yellow
    docker compose build
    docker compose up -d
}

# Quick check: is Docker daemon available?
Write-Host "Checking Docker daemon availability..." -ForegroundColor Yellow
docker info > $null 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Docker daemon is not reachable. Please start Docker Desktop (or the Docker daemon) and retry." -ForegroundColor Red
    exit 1
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
        # Use an explicit string expansion to avoid PowerShell interpreting $cid:/... as an invalid variable reference
        $target = "$($cid):/tmp/init-databases.sql"
        docker cp .\init-databases.sql $target
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
