# dotfiles

このリポジトリは [chezmoi](https://chezmoi.io/) を使用して dotfiles を管理している。

## セットアップ

新しいデバイスでこの dotfiles を展開する場合は、以下のコマンドを実行する。

### Windows

```powershell
winget install twpayne.chezmoi
chezmoi init --apply c-ardinal
```

### Mac / Linux

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply c-ardinal
```

> **Note:** すでに chezmoi がインストールされている場合は、OS問わず `chezmoi init --apply c-ardinal` を実行する。

---

## チートシート

### 1. リモートの最新の変更を取得して適用する (Pull)

他のPCでPushした変更を、現在のPCに反映させる。

```bash
chezmoi update
```

### 2. 新しいファイルを chezmoi の管理下に追加する

システム上のファイル（例: `~/.zshrc`）を新たに管理対象にする。

```bash
chezmoi add ~/.zshrc
```

### 3. 管理中のファイルを編集する

ファイルの設定を変更したい場合は、対象のファイルを `chezmoi edit` で開いて編集する。

```bash
chezmoi edit ~/.zshrc
```

### 4. 変更の差分を確認する

システムに適用する前に、どのような変更が反映されるかを確認する。

```bash
chezmoi diff
```

### 5. 変更を現在のPCのシステムに適用する

編集した内容を、実体ファイル（ホームディレクトリ等）に反映する。

```bash
chezmoi apply
```

### 6. 変更をリモートリポジトリ(GitHub)へ保存する (Push)

設定を変更・追加したら、GitでコミットしてリモートリポジトリにPushする。

```bash
# chezmoi の管理ディレクトリ (`~/.local/share/chezmoi`) に移動
chezmoi cd

# 通常の Git 操作で保存・プッシュ
git add .
git commit -m "Update dotfiles"
git push

# 管理ディレクトリから抜ける
exit
```
