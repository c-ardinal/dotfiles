
-- 参考サイト
-- a24k氏, 年頭にあたり Ghostty と WezTerm を試す, https://zenn.dev/a24k/articles/20260110-ghostty-wezterm
-- CoralPink氏, Commentary of Dotfiles, https://coralpink.github.io/commentary/index.html
-- ナミレリ氏, 【Mac】WezTermで快適なターミナル体験, https://namileriblog.com/mac/wezterm/

local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- OS判定ヘルパー (wezterm.target_triple によるランタイム判定)
local is_windows = wezterm.target_triple:find('windows') ~= nil
local is_macos   = wezterm.target_triple:find('apple')   ~= nil
local is_linux   = (not is_windows) and (not is_macos)

-- ==========================================
-- 1. 基本設定 (Basic Settings)
-- ==========================================
-- フォント設定(英語フォント + 日本語フォントのフォールバック)
config.font = wezterm.font_with_fallback({
  'JetBrains Mono',
  is_macos and 'Hiragino Sans' or 'Meiryo',  -- macOS: ヒラギノ, Windows: メイリオ
})
config.font_size = 10.0
-- 日本語入力(IME)を有効化
config.use_ime = true
-- Leaderキーなどを押したときに即座にステータスバー(右上のインジケータ等)へ反映させるための更新頻度設定
config.status_update_interval = 100
-- デフォルトシェルを NuShell に設定
-- macOS の GUI アプリは PATH が最小限 (/usr/bin:/bin 等) なので、フルパスで指定する
if is_windows then
  config.default_prog = { 'nu' }
else
  local nu_candidates = {
    wezterm.home_dir .. '/.local/bin/nu',
    '/opt/homebrew/bin/nu',   -- macOS (Apple Silicon) Homebrew
    '/usr/local/bin/nu',      -- macOS (Intel) Homebrew / Linux
    '/usr/bin/nu',            -- Linux パッケージマネージャ
  }
  for _, path in ipairs(nu_candidates) do
    local f = io.open(path, 'r')
    if f then
      f:close()
      config.default_prog = { path }
      break
    end
  end
  -- 見つからない場合は default_prog を設定せず、システムデフォルトシェルを使用
end
-- カーソルを点滅する縦線に設定
config.default_cursor_style = "BlinkingBar"
-- 起動時のカレントディレクトリ (OS別)
config.default_cwd = is_windows and '/_Workspace' or (wezterm.home_dir .. '/workspace')
-- スクロールバックバッファを増量 (デフォルト3500行)
config.scrollback_lines = 10000
-- ペイン切替時にズーム状態を自動解除
config.unzoom_on_switch_pane = true
-- bold文字でANSI色を明るくしない (色の一貫性を保つ)
config.bold_brightens_ansi_colors = false
-- URL自動検出のハイライト
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- ==========================================
-- 2. ウィンドウと外観 (Window & Appearance)
-- ==========================================
config.color_scheme = 'Dracula+'
config.text_background_opacity = 1.0
config.window_background_opacity = 0.9
config.window_decorations = "TITLE | RESIZE"
config.window_padding = {
  left = '1cell', right = '1cell',
  top = '0.5cell', bottom = '0.5cell',
}
config.window_frame = {
    border_left_width = '1',
    border_right_width = '1',
    border_bottom_height = '1',
    border_top_height = '1',
    border_left_color = '#5A7DFF',
    border_right_color = '#5A7DFF',
    border_bottom_color = '#5A7DFF',
    border_top_color = '#5A7DFF',
}
-- 非アクティブペインを暗くして視覚的に区別
config.inactive_pane_hsb = {
  saturation = 0.7,
  brightness = 0.6,
}

-- ==========================================
-- 3. タブバーの設定 (Tab bar)
-- ==========================================
config.hide_tab_bar_if_only_one_tab = false
config.tab_and_split_indices_are_zero_based = true
config.use_fancy_tab_bar = true
config.switch_to_last_active_tab_when_closing_tab = true
config.tab_bar_at_bottom = true

