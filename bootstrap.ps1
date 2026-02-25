# Windows 向けの完全自動セットアップ(Bootstrap)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = "Stop"

Write-Output "🚀 Windows Bootstrap を開始します..."

# 1. 前提ツールのインストール検証
foreach ($app in @("twpayne.chezmoi", "Nushell.Nushell", "Git.Git")) {
    $check = winget list --id $app --exact 2>$null | Out-String
    if (-not ($check -match $app)) {
        Write-Output "📥 未インストールの $app を winget で導入しています..."
        winget install --id $app --exact --silent --accept-package-agreements --accept-source-agreements
    }
}

# インストールしたばかりの Nushell/Git へのパスを現在のセッションに反映
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# 2. リポジトリの初期化
$chezmoiDir = Join-Path $env:USERPROFILE ".local\share\chezmoi"
if (-not (Test-Path $chezmoiDir)) {
    Write-Output "📥 chezmoi リポジトリ (c-ardinal/dotfiles) を取得しています..."
    chezmoi init c-ardinal
}

# 3. リポジトリ内の dotfiles.nu にバトンを渡してセットアップ実行
Set-Location $chezmoiDir
Write-Output "⚙️ Nushsell オーケストレーターに処理を委譲します..."
nu .\dotfiles.nu install
nu .\dotfiles.nu apply

Write-Output "🎉 Bootstrap が完全に終了しました！ 新しいターミナルを開いてください。"
