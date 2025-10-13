# ============================================================
# GitHub Setup & Push Script
# ============================================================

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Vehicle Inspection System - GitHub Setup" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Check if Git is installed
Write-Host "Checking Git installation..." -ForegroundColor Yellow
try {
    $gitVersion = git --version 2>&1
    Write-Host "[OK] Git is installed: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Git is not installed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Git from: https://git-scm.com/download/win" -ForegroundColor Yellow
    Write-Host "After installation, restart PowerShell and run this script again." -ForegroundColor Yellow
    pause
    exit
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Step 1: Create GitHub Repository" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Before continuing, please:" -ForegroundColor Yellow
Write-Host "  1. Go to https://github.com/new" -ForegroundColor White
Write-Host "  2. Create a new repository named: vehicle-inspection-system" -ForegroundColor White
Write-Host "  3. DO NOT initialize with README, .gitignore, or license" -ForegroundColor White
Write-Host "  4. Copy the repository URL (will look like: https://github.com/yourusername/vehicle-inspection-system.git)" -ForegroundColor White
Write-Host ""
Write-Host "Press any key when you're ready to continue..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Step 2: Configure Repository URL" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
$repoUrl = Read-Host "Enter your GitHub repository URL (e.g., https://github.com/username/vehicle-inspection-system.git)"

if ([string]::IsNullOrWhiteSpace($repoUrl)) {
    Write-Host "[ERROR] No repository URL provided. Exiting..." -ForegroundColor Red
    pause
    exit
}

Write-Host "[OK] Repository URL set to: $repoUrl" -ForegroundColor Green

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Step 3: Initialize Git Repository" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Check if already initialized
if (Test-Path ".git") {
    Write-Host "[WARNING] Git repository already initialized" -ForegroundColor Yellow
    $reinit = Read-Host "Do you want to reinitialize? (y/N)"
    if ($reinit -eq "y" -or $reinit -eq "Y") {
        Remove-Item -Recurse -Force ".git"
        git init
        Write-Host "[OK] Git repository reinitialized" -ForegroundColor Green
    }
} else {
    git init
    Write-Host "[OK] Git repository initialized" -ForegroundColor Green
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Step 4: Configure Git User" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

$gitUserName = git config --global user.name 2>&1
$gitUserEmail = git config --global user.email 2>&1

if ([string]::IsNullOrWhiteSpace($gitUserName)) {
    Write-Host "Git user name not configured." -ForegroundColor Yellow
    $userName = Read-Host "Enter your name"
    git config --global user.name "$userName"
    Write-Host "[OK] User name set to: $userName" -ForegroundColor Green
} else {
    Write-Host "[OK] Git user name: $gitUserName" -ForegroundColor Green
}

if ([string]::IsNullOrWhiteSpace($gitUserEmail)) {
    Write-Host "Git user email not configured." -ForegroundColor Yellow
    $userEmail = Read-Host "Enter your email"
    git config --global user.email "$userEmail"
    Write-Host "[OK] User email set to: $userEmail" -ForegroundColor Green
} else {
    Write-Host "[OK] Git user email: $gitUserEmail" -ForegroundColor Green
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Step 5: Stage Files" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Adding all files to Git..." -ForegroundColor Yellow
git add .
Write-Host "[OK] All files staged" -ForegroundColor Green

Write-Host ""
Write-Host "Files to be committed:" -ForegroundColor Cyan
git status --short

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Step 6: Create Initial Commit" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

git commit -m "Initial commit: Vehicle Inspection System with all features implemented"
Write-Host "[OK] Initial commit created" -ForegroundColor Green

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Step 7: Set Default Branch to 'main'" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

git branch -M main
Write-Host "[OK] Default branch set to 'main'" -ForegroundColor Green

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Step 8: Add Remote Origin" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Check if remote already exists
$existingRemote = git remote get-url origin 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "[WARNING] Remote 'origin' already exists: $existingRemote" -ForegroundColor Yellow
    $changeRemote = Read-Host "Do you want to change it to $repoUrl? (y/N)"
    if ($changeRemote -eq "y" -or $changeRemote -eq "Y") {
        git remote set-url origin $repoUrl
        Write-Host "[OK] Remote URL updated" -ForegroundColor Green
    }
} else {
    git remote add origin $repoUrl
    Write-Host "[OK] Remote 'origin' added" -ForegroundColor Green
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Step 9: Push to GitHub" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Pushing to GitHub..." -ForegroundColor Yellow
Write-Host "[WARNING] You may be prompted for GitHub authentication" -ForegroundColor Yellow
Write-Host ""

git push -u origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Green
    Write-Host "  [SUCCESS] Project pushed to GitHub!" -ForegroundColor Green
    Write-Host "============================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Your repository is now available at:" -ForegroundColor Cyan
    Write-Host "  $repoUrl" -ForegroundColor White
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "  1. Visit your GitHub repository" -ForegroundColor White
    Write-Host "  2. Review the README.md for project documentation" -ForegroundColor White
    Write-Host "  3. Share the repository URL with your team" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Red
    Write-Host "  [FAILED] Push Failed!" -ForegroundColor Red
    Write-Host "============================================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Common issues:" -ForegroundColor Yellow
    Write-Host "  1. Authentication failed - Set up GitHub credentials" -ForegroundColor White
    Write-Host "  2. Repository doesn't exist - Create it on GitHub first" -ForegroundColor White
    Write-Host "  3. Wrong URL - Double-check the repository URL" -ForegroundColor White
    Write-Host ""
    Write-Host "For GitHub authentication, you can use:" -ForegroundColor Yellow
    Write-Host "  - GitHub CLI (gh): https://cli.github.com/" -ForegroundColor White
    Write-Host "  - Personal Access Token: https://github.com/settings/tokens" -ForegroundColor White
    Write-Host "  - SSH Keys: https://docs.github.com/en/authentication/connecting-to-github-with-ssh" -ForegroundColor White
    Write-Host ""
}

Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
