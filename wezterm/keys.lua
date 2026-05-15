local wezterm = require('wezterm')
local act = wezterm.action
local M = {}

function M.apply(config)
  config.keys = {
    -- 垂直分割 (左右)
    { key = 'd', mods = 'CMD', action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }) },
    -- 水平分割 (上下)
    { key = 'd', mods = 'CMD|SHIFT', action = act.SplitVertical({ domain = 'CurrentPaneDomain' }) },

    -- ペイン間の移動
    { key = 'LeftArrow',  mods = 'CMD|OPT', action = act.ActivatePaneDirection('Left') },
    { key = 'RightArrow', mods = 'CMD|OPT', action = act.ActivatePaneDirection('Right') },
    { key = 'UpArrow',    mods = 'CMD|OPT', action = act.ActivatePaneDirection('Up') },
    { key = 'DownArrow',  mods = 'CMD|OPT', action = act.ActivatePaneDirection('Down') },

    -- ペインを閉じる
    { key = 'w', mods = 'CMD', action = act.CloseCurrentPane({ confirm = true }) },
  }
end

return M
