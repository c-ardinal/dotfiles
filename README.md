# dotfiles

このリポジトリは [chezmoi](https://chezmoi.io/) を使用して dotfiles を管理している。

## セットアップ

新しいデバイスでこの dotfiles を展開する場合、OS ごとに以下の 1 コマンドを実行するだけで、必要なツールのインストールから設定まで全て全自動で行う。

### Windows

```powershell
$ProgressPreference = 'SilentlyContinue'; Invoke-RestMethod -Uri "https://raw.githubusercontent.com/c-ardinal/dotfiles/refs/heads/main/bootstrap.ps1" | Invoke-Expression
```

### Mac / Linux

```bash
curl -fsLS https://raw.githubusercontent.com/c-ardinal/dotfiles/refs/heads/main/bootstrap.sh | bash
```

---

## 統合管理スクリプト (`dotfiles.nu`) について

OS ごとの差異を吸収するため、インストール・適用・収集のロジックはすべて **Nushell** のスクリプト (`dotfiles.nu`) に一元化する。

どの OS からでも、`nu dotfiles.nu <action>` を実行するだけで共通の管理が可能。

### 1. アプリケーション・依存ファイルのインストール

WezTerm, Oh My Posh などの依存アプリケーションが未インストールの場合は一括インストールを実行。
加えて、`PSReadLine` の自動アップデート処理や `nu_scripts` のクローンなどもこの段階で行う。

```bash
nu dotfiles.nu install
```

### 2. 環境の適用 (Apply)

chezmoi を使用して設定ファイルを配置・同期します。

```bash
nu dotfiles.nu apply
```

### 3. 環境の収集 (Collect)

管理対象となっている各設定ファイルの最新の実体を、chezmoi のリポジトリ内に安全に再収集(`re-add`)します。

```bash
nu dotfiles.nu collect
```

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