-- ==========================================
-- 4. マルチプレクサ (タブ・ペイン) のキーバインド
-- ==========================================
-- tmuxのように `Ctrl + b` をプレフィックスキー (Leader key) に設定
config.leader = { key = 'b', mods = 'CTRL', timeout_milliseconds = 1000 }
config.keys = {
  -- [ ペインの分割 ]
  -- Ctrl+b を押した後、 - で上下分割
  { key = '-', mods = 'LEADER', action = wezterm.action.SplitVertical{ domain = 'CurrentPaneDomain' } },
  -- Ctrl+b を押した後、 \ で左右分割
  { key = '\\', mods = 'LEADER', action = wezterm.action.SplitHorizontal{ domain = 'CurrentPaneDomain' } },
  
  -- [ ペイン間の移動 ] (Vimライクな hjkl)
  { key = 'h', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection('Left') },
  { key = 'j', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection('Down') },
  { key = 'k', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection('Up') },
  { key = 'l', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection('Right') },
  { key = 'g', mods = 'LEADER', action = wezterm.action.PaneSelect },

  -- [ ペインのサイズ変更 ]
  { key = 'LeftArrow', mods = 'LEADER', action = wezterm.action.AdjustPaneSize{'Left', 5} },
  { key = 'DownArrow', mods = 'LEADER', action = wezterm.action.AdjustPaneSize{'Down', 5} },
  { key = 'UpArrow', mods = 'LEADER', action = wezterm.action.AdjustPaneSize{'Up', 5} },
  { key = 'RightArrow', mods = 'LEADER', action = wezterm.action.AdjustPaneSize{'Right', 5} },

  -- [ タブの操作 ]
  -- Ctrl+bを押した後 c で新規タブ
  { key = 'c', mods = 'LEADER', action = wezterm.action.SpawnTab('CurrentPaneDomain') },
  -- Ctrl+bを押した後 p(前), n(次) でタブ移動
  { key = 'p', mods = 'LEADER', action = wezterm.action.ActivateTabRelative(-1) },
  { key = 'n', mods = 'LEADER', action = wezterm.action.ActivateTabRelative(1) },
  -- Ctrl+bを押した後 x で現在のペイン/タブを閉じる
  { key = 'x', mods = 'LEADER', action = wezterm.action.CloseCurrentPane{ confirm = true } },
  -- Ctrl+bを押した後 w でタブ一覧を表示 (Tmux Prefix + w)
  { key = 'w', mods = 'LEADER', action = wezterm.action.ShowTabNavigator },

  -- [ポップアップ代替]
  -- Windows環境などで os.getenv("SHELL") が nil の場合でも動くようにフォールバックを追加
  { key = 't', mods = 'LEADER', action = wezterm.action.SpawnCommandInNewTab { label = 'poptab', args = os.getenv("SHELL") and { os.getenv("SHELL"), '-l', '-c', 'lazygit' } or { 'lazygit' } } },
  { key = 't', mods = 'LEADER|CTRL', action = wezterm.action.SpawnCommandInNewTab { label = 'poptab', args = os.getenv("SHELL") and { os.getenv("SHELL"), '-l', '-c', 'btm' } or { 'btm' } } },
  { key = 'y', mods = 'LEADER', action = wezterm.action.SpawnCommandInNewTab { label = 'poptab', args = os.getenv("SHELL") and { os.getenv("SHELL"), '-l', '-c', 'yazi' } or { 'yazi' } } },
  
  -- [ クリップボード操作 ]
  -- Ctrl+V でクリップボードの内容を貼り付ける
  { key = 'v', mods = 'CTRL', action = wezterm.action.PasteFrom 'Clipboard' },

  -- [ Tmux & Windowsライクな便利バインド ]
  -- Leader + z : ペインの最大化/元に戻す (Tmux Prefix + z)
  { key = 'z', mods = 'LEADER', action = wezterm.action.TogglePaneZoomState },
  -- Leader + [ : コピーモード (Tmux Prefix + [ )
  { key = '[', mods = 'LEADER', action = wezterm.action.ActivateCopyMode },
  -- Leader + , : タブ名のリネーム (Tmux Prefix + ,)
  {
    key = ',', mods = 'LEADER',
    action = wezterm.action.PromptInputLine {
      description = 'Enter new name for tab',
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    },
  },
  -- Alt + Enter : フルスクリーン切り替え (WindowsコマンドプロンプトやTeraTerm風)
  { key = 'Enter', mods = 'ALT', action = wezterm.action.ToggleFullScreen },

  -- [ タブ番号で直接移動 ] (tmux: Prefix + 0-9)
  { key = '0', mods = 'LEADER', action = wezterm.action.ActivateTab(0) },
  { key = '1', mods = 'LEADER', action = wezterm.action.ActivateTab(1) },
  { key = '2', mods = 'LEADER', action = wezterm.action.ActivateTab(2) },
  { key = '3', mods = 'LEADER', action = wezterm.action.ActivateTab(3) },
  { key = '4', mods = 'LEADER', action = wezterm.action.ActivateTab(4) },
  { key = '5', mods = 'LEADER', action = wezterm.action.ActivateTab(5) },
  { key = '6', mods = 'LEADER', action = wezterm.action.ActivateTab(6) },
  { key = '7', mods = 'LEADER', action = wezterm.action.ActivateTab(7) },
  { key = '8', mods = 'LEADER', action = wezterm.action.ActivateTab(8) },
  { key = '9', mods = 'LEADER', action = wezterm.action.ActivateTab(9) },

  -- [ Ctrl+b パススルー ] (tmux: Prefix + Prefix で実際のCtrl+bを送信)
  { key = 'b', mods = 'LEADER|CTRL', action = wezterm.action.SendKey{ key = 'b', mods = 'CTRL' } },

  -- [ 最後のタブに切替 ] (tmux: Prefix + Space)
  { key = 'Space', mods = 'LEADER', action = wezterm.action.ActivateLastTab },

  -- [ スクロールバック検索 ] (tmux: Prefix + /)
  { key = '/', mods = 'LEADER', action = wezterm.action.Search('CurrentSelectionOrEmptyString') },

  -- [ ペイン入れ替え ] (tmux: Prefix + { / })
  { key = '{', mods = 'LEADER|SHIFT', action = wezterm.action.RotatePanes('CounterClockwise') },
  { key = '}', mods = 'LEADER|SHIFT', action = wezterm.action.RotatePanes('Clockwise') },

  -- [ QuickSelect: URL・パス・ハッシュ等を素早く選択コピー ]
  { key = 's', mods = 'LEADER', action = wezterm.action.QuickSelect },
}

-- [ マウス操作のバインド ]
-- 右クリック: テキスト選択中はコピー、それ以外はペースト
config.mouse_bindings = {
  {
    event = { Down = { streak = 1, button = 'Right' } },
    mods = 'NONE',
    action = wezterm.action_callback(function(window, pane)
      local sel = window:get_selection_text_for_pane(pane)
      if sel and sel ~= '' then
        window:perform_action(wezterm.action.CopyTo('ClipboardAndPrimarySelection'), pane)
        window:perform_action(wezterm.action.ClearSelection, pane)
      else
        window:perform_action(wezterm.action.PasteFrom('Clipboard'), pane)
      end
    end),
  },
  -- ドラッグ選択（左クリックを離す）した瞬間に自動でクリップボードにコピーする (TeraTerm等風)
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = wezterm.action.CompleteSelection 'Clipboard',
  },
  -- Ctrl + 左クリックで、マウスカーソル下のリンクを開く
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CTRL',
    action = wezterm.action.OpenLinkAtMouseCursor,
  },
}

