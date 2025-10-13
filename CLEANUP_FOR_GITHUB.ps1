# ============================================================
# Cleanup Script - Prepare for GitHub Upload
# ============================================================

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Cleanup for GitHub Upload" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

$projectPath = $PSScriptRoot

Write-Host "Cleaning up project at: $projectPath" -ForegroundColor Yellow
Write-Host ""

# Count files before cleanup
$pycacheCount = (Get-ChildItem -Path $projectPath -Recurse -Directory -Filter "__pycache__" -ErrorAction SilentlyContinue).Count
$pycCount = (Get-ChildItem -Path $projectPath -Recurse -File -Filter "*.pyc" -ErrorAction SilentlyContinue).Count
$envCount = (Get-ChildItem -Path $projectPath -Recurse -File -Filter ".env" -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq ".env" }).Count

Write-Host "Found:" -ForegroundColor Yellow
Write-Host "  - $pycacheCount __pycache__ folders" -ForegroundColor White
Write-Host "  - $pycCount .pyc files" -ForegroundColor White
Write-Host "  - $envCount .env files" -ForegroundColor White
Write-Host ""

$confirm = Read-Host "Do you want to delete these files? (y/N)"

if ($confirm -ne "y" -and $confirm -ne "Y") {
    Write-Host "Cleanup cancelled." -ForegroundColor Yellow
    pause
    exit
}

Write-Host ""
Write-Host "Starting cleanup..." -ForegroundColor Yellow
Write-Host ""

# Remove __pycache__ folders
Write-Host "1. Removing __pycache__ folders..." -ForegroundColor Cyan
$removed = 0
Get-ChildItem -Path $projectPath -Recurse -Directory -Filter "__pycache__" -ErrorAction SilentlyContinue | ForEach-Object {
    Remove-Item -Path $_.FullName -Recurse -Force
    $removed++
    Write-Host "   Deleted: $($_.FullName)" -ForegroundColor Gray
}
Write-Host "   ✓ Removed $removed __pycache__ folders" -ForegroundColor Green
Write-Host ""

# Remove .pyc files
Write-Host "2. Removing .pyc files..." -ForegroundColor Cyan
$removed = 0
Get-ChildItem -Path $projectPath -Recurse -File -Filter "*.pyc" -ErrorAction SilentlyContinue | ForEach-Object {
    Remove-Item -Path $_.FullName -Force
    $removed++
}
Write-Host "   ✓ Removed $removed .pyc files" -ForegroundColor Green
Write-Host ""

# Remove .env files (but keep .env.example)
Write-Host "3. Removing .env files (keeping .env.example)..." -ForegroundColor Cyan
$removed = 0
Get-ChildItem -Path $projectPath -Recurse -File -Filter ".env" -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq ".env" } | ForEach-Object {
    Write-Host "   ⚠ Deleting: $($_.FullName)" -ForegroundColor Yellow
    Remove-Item -Path $_.FullName -Force
    $removed++
}
Write-Host "   ✓ Removed $removed .env files" -ForegroundColor Green
Write-Host ""

# Remove venv/env folders if they exist
Write-Host "4. Checking for virtual environment folders..." -ForegroundColor Cyan
$venvFolders = @("venv", "env", ".venv")
$removed = 0
foreach ($folder in $venvFolders) {
    $path = Join-Path $projectPath $folder
    if (Test-Path $path) {
        Write-Host "   Found virtual environment: $folder" -ForegroundColor Yellow
        $removeVenv = Read-Host "   Delete $folder folder? (y/N)"
        if ($removeVenv -eq "y" -or $removeVenv -eq "Y") {
            Remove-Item -Path $path -Recurse -Force
            Write-Host "   ✓ Deleted $folder" -ForegroundColor Green
            $removed++
        }
    }
}
if ($removed -eq 0) {
    Write-Host "   ✓ No virtual environment folders found" -ForegroundColor Green
}
Write-Host ""

# Remove .vscode and .idea folders
Write-Host "5. Checking for IDE settings folders..." -ForegroundColor Cyan
$ideFolders = @(".vscode", ".idea")
$removed = 0
foreach ($folder in $ideFolders) {
    $path = Join-Path $projectPath $folder
    if (Test-Path $path) {
        Remove-Item -Path $path -Recurse -Force
        Write-Host "   ✓ Deleted $folder" -ForegroundColor Green
        $removed++
    }
}
if ($removed -eq 0) {
    Write-Host "   ✓ No IDE settings folders found" -ForegroundColor Green
}
Write-Host ""

# Summary
Write-Host "============================================================" -ForegroundColor Green
Write-Host "  ✓ Cleanup Complete!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Your project is now ready for GitHub upload!" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Use GitHub Desktop (recommended)" -ForegroundColor White
Write-Host "     Download: https://desktop.github.com/" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Or upload via GitHub web interface" -ForegroundColor White
Write-Host "     Go to: https://github.com/new" -ForegroundColor Gray
Write-Host ""
Write-Host "  3. See UPLOAD_TO_GITHUB_MANUAL.md for detailed instructions" -ForegroundColor White
Write-Host ""
Write-Host "⚠ IMPORTANT: Make sure you have .env.example files (these are safe to upload)" -ForegroundColor Yellow
Write-Host ""

pause
