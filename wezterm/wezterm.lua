local wezterm = require('wezterm')
local config = wezterm.config_builder()

require('appearance').apply(config)
require('tabbar').apply(config)

return config