-- ==========================================
-- 5. 通知
-- ==========================================
-- ベル音を無効化 (トースト通知のみ表示)
config.audible_bell = "Disabled"

local function is_claude(pane)
  local info = pane:get_foreground_process_info()
  if info and info.executable then
    -- 実行ファイルパスに"claude"が含まれているかチェック
    if info.executable:lower():find("claude") then
      return true
    end
  end
  -- フォールバック: プロセス名でもチェック
  local name = pane:get_foreground_process_name()
  if name and name:lower():find("claude") then
    return true
  end
  return false
end

wezterm.on("bell", function(window, pane)
  -- プロセス名をログ出力 (デバッグ用: WezTermのDebug Overlay (Ctrl+Shift+L) で確認可能)
  local proc_name = pane:get_foreground_process_name() or "unknown"
  wezterm.log_info("bell event fired, process: " .. proc_name)

  if is_claude(pane) then
    window:toast_notification("Claude Code", "Task completed", nil, 4000)
  else
    -- デバッグ用: is_claudeがfalseの場合も通知して検証
    window:toast_notification("WezTerm Bell", "Process: " .. proc_name, nil, 4000)
  end
end)

-- ==========================================
-- 6. プラグイン設定
-- ==========================================
-- [ sessionizer.wezterm: プロジェクト単位の瞬時ワークスペース作成 ]
local sessionizer = wezterm.plugin.require("https://github.com/mikkasendke/sessionizer.wezterm")
sessionizer.apply_to_config(config)
-- デフォルトで Leader + f や Leader + w などのバインドが追加される場合があります。

