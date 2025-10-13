# Export VS Code Extensions
Write-Host "Exporting VS Code Extensions..." -ForegroundColor Cyan

# Get list of installed extensions
$extensions = code --list-extensions

# Save to file
$extensions | Out-File "vscode-extensions-list.txt"

Write-Host "[OK] Extensions exported to: vscode-extensions-list.txt" -ForegroundColor Green
Write-Host ""
Write-Host "To install on another machine, run:" -ForegroundColor Yellow
Write-Host "  Get-Content vscode-extensions-list.txt | ForEach-Object { code --install-extension `$_ }" -ForegroundColor Cyan
