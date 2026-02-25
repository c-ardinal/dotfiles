# chezmoi run_once script: Install nushell/nu_scripts
# This script runs once during `chezmoi apply` to clone the nu_scripts repository.

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$nuScriptsDir = Join-Path $env:USERPROFILE ".local\share\nu_scripts"

if (Test-Path $nuScriptsDir) {
    Write-Output "[nu_scripts] Already installed at $nuScriptsDir. Skipping."
} else {
    Write-Output "[nu_scripts] Cloning nushell/nu_scripts..."
    git clone --depth 1 https://github.com/nushell/nu_scripts.git $nuScriptsDir
    if ($LASTEXITCODE -eq 0) {
        Write-Output "[nu_scripts] Successfully installed."
    } else {
        Write-Error "[nu_scripts] Clone failed (exit code: $LASTEXITCODE)."
        exit 1
    }
}
