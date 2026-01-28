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

local function trim_whitespace(value)
  return (value:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function project_workspace_picker(window, pane)
  local success, stdout, stderr = wezterm.run_child_process {
    "sh",
    "-lc",
    "zoxide query -l | fzf --prompt 'Project> '",
  }

  if not success then
    wezterm.log_error("Project picker failed: " .. (stderr or ""))
    return
  end

  local project_dir = trim_whitespace(stdout or "")
  if project_dir == "" then
    return
  end

  local workspace_name = project_dir:match("([^/]+)$") or project_dir

  window:perform_action(
    act.SwitchToWorkspace {
      name = workspace_name,
      spawn = { cwd = project_dir },
    },
    pane
  )
end

local function prompt_new_workspace(window, pane)
  window:perform_action(
    act.PromptInputLine {
      description = "New workspace name",
      action = wezterm.action_callback(function(prompt_window, prompt_pane, line)
        if not line or line == "" then
          return
        end

        prompt_window:perform_action(
          act.SwitchToWorkspace { name = line },
          prompt_pane
        )
      end),
    },
    pane
  )
end

local function prompt_rename_workspace(window, pane)
  local current_workspace = wezterm.mux.get_active_workspace()
  if not current_workspace or current_workspace == "" then
    return
  end

  window:perform_action(
    act.PromptInputLine {
      description = "Rename workspace",
      action = wezterm.action_callback(function(prompt_window, prompt_pane, line)
        if not line or line == "" or line == current_workspace then
          return
        end

        wezterm.mux.rename_workspace(current_workspace, line)
        prompt_window:perform_action(
          act.SwitchToWorkspace { name = line },
          prompt_pane
        )
      end),
    },
    pane
  )
end

config.keys = {
  { key = "t", mods = "LEADER", action = act.SendKey { key = "t", mods = "CTRL" } },
  { key = "s", mods = "LEADER", action = act.ShowLauncher },
  { key = "p", mods = "LEADER", action = wezterm.action_callback(project_workspace_picker) },
  { key = "n", mods = "LEADER", action = wezterm.action_callback(prompt_new_workspace) },
  { key = "r", mods = "LEADER", action = wezterm.action_callback(prompt_rename_workspace) },
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
