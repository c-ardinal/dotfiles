# -------------------------------------------------------------
# Custom Completions from nushell/nu_scripts
# Source: https://github.com/nushell/nu_scripts
# Installed at: ~/.local/share/nu_scripts
# -------------------------------------------------------------

const nu_scripts = "~/.local/share/nu_scripts/custom-completions"

# Core tools
use ($nu_scripts | path join "git" "git-completions.nu") *
use ($nu_scripts | path join "npm" "npm-completions.nu") *
use ($nu_scripts | path join "docker" "docker-completions.nu") *
use ($nu_scripts | path join "ssh" "ssh-completions.nu") *
use ($nu_scripts | path join "curl" "curl-completions.nu") *
use ($nu_scripts | path join "rg" "rg-completions.nu") *

# Windows package managers
use ($nu_scripts | path join "winget" "winget-completions.nu") *
