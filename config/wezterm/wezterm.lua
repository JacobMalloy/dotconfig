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

config.font = wezterm.font 'Victor Mono'
config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }
config.font_size = 12


config.color_scheme = 'Dark+'
config.default_cursor_style = "SteadyBar"
--config.color_schemes={
--  ['Dark+']={
--    --cursor_border = {Color = '#ff0000'},
--    cursor_border = '#ff0000',
--    cursor_fg = '#ff0000',
--  }
--}
config.colors={
    cursor_border = '#ff0000',
    cursor_fg = '#ff0000',
}

config.front_end = 'WebGpu'
-- config.front_end = 'OpenGL'


config.window_background_opacity = 0.7
config.text_background_opacity=0.7
config.macos_window_background_blur = 20
-- config.win32_system_backdrop = "Acrylic"


config.audible_bell = "Disabled"



if string.find(wezterm.target_triple,"windows") then
  config.window_background_opacity = .2
  config.text_background_opacity=config.window_background_opacity;
  config.win32_system_backdrop = "Acrylic"  
end



-- and finally, return the configuration to wezterm
return config
