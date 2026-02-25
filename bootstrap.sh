#!/bin/bash
# Mac/Linux 向けの完全自動セットアップ(Bootstrap)
set -e

echo "🚀 Unix Bootstrap を開始します..."

# 1. 依存(Nushell, Chezmoi, Git) のインストール (Homebrew 利用想定)
if ! command -v brew >/dev/null 2>&1; then
    echo "❌ brew (Homebrew) が見つかりません。先に Homebrew をインストールしてください。"
    exit 1
fi

for app in chezmoi nushell git; do
    if ! command -v $app >/dev/null 2>&1; then
        echo "📥 brew $app をインストールしています..."
        brew install $app
    fi
done

# 2. リポジトリの初期化
CHEZMOI_DIR="$HOME/.local/share/chezmoi"
if [ ! -d "$CHEZMOI_DIR" ]; then
    echo "📥 chezmoi リポジトリ (c-ardinal/dotfiles) を取得しています..."
    chezmoi init c-ardinal
fi

# 3. Nushell スクリプトへバトンタッチ
cd "$CHEZMOI_DIR"
echo "⚙️ Nushsell オーケストレーターに処理を委譲します..."
nu ./dotfiles.nu install
nu ./dotfiles.nu apply

echo "🎉 Bootstrap が完全に終了しました！ 新しいターミナルを開いてください。"
