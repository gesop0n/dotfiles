local wezterm = require('wezterm')
local M = {}

function M.apply(config)
  config.font = wezterm.font('MesloLGS Nerd Font', { weight = 'Regular' })
  config.font_size = 16.0

  config.color_scheme = 'Tokyo Night (Gogh)'

  config.window_decorations = "RESIZE"
  config.window_background_opacity = 0.75
  config.macos_window_background_blur = 30
  config.window_padding = { left = 16, right = 16, top = 10, bottom = 10 }
end

return M
