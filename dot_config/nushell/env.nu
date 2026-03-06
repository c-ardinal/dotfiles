# env.nu
#
# Installed by:
# version = "0.110.0"
#
# Previously, environment variables were typically configured in `env.nu`.
# In general, most configuration can and should be performed in `config.nu`
# or one of the autoload directories.
#
# This file is generated for backwards compatibility for now.
# It is loaded before config.nu and login.nu
#
# See https://www.nushell.sh/book/configuration.html
#
# Also see `help config env` for more options.
#
# You can remove these comments if you want or leave
# them for future reference.

# -------------------------------------------------------------
# Oh My Posh Prompt Initialization
# -------------------------------------------------------------
$env.POSH_THEME = ("~/.config/oh-my-posh.json" | path expand)
# To regenerate init.nu after config changes, run:
#   oh-my-posh init nu --config ~/.config/oh-my-posh.json --print | save -f ($nu.default-config-dir | path join "vendor/autoload/oh-my-posh.nu")