-- [ smart-splits.nvim: Neovimとのペイン移動連携 ]
local smart_splits = wezterm.plugin.require("https://github.com/mrjones2014/smart-splits.nvim")
-- Ctrl + h, j, k, l でNeovimのペインとWezTermのペインをシームレスに行き来できるようにします
smart_splits.apply_to_config(config, {
  direction_keys = { 'h', 'j', 'k', 'l' },
  modifiers = {
    move = 'CTRL',    -- Ctrl + hjklで移動
    resize = 'META',  -- Alt + hjklでサイズ変更
  },
})


-- [tabline.wez: タブラインのカスタマイズ]
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
tabline.setup({
    options = {
        --theme = 'Tokyo Night Moon',
        theme = 'Dracula+',
        section_separators = {
            left = wezterm.nerdfonts.ple_upper_left_triangle,
            right = wezterm.nerdfonts.ple_lower_right_triangle,
        },
        component_separators = {
            left = wezterm.nerdfonts.ple_forwardslash_separator,
            right = wezterm.nerdfonts.ple_forwardslash_separator,
        },
        tab_separators = {
            left = wezterm.nerdfonts.ple_upper_left_triangle,
            right = wezterm.nerdfonts.ple_lower_right_triangle,
        },
        theme_overrides = {
            tab = {
                active = { fg = "#091833", bg = "#59c2c6" },
            },
        },
    },
    sections = {
        tabline_a = { 'mode' },
        tabline_b = { 'workspace' },
        tabline_c = { ' ' },
        tab_active = {
            "index",
            { "process", padding = { left = 0, right = 1 } },
            "",
            { "cwd",     padding = { left = 1, right = 0 } },
            { "zoomed",  padding = 1 },
        },
        tab_inactive = {
            "index",
            { "process", padding = { left = 0, right = 1 } },
            "󰉋",
            { "cwd",     padding = { left = 1, right = 0 } },
            { "zoomed",  padding = 1 },
        },
        tabline_x = { 
            -- Leaderキー入力状態を判定する独自コンポーネント
            function(window, pane)
                if window and window.leader_is_active and window:leader_is_active() then
                    return wezterm.format({
                        { Foreground = { Color = '#ff9e64' } }, -- 少し目立ちやすいオレンジ色
                        { Attribute = { Intensity = 'Bold' } },
                        { Text = ' ⌨️ LEADER ' },
                    })
                end
                return ' '
            end,
            'ram', 
            'cpu' 
        },
        tabline_y = {
            {
                'datetime',
                style = (wezterm.nerdfonts.fa_calendar_day or wezterm.nerdfonts.md_calendar or '📅') .. ' %Y-%m-%d',
                hour_to_icon = '',
            },
            {
                'datetime',
                style = '%H:%M:%S',
                padding = { left = 0, right = 1 },
            },
            'battery',
        },
        tabline_z = { 'domain' },
    },
})
tabline.apply_to_config(config)

