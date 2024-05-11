-- Pull in the wezterm API
local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()

-- appearance
config.color_scheme = "Dracula"

config.use_fancy_tab_bar = true
config.window_background_opacity = 0.6
config.text_background_opacity = 0.8
config.inactive_pane_hsb = {
	saturation = 0.8,
	brightness = 0.7,
}

config.font = wezterm.font("agave Nerd Font")
config.font_size = 16

config.status_update_interval = 1000
wezterm.on("update-status", function(window, pane)
	local stat = window:active_workspace()

	local t = window:active_key_table()
	if t then
		stat = t
	elseif window:leader_is_active() then
		stat = "LDR"
	end

	local basename = function(s)
		s = string.gsub(s, "(.*)/$", "%1")
		return string.gsub(s, "(.*[/\\])(.*)", "%2")
	end

	local cwd = pane:get_current_working_dir()
	if cwd then
		cwd = basename(cwd.path)
	end

	local cmd = pane:get_foreground_process_name()
	if cmd then
		cmd = basename(cmd)
	end

	window:set_right_status(wezterm.format({
		{ Text = wezterm.nerdfonts.oct_table .. "  " .. stat },
		{ Text = "   |   " },
		{ Text = wezterm.nerdfonts.cod_folder_opened .. "  " .. (cwd or "") },
		{ Text = "   |   " },
		{ Text = wezterm.nerdfonts.fa_code .. "  " .. (cmd or "") },
		{ Text = "       " },
	}))
end)

-- key mapping
config.disable_default_key_bindings = true
config.keys = {
	-- tab control
	{ key = "]", mods = "ALT", action = act.ActivateTabRelative(1) },
	{ key = "[", mods = "ALT", action = act.ActivateTabRelative(-1) },
	{ key = "+", mods = "CMD", action = act.IncreaseFontSize },
	{ key = "-", mods = "CMD", action = act.DecreaseFontSize },
	{ key = "0", mods = "CMD", action = act.ResetFontSize },
	{ key = "1", mods = "CMD", action = act.ActivateTab(0) },
	{ key = "2", mods = "CMD", action = act.ActivateTab(1) },
	{ key = "3", mods = "CMD", action = act.ActivateTab(2) },
	{ key = "4", mods = "CMD", action = act.ActivateTab(3) },
	{ key = "5", mods = "CMD", action = act.ActivateTab(4) },
	{ key = "6", mods = "CMD", action = act.ActivateTab(5) },
	{ key = "7", mods = "CMD", action = act.ActivateTab(6) },
	{ key = "8", mods = "CMD", action = act.ActivateTab(7) },
	{ key = "9", mods = "CMD", action = act.ActivateTab(8) },
	{ key = "t", mods = "CMD", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "w", mods = "CMD", action = act.CloseCurrentTab({ confirm = true }) },
	{
		key = "t",
		mods = "ALT",
		action = wezterm.action.ActivateKeyTable({
			name = "tab",
		}),
	},

	-- pane control
	{ key = "d", mods = "CMD", action = act.SplitHorizontal({}) },
	{ key = "d", mods = "CMD|SHIFT", action = act.SplitVertical({}) },
	{ key = "h", mods = "ALT", action = act.ActivatePaneDirection("Left") },
	{ key = "l", mods = "ALT", action = act.ActivatePaneDirection("Right") },
	{ key = "k", mods = "ALT", action = act.ActivatePaneDirection("Up") },
	{ key = "j", mods = "ALT", action = act.ActivatePaneDirection("Down") },
	{ key = "f", mods = "ALT", action = act.TogglePaneZoomState },
	{ key = "w", mods = "CMD", action = act.CloseCurrentPane({ confirm = true }) },

	{ key = "f", mods = "CMD", action = act.Search("CurrentSelectionOrEmptyString") },
	{ key = "n", mods = "CMD", action = act.SpawnWindow },
	{ key = "p", mods = "CMD", action = act.ActivateCommandPalette },
	{ key = "r", mods = "CMD", action = act.ReloadConfiguration },
	{ key = "c", mods = "CMD", action = act.CopyTo("Clipboard") },
	{ key = "v", mods = "CMD", action = act.PasteFrom("Clipboard") },
	{ key = "c", mods = "SHIFT|CTRL", action = act.ActivateCopyMode },
	{ key = "q", mods = "CTRL|SHIFT", action = act.QuitApplication },

	-- session control
	{
		key = "s",
		mods = "ALT",
		action = wezterm.action.ShowLauncherArgs({
			flags = "LAUNCH_MENU_ITEMS|WORKSPACES|TABS",
		}),
	},
	{ key = "s", mods = "CTRL", action = act.ActivateKeyTable({ name = "workspace" }) },
}

