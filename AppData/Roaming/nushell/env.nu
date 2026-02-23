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
# Starship Prompt Initialization
# -------------------------------------------------------------
mkdir ~/.cache/starship
starship init nu | save -f ~/.cache/starship/init.nu
starship preset catppuccin-powerline -o ~/.config/starship_CatppuccinPowerline.toml
$env.STARSHIP_CONFIG = ("~/.config/starship_CatppuccinPowerline.toml" | path expand)