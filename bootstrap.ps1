# Windows 向けの完全自動セットアップ(Bootstrap)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = "Stop"

Write-Output "🚀 Windows Bootstrap を開始します..."

# 1. 前提ツールのインストール検証
$requiredApps = @(
    @{ Cmd = 'chezmoi'; Id = 'twpayne.chezmoi' }
    @{ Cmd = 'nu';      Id = 'Nushell.Nushell' }
    @{ Cmd = 'git';     Id = 'Git.Git' }
)

foreach ($app in $requiredApps) {
    if (-not (Get-Command $app.Cmd -ErrorAction SilentlyContinue)) {
        Write-Output "📥 未インストールの $($app.Id) を winget で導入しています..."
        winget install --id $app.Id --exact --silent --accept-package-agreements --accept-source-agreements
    } else {
        Write-Output "✨ $($app.Cmd) は既にインストールされています。"
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
