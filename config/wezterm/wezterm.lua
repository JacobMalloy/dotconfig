-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This table will hold the configuration.
local config = wezterm.config_builder()
local action = wezterm.action

local current_system = "linux"


if string.find(wezterm.target_triple, "darwin") then
    current_system = "macos"
elseif string.find(wezterm.target_triple, "win32") then
    current_system = "windows"
end

-- This is where you actually apply your config choices

config.font = wezterm.font_with_fallback {
    'Monaspace Neon',
    --     'Fantasque Sans Mono',
    --     'Victor Mono',
    'Jetbrains Mono',
    'Noto Color Emoji',
}
config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }
config.font_size = 15


config.color_scheme = 'Dark+'




config.default_cursor_style = "SteadyBar"

config.window_padding = { left = '0.5cell', right = '0.5cell', top = '0.5cell', bottom = '0.5cell' }

config.colors = {
    cursor_bg = '#ff2040',
    background = 'hsv(0,0%,2%)'
}



-- config.front_end = 'WebGpu'
-- config.front_end = 'OpenGL'


--config.window_background_opacity = 0.8
--config.text_background_opacity=0.5
config.macos_window_background_blur = 20
-- config.win32_system_backdrop = "Acrylic"

-- config.window_background_image = os.getenv("HOME") .. '/.config/wezterm/triangle.png'



config.audible_bell = "Disabled"

local window_background_opacity = 0.8
local text_background_opacity = 0.5


if current_system == "windows" then
    window_background_opacity = .5
    text_background_opacity = window_background_opacity;
    config.win32_system_backdrop = "Acrylic"
    -- config.front_end = "OpenGL"
elseif current_system == "linux" then
    window_background_opacity = 0.85
    text_background_opacity = window_background_opacity;
    config.front_end = 'WebGpu'
end


wezterm.on('window-config-reloaded', function(window, pane)
    -- approximately identify this gui window, by using the associated mux id
    local id = tostring(window:window_id())

    -- maintain a mapping of windows that we have previously seen before in this event handler
    local seen = wezterm.GLOBAL.seen_windows or {}
    -- set a flag if we haven't seen this window before
    local is_new_window = not seen[id]
    -- and update the mapping
    seen[id] = true
    wezterm.GLOBAL.seen_windows = seen

    -- now act upon the flag
    if is_new_window then
        local overrides = window:get_config_overrides() or {}
        if not overrides.text_background_opacity then
            overrides.text_background_opacity = text_background_opacity
            overrides.window_background_opacity = window_background_opacity
        end
        window:set_config_overrides(overrides)
    end
end)

wezterm.on('toggle-text-bg-opacity', function(window, pane)
    local overrides = window:get_config_overrides() or {}
    if not overrides.text_background_opacity then
        overrides.text_background_opacity = text_background_opacity
        overrides.window_background_opacity = window_background_opacity
    else
        overrides.text_background_opacity = nil
        overrides.window_background_opacity = nil
    end
    window:set_config_overrides(overrides)
end)

config.keys = {
    {
        key = '+',
        mods = 'CMD',
        action = wezterm.action.IncreaseFontSize,
    },
    {
        key = '-',
        mods = 'CMD',
        action = wezterm.action.DecreaseFontSize,
    },
    {
        key = 'B',
        mods = 'CMD',
        action = wezterm.action.EmitEvent 'toggle-text-bg-opacity',
    },
}

-- and finally, return the configuration to wezterm
return config
