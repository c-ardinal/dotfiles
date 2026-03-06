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

# 2. 依存ツールのインストール
# formula名 → CLIバイナリ名のマッピング (Bash 3.2 互換: case文で実装)
get_bin_name() {
    case "$1" in
        nushell) echo "nu" ;;
        *)       echo "$1" ;;
    esac
}

for formula in chezmoi nushell git; do
    bin="$(get_bin_name "$formula")"
    if command -v "$bin" >/dev/null 2>&1; then
        echo "✅ $formula ($bin) は既にインストール済みです"
    else
        echo "📥 $formula をインストールしています..."
        # ソースビルド(cargo install等)を回避し、プリビルトbottleのみ使用
        if ! brew install --no-build-from-source "$formula" 2>/dev/null; then
            echo "⚠️  bottle が見つかりません。通常の brew install を試みます..."
            brew install "$formula"
        fi
    fi
done

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