config.key_tables = {
	copy_mode = {
		{ key = "0", mods = "NONE", action = act.CopyMode("MoveToStartOfLine") },
		{ key = "^", mods = "NONE", action = act.CopyMode("MoveToStartOfLineContent") },
		{ key = "Enter", mods = "NONE", action = act.CopyMode("MoveToStartOfNextLine") },
		{ key = "$", mods = "NONE", action = act.CopyMode("MoveToEndOfLineContent") },
		{ key = "g", mods = "NONE", action = act.CopyMode("MoveToScrollbackTop") },
		{ key = "G", mods = "NONE", action = act.CopyMode("MoveToScrollbackBottom") },
		{ key = "H", mods = "NONE", action = act.CopyMode("MoveToViewportTop") },
		{ key = "M", mods = "NONE", action = act.CopyMode("MoveToViewportMiddle") },
		{ key = "L", mods = "NONE", action = act.CopyMode("MoveToViewportBottom") },
		{ key = "o", mods = "NONE", action = act.CopyMode("MoveToSelectionOtherEnd") },
		{ key = "O", mods = "NONE", action = act.CopyMode("MoveToSelectionOtherEndHoriz") },
		{ key = "w", mods = "NONE", action = act.CopyMode("MoveForwardWord") },
		{ key = "e", mods = "NONE", action = act.CopyMode("MoveForwardWordEnd") },
		{ key = "b", mods = "NONE", action = act.CopyMode("MoveBackwardWord") },
		{ key = "h", mods = "NONE", action = act.CopyMode("MoveLeft") },
		{ key = "j", mods = "NONE", action = act.CopyMode("MoveDown") },
		{ key = "k", mods = "NONE", action = act.CopyMode("MoveUp") },
		{ key = "l", mods = "NONE", action = act.CopyMode("MoveRight") },
		{ key = "d", mods = "CTRL", action = act.CopyMode({ MoveByPage = 0.5 }) },
		{ key = "u", mods = "CTRL", action = act.CopyMode({ MoveByPage = -0.5 }) },
		{ key = "b", mods = "CTRL", action = act.CopyMode("PageUp") },
		{ key = "f", mods = "CTRL", action = act.CopyMode("PageDown") },
		{ key = ",", mods = "NONE", action = act.CopyMode("JumpReverse") },
		{ key = ";", mods = "NONE", action = act.CopyMode("JumpAgain") },
		{ key = "f", mods = "NONE", action = act.CopyMode({ JumpForward = { prev_char = false } }) },
		{ key = "t", mods = "NONE", action = act.CopyMode({ JumpForward = { prev_char = true } }) },
		{ key = "F", mods = "NONE", action = act.CopyMode({ JumpBackward = { prev_char = false } }) },
		{ key = "T", mods = "NONE", action = act.CopyMode({ JumpBackward = { prev_char = true } }) },
		{ key = "V", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Line" }) },
		{ key = "v", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Cell" }) },
		{ key = "v", mods = "CTRL", action = act.CopyMode({ SetSelectionMode = "Block" }) },
		{
			key = "y",
			mods = "NONE",
			action = act.Multiple({ { CopyTo = "ClipboardAndPrimarySelection" }, { CopyMode = "Close" } }),
		},
		{ key = "Escape", mods = "NONE", action = act.CopyMode("ClearSelectionMode") },
		{ key = "q", mods = "NONE", action = act.CopyMode("Close") },
	},

	search_mode = {
		{ key = "Enter", mods = "NONE", action = act.CopyMode("PriorMatch") },
		{ key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
		{ key = "n", mods = "CTRL", action = act.CopyMode("NextMatch") },
		{ key = "p", mods = "CTRL", action = act.CopyMode("PriorMatch") },
		{ key = "r", mods = "CTRL", action = act.CopyMode("CycleMatchType") },
		{ key = "u", mods = "CTRL", action = act.CopyMode("ClearPattern") },
	},

	tab = {
		{
			key = "r",
			action = act.PromptInputLine({
				description = "Enter new name for tab",
				action = wezterm.action_callback(function(window, _, line)
					if line then
						window:active_tab():set_title(line)
					end
				end),
			}),
		},
	},

	workspace = {
		{
			key = "r",
			action = wezterm.action.PromptInputLine({
				description = "Enter new name for workspace",
				action = wezterm.action_callback(function(_, _, line)
					if line then
						wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
					end
				end),
			}),
		},
		{ key = "]", action = act.SwitchWorkspaceRelative(1) },
		{ key = "[", action = act.SwitchWorkspaceRelative(-1) },
	},
}

return config
