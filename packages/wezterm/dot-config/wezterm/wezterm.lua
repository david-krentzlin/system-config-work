local wezterm = require "wezterm"

local act = wezterm.action
local config = wezterm.config_builder()

config.color_scheme = "Modus-Vivendi"
config.font = wezterm.font_with_fallback({
	{ family = "Terminess Nerd Font", weight = "Regular" },
	{ family = "Terminess (TTF) Nerd Font", weight = "Regular" },
})
config.font_size = 14
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.leader = { key = ",", mods = "SUPER", timeout_milliseconds = 1000 }
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
    "zsh",
    "-lic",
    "zoxide query -l",
  }

  if not success then
    wezterm.log_error("Project picker failed: " .. (stderr or ""))
    return
  end

  local choices = {}
  for line in (stdout or ""):gmatch("[^\r\n]+") do
    local project_dir = trim_whitespace(line)
    if project_dir ~= "" then
      local workspace_name = project_dir:match("([^/]+)$") or project_dir
      table.insert(choices, {
        id = project_dir,
        label = workspace_name,
      })
    end
  end

  if #choices == 0 then
    wezterm.log_info("Project picker: no entries from zoxide")
    return
  end

  window:perform_action(
    act.InputSelector {
      title = "Project",
      choices = choices,
      fuzzy = true,
      action = wezterm.action_callback(function(prompt_window, prompt_pane, id, label)
        if not id and not label then
          return
        end

        local project_dir = trim_whitespace(id or label or "")
        if project_dir == "" then
          return
        end

        local workspace_name = project_dir:match("([^/]+)$") or project_dir
        prompt_window:perform_action(
          act.SwitchToWorkspace {
            name = workspace_name,
            spawn = { cwd = project_dir },
          },
          prompt_pane
        )
      end),
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

local function workspace_switcher(window, pane)
  local current_workspace = wezterm.mux.get_active_workspace()
  local workspaces = wezterm.mux.get_workspace_names()
  local choices = {}

  for _, workspace_name in ipairs(workspaces or {}) do
    local label = workspace_name
    if workspace_name == current_workspace then
      label = "* " .. workspace_name
    end

    table.insert(choices, {
      id = workspace_name,
      label = label,
    })
  end

  if #choices == 0 then
    return
  end

  window:perform_action(
    act.InputSelector {
      title = "Workspace",
      choices = choices,
      fuzzy = true,
      action = wezterm.action_callback(function(prompt_window, prompt_pane, id, label)
        if not id and not label then
          return
        end

        local target_workspace = trim_whitespace(id or label or "")
        if target_workspace == "" then
          return
        end

        prompt_window:perform_action(
          act.SwitchToWorkspace { name = target_workspace },
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
	{ key = "w", mods = "LEADER", action = wezterm.action_callback(workspace_switcher) },
	{ key = "n", mods = "LEADER", action = wezterm.action_callback(prompt_new_workspace) },
  { key = "r", mods = "LEADER", action = wezterm.action_callback(prompt_rename_workspace) },
  { key = "c", mods = "LEADER", action = act.SpawnTab "CurrentPaneDomain" },
  { key = "[", mods = "LEADER", action = act.ActivateTabRelative(-1) },
  { key = "]", mods = "LEADER", action = act.ActivateTabRelative(1) },
  { key = "1", mods = "LEADER", action = act.ActivateTab(0) },
  { key = "2", mods = "LEADER", action = act.ActivateTab(1) },
  { key = "3", mods = "LEADER", action = act.ActivateTab(2) },
  { key = "4", mods = "LEADER", action = act.ActivateTab(3) },
  { key = "5", mods = "LEADER", action = act.ActivateTab(4) },
  { key = "6", mods = "LEADER", action = act.ActivateTab(5) },
  { key = "7", mods = "LEADER", action = act.ActivateTab(6) },
  { key = "8", mods = "LEADER", action = act.ActivateTab(7) },
  { key = "9", mods = "LEADER", action = act.ActivateTab(8) },
	{ key = "x", mods = "LEADER", action = act.CloseCurrentPane { confirm = false } },
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
					"zsh",
					"-lic",
					"root=$(git rev-parse --show-toplevel 2>/dev/null || pwd); cd \"$root\"; if command -v lazygit >/dev/null 2>&1; then exec lazygit; else echo 'lazygit not found on PATH'; exec zsh -l; fi",
				},
			},
		},
	},
}

return config
