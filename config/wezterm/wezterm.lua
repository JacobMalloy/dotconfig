-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- This is where you actually apply your config choices



config.color_scheme = 'Dark+'

config.front_end = 'WebGpu'


config.window_background_opacity = 0.3
config.macos_window_background_blur = 20
-- config.win32_system_backdrop = "Acrylic"


config.audible_bell = "Disabled"

-- and finally, return the configuration to wezterm
return config
