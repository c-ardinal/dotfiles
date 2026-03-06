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
# Homebrew は macOS 12 等の古い OS で bottle を提供しないため、
# cargo ソースビルド (30分) を回避して常にプリビルトバイナリを使用する。
install_nushell() {
    if command -v nu >/dev/null 2>&1; then
        echo "✅ nushell (nu) は既にインストール済みです: $(nu --version)"
        return 0
    fi

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
        *)      echo "❌ 未対応の OS です: $(uname -s)"; return 1 ;;
    esac

    local pattern="${arch}-${os_suffix}.tar.gz"
    echo "   対象バイナリ: *${pattern}"

    local download_url
    download_url="$(curl -sL https://api.github.com/repos/nushell/nushell/releases/latest \
        | grep "browser_download_url.*${pattern}" \
        | head -1 \
        | cut -d '"' -f 4)"

    if [ -z "$download_url" ]; then
        echo "❌ ダウンロードURLが取得できませんでした"
        echo "   手動インストール: https://github.com/nushell/nushell/releases/latest"
        return 1
    fi

    echo "   URL: $download_url"

    local tmpdir
    tmpdir="$(mktemp -d)"
    curl -sL "$download_url" | tar xz -C "$tmpdir"

    # nu バイナリを探す
    local nu_bin
    nu_bin="$(find "$tmpdir" -name "nu" -not -name "nu_*" -type f | head -1)"

    if [ -z "$nu_bin" ]; then
        echo "❌ nu バイナリが見つかりませんでした"
        ls -laR "$tmpdir"
        rm -rf "$tmpdir"
        return 1
    fi

    mkdir -p "$HOME/.local/bin"
    cp "$nu_bin" "$HOME/.local/bin/nu"
    chmod +x "$HOME/.local/bin/nu"
    rm -rf "$tmpdir"

    export PATH="$HOME/.local/bin:$PATH"
    echo "✅ Nushell $($HOME/.local/bin/nu --version) を ~/.local/bin/nu にインストールしました"
}

# 2. 依存ツールのインストール
# chezmoi, git は brew で (bottle 提供あり)
for formula in chezmoi git; do
    if command -v "$formula" >/dev/null 2>&1; then
        echo "✅ $formula は既にインストール済みです"
    else
        echo "📥 $formula をインストールしています..."
        brew install "$formula"
    fi
done

# nushell は専用の関数でインストール (brew の cargo ビルドを回避)
install_nushell

# ~/.local/bin を PATH に追加
if [ -d "$HOME/.local/bin" ] && ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# 3. リポジトリの初期化
CHEZMOI_DIR="$HOME/.local/share/chezmoi"
if [ ! -d "$CHEZMOI_DIR" ]; then
    echo "📥 chezmoi リポジトリ (c-ardinal/dotfiles) を取得しています..."
    chezmoi init c-ardinal
fi

# 4. Nushell スクリプトへバトンタッチ
cd "$CHEZMOI_DIR"
echo "⚙️ Nushell オーケストレーターに処理を委譲します..."
nu ./dotfiles.nu install
nu ./dotfiles.nu apply

echo "🎉 Bootstrap が完全に終了しました！ 新しいターミナルを開いてください。"
