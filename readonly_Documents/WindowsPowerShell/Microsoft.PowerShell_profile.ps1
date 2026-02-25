# Require UTF-8 encoding in PowerShell output
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Initialize Oh My Posh with the same custom configuration
oh-my-posh init pwsh --config ~/.config/oh-my-posh.json | Invoke-Expression
