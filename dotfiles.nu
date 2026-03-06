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
        let brew_apps = [
            { cmd: 'wezterm', formula: 'wezterm' }
            { cmd: 'oh-my-posh', formula: 'oh-my-posh' }
        ]
        for app in $brew_apps {
            let check = (which $app.cmd)
            if ($check | is-empty) {
                print $"📥 brew install ($app.formula)..."
                brew install $app.formula
            } else {
                print $"✨ ($app.cmd) は既にインストールされています。"
            }
        }
    } else if $os == 'linux' {
        print "📦 Linux環境です。手動で必要なパッケージを入れるか、将来的に追加してください"
    }

    # 共通処理: nu_scripts のクローン
    let nu_scripts_dir = (("~" | path expand) | path join ".local" "share" "nu_scripts")
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
        ^powershell -NoProfile -Command "$ProgressPreference = 'SilentlyContinue'; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser -ErrorAction SilentlyContinue -WarningAction SilentlyContinue | Out-Null; Install-Module -Name PSReadLine -Force -SkipPublisherCheck -Scope CurrentUser -ErrorAction SilentlyContinue -WarningAction SilentlyContinue"
    }

    print "⚙️ chezmoi apply を実行中..."
    chezmoi apply --force

    # Oh My Posh init.nu を生成 (macOS/Linux)
    if $os != 'windows' {
        generate_omp_init
    }

    print "✅ Apply が完了しました！"
}

# Oh My Posh init.nu を生成して Nushell vendor/autoload に配置
def generate_omp_init [] {
    let omp_check = (which oh-my-posh)
    if ($omp_check | is-empty) {
        print "⚠️  oh-my-posh が見つかりません。スキップします。"
        return
    }

    let config_path = ("~/.config/oh-my-posh.json" | path expand)
    if not ($config_path | path exists) {
        print $"⚠️  OMP 設定ファイルが見つかりません: ($config_path)"
        return
    }

    # Nushell config ディレクトリを特定
    let nu_config_dir = $nu.default-config-dir
    let output_dir = ($nu_config_dir | path join "vendor" "autoload")
    let output_file = ($output_dir | path join "oh-my-posh.nu")

    mkdir $output_dir

    print $"⚙️ oh-my-posh init.nu を生成しています..."
    let config_safe = ($config_path | str replace --all '\' '/')
    let raw_script = (oh-my-posh init nu --config $config_path --print)
    let init_script = $'$env.POSH_THEME = "($config_safe)"' + "\n" + $raw_script

    $init_script | save -f $output_file
    print $"✅ Oh My Posh init.nu を生成しました: ($output_file)"
}

def collect_env [] {
    print "📥 環境の収集 (Collect) を開始します..."
    print "⚙️ chezmoi re-add を実行中..."
    
    # 差分や追跡ファイルを安全にループ処理して re-add
    let files = (chezmoi managed --include=files | lines | where ($it | is-not-empty))
    
    for file in $files {
        print $"  -> collect: ($file)"
        let abs_path = (("~" | path expand) | path join $file)
        if ($abs_path | path exists) {
            chezmoi re-add $abs_path
        } else {
            print $"[警告] ファイルが見つかりません: ($abs_path)"
        }
    }

    print "✅ Collect が完了しました！"
    print "差分は 'chezmoi diff' で確認し、'chezmoi cd' から git commit / push を行ってください。"
}
