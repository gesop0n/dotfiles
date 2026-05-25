local wezterm = require("wezterm")
local M = {}

M.custom_title = {}

-- =============================================================================
-- 定数
-- =============================================================================

local ICONS = {
    docker   = wezterm.nerdfonts.md_docker,
    neovim   = wezterm.nerdfonts.linux_neovim,
    nb       = wezterm.nerdfonts.md_notebook,
    ssh      = wezterm.nerdfonts.md_lan,
    claude   = "✳",
    fallback = wezterm.nerdfonts.dev_terminal,
    zoom     = wezterm.nerdfonts.md_magnify,
}

local ICON_COLORS = {
    docker = "#4169e1",
    neovim = "#57A143",
    nb     = "#9370DB",
    ssh    = "#ff6b6b",
    claude = "#D97757",
}

local TAB_COLORS = {
    background_active     = "#9a7d20",
    foreground_active     = "#1a1b26",
    background_inactive   = "#3b3d56",
    foreground_inactive   = "#888aa4",
    background_ssh_active = "#ff6b6b",
    foreground_ssh_active = "#ffffff",
}

local BAR_BG = "#15161e"

local DECO = {
    left  = wezterm.nerdfonts.ple_left_half_circle_thick,
    right = wezterm.nerdfonts.ple_right_half_circle_thick,
}

-- =============================================================================
-- ヘルパー関数
-- =============================================================================

local function basename(path)
    return string.gsub(path or "", "(.*[/\\])(.*)", "%2")
end

local function is_nb_process(process_name, cmdline, cwd)
    return process_name == "nb"
        or (cmdline and (cmdline:find("/nb") or cmdline:find("nb ")))
        or (cwd and cwd:find("%.nb"))
end

local function is_ssh_process(process_name, cmdline, user_vars)
    if user_vars.ssh_host and user_vars.ssh_host ~= "" then
        return true, user_vars.ssh_host
    end
    if process_name:find("ssh") or (cmdline and cmdline:find("ssh")) then
        local host = cmdline and cmdline:match("ssh%s+([%w_%-%.]+)")
        return true, host
    end
    return false, nil
end

local function is_claude_process(process_name, pane_title)
    return process_name == "claude"
        or (pane_title and (pane_title:find("^✳") or pane_title:lower():find("claude")))
end

local function extract_project_name(cwd)
    if not cwd then return "-" end
    local home = os.getenv("HOME")
    if home and cwd:find("^" .. home) then
        cwd = cwd:gsub("^" .. home, "~")
    end
    if cwd:find("%.nb") then return "nb" end
    local _, project = cwd:match(".*/src/github.com/([^/]+)/([^/]+)")
    if project then return project end
    cwd = cwd:gsub("/$", "")
    return cwd:match("([^/]+)$") or cwd
end

local function get_icon_and_color(process_name, pane_title, cmdline, cwd, is_ssh, is_active, is_claude)
    if is_ssh then
        return ICONS.ssh, is_active and "#ffffff" or ICON_COLORS.ssh
    end
    if pane_title == "nvim" or process_name == "nvim" then
        return ICONS.neovim, ICON_COLORS.neovim
    end
    if is_nb_process(process_name, cmdline, cwd) then
        return ICONS.nb, ICON_COLORS.nb
    end
    if is_claude then
        return ICONS.claude, ICON_COLORS.claude
    end
    if process_name == "docker" or (pane_title and pane_title:find("docker")) then
        return ICONS.docker, ICON_COLORS.docker
    end
    return ICONS.fallback, TAB_COLORS.foreground_inactive
end

local function get_tab_colors(is_active, is_ssh)
    if is_active and is_ssh then
        return TAB_COLORS.background_ssh_active, TAB_COLORS.foreground_ssh_active
    elseif is_active then
        return TAB_COLORS.background_active, TAB_COLORS.foreground_active
    end
    return TAB_COLORS.background_inactive, TAB_COLORS.foreground_inactive
end

local function has_zoomed_pane(panes)
    for _, p in ipairs(panes) do
        if p.is_zoomed then return true end
    end
    return false
end

-- =============================================================================
-- メイン
-- =============================================================================

