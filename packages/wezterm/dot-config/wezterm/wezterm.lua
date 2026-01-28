local wezterm = require "wezterm"

local act = wezterm.action
local config = wezterm.config_builder()

config.color_scheme = "Modus-Vivendi"
config.font = wezterm.font_with_fallback({
  "Terminess Nerd Font",
  "Terminess (TTF) Nerd Font",
})
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.leader = { key = "t", mods = "CTRL", timeout_milliseconds = 1000 }
config.window_padding = {
  left = 6,
  right = 6,
  top = 4,
  bottom = 4,
}

config.keys = {
  { key = "t", mods = "LEADER", action = act.SendKey { key = "t", mods = "CTRL" } },
  { key = "s", mods = "LEADER", action = act.ShowLauncher },
  { key = "c", mods = "LEADER", action = act.SpawnTab "CurrentPaneDomain" },
  { key = "x", mods = "LEADER", action = act.CloseCurrentPane { confirm = true } },
  { key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
  { key = "h", mods = "LEADER", action = act.ActivatePaneDirection "Left" },
  { key = "j", mods = "LEADER", action = act.ActivatePaneDirection "Down" },
  { key = "k", mods = "LEADER", action = act.ActivatePaneDirection "Up" },
  { key = "l", mods = "LEADER", action = act.ActivatePaneDirection "Right" },
  { key = "H", mods = "LEADER|SHIFT", action = act.AdjustPaneSize { "Left", 5 } },
  { key = "J", mods = "LEADER|SHIFT", action = act.AdjustPaneSize { "Down", 5 } },
  { key = "K", mods = "LEADER|SHIFT", action = act.AdjustPaneSize { "Up", 5 } },
  { key = "L", mods = "LEADER|SHIFT", action = act.AdjustPaneSize { "Right", 5 } },
  { key = "|", mods = "LEADER|SHIFT", action = act.SplitHorizontal { domain = "CurrentPaneDomain" } },
  { key = "-", mods = "LEADER", action = act.SplitVertical { domain = "CurrentPaneDomain" } },
  {
    key = "g",
    mods = "LEADER",
    action = act.SplitPane {
      direction = "Right",
      size = { Percent = 40 },
      command = {
        args = {
          "sh",
          "-lc",
          "root=$(git rev-parse --show-toplevel 2>/dev/null || pwd); cd \"$root\" && exec gitu",
        },
      },
      domain = "CurrentPaneDomain",
    },
  },
}

return config
