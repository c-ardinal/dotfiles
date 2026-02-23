
-- 参考サイト
-- a24k氏, 年頭にあたり Ghostty と WezTerm を試す, https://zenn.dev/a24k/articles/20260110-ghostty-wezterm
-- CoralPink氏, Commentary of Dotfiles, https://coralpink.github.io/commentary/index.html
-- ナミレリ氏, 【Mac】WezTermで快適なターミナル体験, https://namileriblog.com/mac/wezterm/

local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- ==========================================
-- 1. 基本設定 (Basic Settings)
-- ==========================================
-- フォント設定(英語フォント + 日本語フォントのフォールバック)
config.font = wezterm.font_with_fallback({
  'JetBrains Mono',
  'Meiryo',
})
config.font_size = 10.0
-- 日本語入力(IME)を有効化
config.use_ime = true
-- Leaderキーなどを押したときに即座にステータスバー(右上のインジケータ等)へ反映させるための更新頻度設定
config.status_update_interval = 100
-- デフォルトシェルを NuShell に設定
config.default_prog = { 'nu' }
-- カーソルを点滅する縦線に設定
config.default_cursor_style = "BlinkingBar"
-- 起動時のカレントディレクトリを /_Workspace に設定
config.default_cwd = "/_Workspace"
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
}

-- ==========================================
-- 5. プラグイン設定
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
-- 6. ウィンドウサイズの記憶と復元 (手動実装)
-- ==========================================
local state_file = wezterm.home_dir .. '/.wezterm_state.json'
local f = io.open(state_file, 'r')
if f then
  local content = f:read('*a')
  f:close()
  local success, parsed = pcall(wezterm.json_parse, content)
  if success and parsed and parsed.cols and parsed.rows then
    -- 前回のウィンドウの列数と行数を初期サイズとして復元
    config.initial_cols = parsed.cols
    config.initial_rows = parsed.rows
  end
end

wezterm.on('window-resized', function(window, pane)
  if pane then
    local p_dims = pane:get_dimensions()
    local f = io.open(state_file, 'w')
    if f then
      f:write(wezterm.json_encode({
        cols = p_dims.cols,
        rows = p_dims.viewport_rows
      }))
      f:close()
    end
  end
end)

return config