function M.apply(config)
    local title_cache    = {}
    local raw_cwd_cache  = {}
    local ssh_host_cache = {}
    local claude_cache   = {}

    wezterm.on("update-status", function(_, pane)
        local pane_id   = pane:pane_id()
        local user_vars = pane.user_vars or {}

        if not (user_vars.ssh_host and user_vars.ssh_host ~= "") then
            local cwd_url = pane:get_current_working_dir()
            local cwd = cwd_url and cwd_url.file_path
            if cwd ~= raw_cwd_cache[pane_id] then
                raw_cwd_cache[pane_id] = cwd
                title_cache[pane_id]   = extract_project_name(cwd)
            end
        end

        local process_name = basename(pane:get_foreground_process_name() or "")
        local pane_title   = pane:get_title() or ""
        if is_claude_process(process_name, pane_title) then
            claude_cache[pane_id] = true
        elseif (process_name == "zsh" or process_name == "bash" or process_name == "fish")
            and not (pane_title:find("^✳") or pane_title:lower():find("claude")) then
            claude_cache[pane_id] = nil
        end
    end)

    wezterm.on("format-tab-title", function(tab, _, _, _, _, max_width)
        local pane             = tab.active_pane
        local pane_id          = pane.pane_id
        local process_name     = basename(pane.foreground_process_name)
        local pane_title       = pane.title or ""
        local cmdline          = pane.foreground_process_name or ""
        local user_vars        = pane.user_vars or {}
        local cached_cwd       = title_cache[pane_id] or ""

        local is_ssh, ssh_host = is_ssh_process(process_name, cmdline, user_vars)
        if is_ssh and ssh_host then
            ssh_host_cache[pane_id] = ssh_host
        elseif not is_ssh then
            ssh_host_cache[pane_id] = nil
        end

        local is_claude = claude_cache[pane_id] or false
        local bg, fg    = get_tab_colors(tab.is_active, is_ssh)

        local custom    = M.custom_title[tab.tab_id]
            or (tab.tab_title ~= "" and tab.tab_title or nil)
        local title_text
        if custom then
            title_text = custom
        elseif is_ssh then
            title_text = ssh_host_cache[pane_id] or "ssh"
        elseif is_nb_process(process_name, cmdline, cached_cwd) then
            title_text = "nb"
        else
            title_text = title_cache[pane_id] or "-"
        end

        local claude_suffix = ""
        if not custom and is_claude and pane_title ~= "" then
            claude_suffix = " " .. pane_title
        end

        local icon, icon_color = get_icon_and_color(
            process_name, pane_title, cmdline, cached_cwd, is_ssh, tab.is_active, is_claude
        )
        local zoom             = has_zoomed_pane(tab.panes) and (ICONS.zoom .. " ") or ""
        local left_margin      = tab.tab_index == 0 and " " or ""
        local inner_pad        = "  "
        local tab_spacing      = "  "
        local title            = inner_pad .. wezterm.truncate_right(title_text, max_width)
        local suffix           = wezterm.truncate_right(claude_suffix, max_width) .. inner_pad

        if tab.is_active then
            return {
                { Background = { Color = BAR_BG } },
                { Text = left_margin },
                { Foreground = { Color = bg } },
                { Text = DECO.left },
                { Background = { Color = bg } },
                { Foreground = { Color = icon_color } },
                { Text = icon },
                { Foreground = { Color = fg } },
                { Text = zoom },
                { Attribute = { Intensity = "Bold" } },
                { Text = title },
                { Attribute = { Intensity = "Normal" } },
                { Text = suffix },
                { Background = { Color = BAR_BG } },
                { Foreground = { Color = bg } },
                { Text = DECO.right .. tab_spacing },
            }
        else
            return {
                { Background = { Color = BAR_BG } },
                { Text = left_margin },
                { Foreground = { Color = TAB_COLORS.foreground_inactive } },
                { Text = inner_pad .. icon },
                { Text = zoom },
                { Text = title .. tab_spacing },
            }
        end
    end)

    config.enable_tab_bar                 = true
    config.use_fancy_tab_bar              = true
    config.hide_tab_bar_if_only_one_tab   = true
    config.show_new_tab_button_in_tab_bar = false
    config.tab_max_width                  = 32
    config.window_frame = {
        font      = wezterm.font("MesloLGS Nerd Font", { weight = "Regular" }),
        font_size = 13.0,
        active_titlebar_bg   = BAR_BG,
        inactive_titlebar_bg = BAR_BG,
    }
    config.colors = {
        tab_bar = { background = BAR_BG },
    }
end

return M
