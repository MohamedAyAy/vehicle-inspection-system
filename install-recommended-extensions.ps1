# Install Recommended VS Code Extensions for Python/FastAPI Development

Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host "  Installing Recommended VS Code Extensions" -ForegroundColor Yellow
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host ""

$extensions = @(
    "ms-python.python"                    # Python
    "ms-python.vscode-pylance"            # Python language server
    "ms-python.debugpy"                   # Python debugger
    "ms-toolsai.jupyter"                  # Jupyter notebooks
    "donjayamanne.python-environment-manager" # Python env manager
    "VisualStudioExptTeam.vscodeintellicode" # AI-assisted IntelliSense
    "esbenp.prettier-vscode"              # Code formatter
    "dbaeumer.vscode-eslint"              # Linting
    "eamodio.gitlens"                     # Git supercharged
    "mtxr.sqltools"                       # SQL tools
    "mtxr.sqltools-driver-pg"             # PostgreSQL driver for SQL tools
    "humao.rest-client"                   # REST API testing
    "rangav.vscode-thunder-client"        # API client (alternative to Postman)
    "ms-vscode.powershell"                # PowerShell
    "redhat.vscode-yaml"                  # YAML support
    "ms-azuretools.vscode-docker"         # Docker support
    "tamasfe.even-better-toml"            # TOML support
    "wayou.vscode-todo-highlight"         # TODO highlighting
    "PKief.material-icon-theme"           # Better file icons
    "aaron-bond.better-comments"          # Better comment highlighting
)

$total = $extensions.Count
$current = 0

foreach ($ext in $extensions) {
    $current++
    Write-Host "[$current/$total] Installing $ext..." -ForegroundColor Green
    
    # Check if already installed
    $installed = code --list-extensions | Select-String -Pattern "^$ext$"
    
    if ($installed) {
        Write-Host "   [OK] Already installed" -ForegroundColor Yellow
    } else {
        $output = code --install-extension $ext --force 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   [OK] Installed successfully" -ForegroundColor Green
        } else {
            Write-Host "   [ERROR] Failed to install" -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host "  Extension Installation Complete!" -ForegroundColor Green
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Recommended: Restart VS Code to activate all extensions" -ForegroundColor Yellow
Write-Host ""
pause
