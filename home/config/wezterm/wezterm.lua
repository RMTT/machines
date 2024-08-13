local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.color_scheme = "Catppuccin Mocha"
config.xcursor_theme = "breeze_cursors"
config.font = wezterm.font("FiraCode Nerd Font Mono")
config.use_ime = true
config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true
config.window_close_confirmation = 'AlwaysPrompt'

config.keys = {
  {
    key = 'd',
    mods = 'SHIFT|ALT',
    action = wezterm.action.DetachDomain("CurrentPaneDomain"),
  },
  {
    key = 't',
    mods = 'SHIFT|ALT',
    action = wezterm.action.SpawnTab 'CurrentPaneDomain',
  },
  {
    key = '%',
    mods = 'SHIFT|ALT',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    key = '"',
    mods = 'SHIFT|ALT',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },
  {
    key = 'p',
    mods = 'SHIFT|ALT',
    action = wezterm.action.ActivateTabRelative(-1)
  },
  {
    key = 'n',
    mods = 'SHIFT|ALT',
    action = wezterm.action.ActivateTabRelative(1)
  },
  {
    key = 'w',
    mods = 'SHIFT|ALT',
    action = wezterm.action.CloseCurrentTab { confirm = true },
  },
  {
    key = 'h',
    mods = 'SHIFT|ALT',
    action = wezterm.action.ActivatePaneDirection 'Left',
  },
  {
    key = 'l',
    mods = 'SHIFT|ALT',
    action = wezterm.action.ActivatePaneDirection 'Right',
  },
  {
    key = 'k',
    mods = 'SHIFT|ALT',
    action = wezterm.action.ActivatePaneDirection 'Up',
  },
  {
    key = 'j',
    mods = 'SHIFT|ALT',
    action = wezterm.action.ActivatePaneDirection 'Down',
  },
}

return config
