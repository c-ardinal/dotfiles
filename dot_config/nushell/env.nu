# env.nu
#
# macOS/Linux 用 (chezmoi: dot_config/nushell/env.nu)

# -------------------------------------------------------------
# PATH 追加 (GUI起動時にPATHが最小限になる問題の対策)
# -------------------------------------------------------------
$env.PATH = ($env.PATH | split row (char esep)
    | prepend [
        ($env.HOME | path join ".local" "bin")       # GitHub Releases直接DL先
        "/opt/homebrew/bin"                           # macOS (Apple Silicon) Homebrew
        "/usr/local/bin"                              # macOS (Intel) Homebrew / Linux
    ]
    | uniq)

# -------------------------------------------------------------
# Oh My Posh Prompt Initialization
# -------------------------------------------------------------
$env.POSH_THEME = ("~/.config/oh-my-posh.json" | path expand)
# To regenerate init.nu after config changes, run:
#   oh-my-posh init nu --config ~/.config/oh-my-posh.json --print | save -f ($nu.default-config-dir | path join "vendor/autoload/oh-my-posh.nu")

