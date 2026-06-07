local wezterm = require('wezterm')
local act = wezterm.action
local M = {}

function M.apply(config)
  config.keys = {
    -- 垂直分割 (左右)
    { key = 'd', mods = 'CMD', action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }) },
    -- 水平分割 (上下)
    { key = 'd', mods = 'CMD|SHIFT', action = act.SplitVertical({ domain = 'CurrentPaneDomain' }) },

    -- ペイン間の移動 (CMD+OPT+矢印)
    { key = 'LeftArrow',  mods = 'CMD|OPT', action = act.ActivatePaneDirection('Left') },
    { key = 'RightArrow', mods = 'CMD|OPT', action = act.ActivatePaneDirection('Right') },
    { key = 'UpArrow',    mods = 'CMD|OPT', action = act.ActivatePaneDirection('Up') },
    { key = 'DownArrow',  mods = 'CMD|OPT', action = act.ActivatePaneDirection('Down') },

    -- ペイン間の移動 (Ctrl-w → h/j/k/l, vim/tmux風)
    { key = 'w', mods = 'CTRL', action = act.ActivateKeyTable({ name = 'pane_nav', one_shot = true, timeout_milliseconds = 1000 }) },

    -- ペインを閉じる
    { key = 'w', mods = 'CMD', action = act.CloseCurrentPane({ confirm = true }) },

    -- Option+¥ でバックスラッシュを入力
    { key = '¥', mods = 'OPT', action = act.SendString('\\') },
  }

  -- Ctrl-w を押した後に有効になるキーテーブル
  config.key_tables = {
    pane_nav = {
      { key = 'h', action = act.ActivatePaneDirection('Left') },
      { key = 'j', action = act.ActivatePaneDirection('Down') },
      { key = 'k', action = act.ActivatePaneDirection('Up') },
      { key = 'l', action = act.ActivatePaneDirection('Right') },
    },
  }
end

return M
