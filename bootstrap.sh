#!/bin/bash
# Mac/Linux 向けの完全自動セットアップ(Bootstrap)
set -e

echo "🚀 Unix Bootstrap を開始します..."

# 1. Homebrew の確認
if ! command -v brew >/dev/null 2>&1; then
    echo "❌ brew (Homebrew) が見つかりません。先に Homebrew をインストールしてください。"
    echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

# --- Nushell: GitHub Releases からプリビルトバイナリを直接インストール ---
install_nushell_from_github() {
    echo "📥 GitHub Releases から Nushell プリビルトバイナリをダウンロードします..."

    local arch
    arch="$(uname -m)"
    case "$arch" in
        arm64) arch="aarch64" ;;
    esac

    local os_suffix
    case "$(uname -s)" in
        Darwin) os_suffix="apple-darwin" ;;
        Linux)  os_suffix="unknown-linux-gnu" ;;
        *)      echo "❌ 未対応の OS です"; return 1 ;;
    esac

    # GitHub API から最新リリースのダウンロードURLを取得
    local pattern="${arch}-${os_suffix}.tar.gz"
    local download_url
    download_url="$(curl -sL https://api.github.com/repos/nushell/nushell/releases/latest \
        | grep "browser_download_url.*${pattern}" \
        | head -1 \
        | cut -d '"' -f 4)"

    if [ -z "$download_url" ]; then
        echo "❌ ダウンロードURLが取得できませんでした (pattern: $pattern)"
        return 1
    fi

    echo "   URL: $download_url"
    local tmpdir
    tmpdir="$(mktemp -d)"

    curl -sL "$download_url" | tar xz -C "$tmpdir"

    # nu バイナリを探す (アーカイブ内のディレクトリ構成は版により異なる)
    local nu_bin
    nu_bin="$(find "$tmpdir" -name "nu" -type f -perm +111 | head -1)"
    if [ -z "$nu_bin" ]; then
        # フォールバック: 実行権限チェックなしで探す
        nu_bin="$(find "$tmpdir" -name "nu" -type f | head -1)"
    fi

    if [ -z "$nu_bin" ]; then
        echo "❌ nu バイナリが見つかりませんでした"
        rm -rf "$tmpdir"
        return 1
    fi

    mkdir -p "$HOME/.local/bin"
    cp "$nu_bin" "$HOME/.local/bin/nu"
    chmod +x "$HOME/.local/bin/nu"
    rm -rf "$tmpdir"

    export PATH="$HOME/.local/bin:$PATH"
    echo "✅ Nushell $(nu --version) を ~/.local/bin/nu にインストールしました"
}

# --- formula名 → CLIバイナリ名 (Bash 3.2 互換) ---
get_bin_name() {
    case "$1" in
        nushell) echo "nu" ;;
        *)       echo "$1" ;;
    esac
}

# 2. 依存ツールのインストール
for formula in chezmoi nushell git; do
    bin="$(get_bin_name "$formula")"
    if command -v "$bin" >/dev/null 2>&1; then
        echo "✅ $formula ($bin) は既にインストール済みです"
        continue
    fi

    echo "📥 $formula をインストールしています..."

    # nushell は bottle が無い環境 (macOS 12 等) で cargo ビルドになるため特別扱い
    if [ "$formula" = "nushell" ]; then
        if brew install --no-build-from-source nushell 2>/dev/null; then
            echo "✅ nushell を bottle からインストールしました"
        else
            echo "⚠️  bottle が見つかりません。GitHub Releases からインストールします..."
            install_nushell_from_github
        fi
    else
        brew install "$formula"
    fi
done

# 3. ~/.local/bin を PATH に追加 (GitHub 直接インストールした場合用)
if [ -d "$HOME/.local/bin" ] && ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# 4. リポジトリの初期化
CHEZMOI_DIR="$HOME/.local/share/chezmoi"
if [ ! -d "$CHEZMOI_DIR" ]; then
    echo "📥 chezmoi リポジトリ (c-ardinal/dotfiles) を取得しています..."
    chezmoi init c-ardinal
fi

# 5. Nushell スクリプトへバトンタッチ
cd "$CHEZMOI_DIR"
echo "⚙️ Nushell オーケストレーターに処理を委譲します..."
nu ./dotfiles.nu install
nu ./dotfiles.nu apply

echo "🎉 Bootstrap が完全に終了しました！ 新しいターミナルを開いてください。"
