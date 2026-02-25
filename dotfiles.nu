#!/usr/bin/env nu

# Main entry point for dotfiles management
def main [action: string] {
    match $action {
        "install" => { install_apps }
        "apply"   => { apply_env }
        "collect" => { collect_env }
        _         => { print $"Unknown action: ($action). Use 'install', 'apply', or 'collect'." }
    }
}

def install_apps [] {
    print "🚀 アプリケーションのインストールを開始します..."
    let os = $nu.os-info.name

    if $os == 'windows' {
        print "📦 Windowsパッケージ (winget) を確認中..."
        let apps = [
            { cmd: 'wezterm', id: 'wez.wezterm' }
            { cmd: 'oh-my-posh', id: 'JanDeDobbeleer.OhMyPosh' }
        ]
        for app in $apps {
            let check = (which $app.cmd)
            if ($check | is-empty) {
                print $"📥 インストール中: ($app.id)..."
                winget install --id $app.id --exact --silent --accept-package-agreements --accept-source-agreements
            } else {
                print $"✨ ($app.cmd) は既にインストールされています。"
            }
        }
    } else if $os == 'macos' {
        print "📦 macOSパッケージ (Homebrew) を確認中..."
        # 今後の拡張用 (brew install wezterm oh-my-posh 等)
        print "※ まだmacOSの自動インストールは完全に定義されていません"
    } else if $os == 'linux' {
        print "📦 Linux環境です。手動で必要なパッケージを入れるか、将来的こに追加してください"
    }

    # 共通処理: nu_scripts のクローン
    let nu_scripts_dir = ($nu.home-path | path join ".local" "share" "nu_scripts")
    if not ($nu_scripts_dir | path exists) {
        print "📦 nushell/nu_scripts をクローンしています..."
        git clone --depth 1 https://github.com/nushell/nu_scripts.git $nu_scripts_dir
    } else {
        print "✨ nushell/nu_scripts は既にクローンされています。"
    }

    print "✅ インストール完了！"
}

def apply_env [] {
    print "🚀 環境の適用 (Apply) を開始します..."
    
    let os = $nu.os-info.name
    if $os == 'windows' {
        print "📦 PSReadLineモジュールをチェック/更新しています (Windows専用処理)..."
        # PowerShell5.1のOMPクラッシュ対策
        ^powershell -NoProfile -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser -ErrorAction SilentlyContinue | Out-Null; Install-Module -Name PSReadLine -Force -SkipPublisherCheck -Scope CurrentUser -ErrorAction SilentlyContinue"
    }

    print "⚙️ chezmoi apply を実行中..."
    chezmoi apply

    print "✅ Apply が完了しました！"
}

def collect_env [] {
    print "📥 環境の収集 (Collect) を開始します..."
    print "⚙️ chezmoi re-add を実行中..."
    
    # 差分や追跡ファイルを安全にループ処理して re-add
    let files = (chezmoi managed --include=files | lines | where ($it | is-not-empty))
    
    for file in $files {
        print $"  -> collect: ($file)"
        let abs_path = ($nu.home-path | path join $file)
        if ($abs_path | path exists) {
            chezmoi re-add $abs_path
        } else {
            print $"[警告] ファイルが見つかりません: ($abs_path)"
        }
    }

    print "✅ Collect が完了しました！"
    print "差分は 'chezmoi diff' で確認し、'chezmoi cd' から git commit / push を行ってください。"
}