-- tabline.wez が window_decorations などの表示設定を上書きしてしまうため、
-- 必ず apply_to_config などの「後」に Windows 標準タイトルバー設定を最優先で適用します。
config.window_decorations = "TITLE | RESIZE"
config.window_background_opacity = 0.9

-- ==========================================
-- 7. ウィンドウレイアウトの記憶と復元 (自前実装)
-- ==========================================
-- プラグイン不要。ウィンドウサイズ + タブ構成 + ペイン分割比率 + 各ペインCWD を
-- JSONファイルに保存し、次回起動時に gui-startup で復元する。
-- 30秒ごとの定期保存で終了直前の状態も捕捉する。

local layout_file = wezterm.home_dir .. '/.wezterm_layout.json'
local DEFAULT_CWD = is_windows and '/_Workspace' or (wezterm.home_dir .. '/workspace')

-- ペイン座標リストからバイナリツリーを再帰的に構築
-- ※ panes_with_info() の left, top, width, height から分割方向・比率を逆算する
local function build_pane_tree(panes_info, bounds)
  if #panes_info == 0 then return nil end

  -- 単一ペイン → リーフノード
  if #panes_info == 1 then
    local p = panes_info[1]
    local cwd_url = p.pane:get_current_working_dir()
    local cwd = cwd_url and cwd_url.file_path or nil
    if cwd and is_windows then cwd = cwd:gsub('^/(%a):', '%1:') end  -- Windows パス修正: /C: → C:
    return { cwd = cwd or DEFAULT_CWD }
  end

  -- 座標順にソート (左上が先頭)
  table.sort(panes_info, function(a, b)
    if a.left == b.left then return a.top < b.top end
    return a.left < b.left
  end)

  -- 全ペインの外接矩形を算出
  if not bounds then
    local max_r, max_b = 0, 0
    for _, p in ipairs(panes_info) do
      max_r = math.max(max_r, p.left + p.width)
      max_b = math.max(max_b, p.top + p.height)
    end
    bounds = { left = 0, top = 0, right = max_r, bottom = max_b }
  end

  local first = panes_info[1]
  local total_w = bounds.right - bounds.left
  local total_h = bounds.bottom - bounds.top

  -- 縦分割 (左|右) を検出: 先頭ペインの幅が全幅に満たない場合
  if first.left + first.width < bounds.right then
    local split_x = first.left + first.width + 1  -- +1 はセパレータ
    local left_g, right_g = {}, {}
    for _, p in ipairs(panes_info) do
      if p.left < split_x then table.insert(left_g, p)
      else table.insert(right_g, p) end
    end
    if #right_g > 0 then
      return {
        direction = 'Right',
        size = (bounds.right - split_x) / total_w,
        first  = build_pane_tree(left_g,  { left = bounds.left, top = bounds.top, right = split_x - 1, bottom = bounds.bottom }),
        second = build_pane_tree(right_g, { left = split_x,     top = bounds.top, right = bounds.right, bottom = bounds.bottom }),
      }
    end
  end

  -- 横分割 (上/下) を検出: 先頭ペインの高さが全高に満たない場合
  if first.top + first.height < bounds.bottom then
    local split_y = first.top + first.height + 1
    local top_g, bottom_g = {}, {}
    for _, p in ipairs(panes_info) do
      if p.top < split_y then table.insert(top_g, p)
      else table.insert(bottom_g, p) end
    end
    if #bottom_g > 0 then
      return {
        direction = 'Bottom',
        size = (bounds.bottom - split_y) / total_h,
        first  = build_pane_tree(top_g,    { left = bounds.left, top = bounds.top,  right = bounds.right, bottom = split_y - 1 }),
        second = build_pane_tree(bottom_g, { left = bounds.left, top = split_y,     right = bounds.right, bottom = bounds.bottom }),
      }
    end
  end

  -- フォールバック: 単一ペインとして返す
  local cwd_url = first.pane:get_current_working_dir()
  local cwd = cwd_url and cwd_url.file_path or nil
  if cwd and is_windows then cwd = cwd:gsub('^/(%a):', '%1:') end
  return { cwd = cwd or DEFAULT_CWD }
end

-- ツリーの先頭リーフのCWDを取得 (spawn_window / split の cwd 引数に使用)
local function get_first_cwd(node)
  if not node then return nil end
  if node.cwd then return node.cwd end
  if node.first then return get_first_cwd(node.first) end
  return nil
end

-- 現在のレイアウト状態をJSONファイルへ保存
local function save_layout()
  local ok, err = pcall(function()
    local all_wins = wezterm.mux.all_windows()
    if #all_wins == 0 then return end
    local win = all_wins[1]  -- 最初のウィンドウのみ対象
    local tabs = win:tabs()
    if #tabs == 0 then return end

    -- ウィンドウの総サイズを算出 (最初のタブの全ペイン座標から)
    local first_panes = tabs[1]:panes_with_info()
    local total_cols, total_rows = 0, 0
    for _, p in ipairs(first_panes) do
      total_cols = math.max(total_cols, p.left + p.width)
      total_rows = math.max(total_rows, p.top + p.height)
    end

    -- 各タブのペイン構成をツリー化
    local tabs_state = {}
    for _, tab in ipairs(tabs) do
      local panes = tab:panes_with_info()
      if #panes > 0 then
        table.insert(tabs_state, build_pane_tree(panes))
      end
    end

    if #tabs_state > 0 then
      local fh = io.open(layout_file, 'w')
      if fh then
        fh:write(wezterm.json_encode({
          cols = total_cols,
          rows = total_rows,
          tabs = tabs_state,
        }))
        fh:close()
      end
    end
  end)
  if not ok then
    wezterm.log_warn('layout save failed: ' .. tostring(err))
  end
end

-- 5秒ごとの定期保存
-- ※ WezTermに終了前フック(shutdown event)は存在しないため、短い間隔で補う。
--   保存データは数百バイトのJSONなので I/O 負荷はほぼゼロ。
local function periodic_save()
  wezterm.time.call_after(5, function()
    save_layout()
    periodic_save()
  end)
end
periodic_save()

-- ペインの分割を再帰的に復元
local function restore_splits(node, pane)
  if not node or not node.direction then return end
  local second_cwd = get_first_cwd(node.second) or DEFAULT_CWD
  local new_pane = pane:split {
    direction = node.direction,
    size = node.size,
    cwd = second_cwd,
  }
  restore_splits(node.first, pane)       -- 左/上 (元のペイン)
  restore_splits(node.second, new_pane)  -- 右/下 (新しいペイン)
end

-- 起動時にレイアウトを自動復元
wezterm.on('gui-startup', function(cmd)
  local fh = io.open(layout_file, 'r')
  if not fh then
    -- 状態ファイルがない場合はデフォルトで起動
    wezterm.mux.spawn_window { cwd = DEFAULT_CWD, args = cmd and cmd.args or nil }
    return
  end
  local content = fh:read('*a')
  fh:close()

  local ok, state = pcall(wezterm.json_parse, content)
  if not ok or not state or not state.tabs or #state.tabs == 0 then
    wezterm.mux.spawn_window { cwd = DEFAULT_CWD, args = cmd and cmd.args or nil }
    return
  end

  local window
  for i, tab_layout in ipairs(state.tabs) do
    local first_cwd = get_first_cwd(tab_layout) or DEFAULT_CWD
    local tab, pane
    if i == 1 then
      tab, pane, window = wezterm.mux.spawn_window {
        width = state.cols,
        height = state.rows,
        cwd = first_cwd,
        args = cmd and cmd.args or nil,
      }
    else
      tab, pane = window:spawn_tab { cwd = first_cwd }
    end
    restore_splits(tab_layout, pane)
  end
end)

return config