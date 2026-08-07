-- Hyprland 0.56 configuration migrated from hyprland.conf.

local mainMod = "SUPER"

-- Session-wide environment is loaded by UWSM from ~/.config/uwsm/env and
-- ~/.config/uwsm/env-hyprland before the compositor starts.

-- Keep hardware layout and host-specific autostart programs out of Git. A
-- machine.lua next to this file may return `monitors` and `autostart` tables.
local machine_loaded, machine = pcall(require, "machine")
if not machine_loaded then
    machine = {}
end

local monitors = machine.monitors or {
    {
        output = "",
        mode = "preferred",
        position = "auto",
        scale = "auto",
    },
}

for _, monitor in ipairs(monitors) do
    hl.monitor(monitor)
end

-- The hyprland.start event is emitted once per compositor start, not on every
-- config reload. UWSM finalization is portable; the remaining commands are
-- selected in the local machine file.
hl.on("hyprland.start", function()
    hl.exec_cmd("uwsm finalize")
    for _, command in ipairs(machine.autostart or {}) do
        hl.exec_cmd(command)
    end
end)

hl.config({
    xwayland = {
        force_zero_scaling = true,
    },

    cursor = {
        -- Current replacement for the old WLR_NO_HARDWARE_CURSORS variable.
        no_hardware_cursors = 1,
    },

    decoration = {
        rounding = 10,

        blur = {
            enabled = true,
            size = 8,
            passes = 2,
            new_optimizations = true,
            ignore_opacity = true,
            xray = false,
        },

        shadow = {
            enabled = true,
            range = 20,
            render_power = 3,
            color = "rgba(1a1a1aee)",
        },
    },

    animations = {
        enabled = true,
    },

    input = {
        -- Disable the Caps Lock modifier. The physical key is bound below by
        -- keycode so it remains usable even though XKB exposes VoidSymbol.
        kb_options = "caps:none",
        follow_mouse = 1,
    },

    dwindle = {
        preserve_split = true,
        force_split = 2,
    },

    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        mouse_move_enables_dpms = true,
        key_press_enables_dpms = true,
        vrr = 2,
        enable_swallow = true,
        -- Keep swallowing attached to the terminal that the config now starts.
        swallow_regex = "^(kitty)$",
    },
})

-- Curves and animation tree preserved from the old configuration.
hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.curve("overshot", { type = "bezier", points = { { 0.13, 0.99 }, { 0.29, 1.1 } } })
hl.curve("smoothOut", { type = "bezier", points = { { 0.36, 0 }, { 0.66, -0.56 } } })
hl.curve("smoothIn", { type = "bezier", points = { { 0.25, 1 }, { 0.5, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 5, bezier = "myBezier", style = "slide" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 5, bezier = "myBezier", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 5, bezier = "myBezier", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 5, bezier = "myBezier" })
hl.animation({ leaf = "fade", enabled = true, speed = 5, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "default" })
hl.animation({
    leaf = "specialWorkspace",
    enabled = true,
    speed = 5,
    bezier = "overshot",
    style = "slidefadevert -100%",
})

-- Window rules. Lua rules can carry all effects for one matcher in one table.
hl.window_rule({ match = { class = "^(kitty)$" }, opacity = "0.95 0.85" })
hl.window_rule({ match = { class = "^(thunar)$" }, opacity = "0.90 0.80" })
hl.window_rule({ match = { class = "^(copyq)$" }, opacity = "0.90 0.80" })

-- Center ordinary floating windows first. More specific rules below may
-- deliberately override the position (for example, the F12 dropdown).
hl.window_rule({ match = { float = true }, center = true })

hl.window_rule({
    match = { class = "^(clash-verge)$" },
    workspace = "special:clash-verge silent",
})

hl.window_rule({
    match = { title = "^\\$$" },
    float = true,
    workspace = "special:$ silent",
    size = { "monitor_w", "monitor_h * 0.66" },
    move = { 0, 0 },
    border_size = 0,
    rounding = 0
})

hl.window_rule({
    match = { title = "^(scratchpad-monitor)$" },
    float = true,
    workspace = "special:monitor silent",
    size = { "80%", "80%" },
    center = true,
})

hl.window_rule({ match = { class = "^(firefox)$" }, workspace = "2 silent" })
hl.window_rule({ match = { class = "^(chromium)$" }, workspace = "2 silent" })
hl.window_rule({ match = { class = "^(zen)$" }, workspace = "2 silent" })
hl.window_rule({ match = { class = "^(mattermost)$" }, workspace = "3 silent" })
hl.window_rule({ match = { class = "^(Mattermost)$" }, workspace = "3 silent" })
hl.window_rule({ match = { class = "^(code)$" }, workspace = "4 silent" })
hl.window_rule({ match = { class = "^(code-oss)$" }, workspace = "4 silent" })

hl.window_rule({ match = { class = "^(pavucontrol)$" }, float = true, center = true })
hl.window_rule({ match = { class = "^(nm-connection-editor)$" }, float = true, center = true })
hl.window_rule({ match = { class = "^(blueman-manager)$" }, float = true, center = true })
hl.window_rule({ match = { title = "^(Picture-in-Picture)$" }, float = true, center = true })

-- Launchers and basic controls.
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("wofi --show drun"))
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + SHIFT + Return", hl.dsp.exec_cmd("~/.config/hypr/scripts/tmux-terminal.sh"))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("~/.config/hypr/scripts/smart-launch.sh Mattermost mattermost-desktop"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("gtk-launch zen"))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("~/.config/hypr/scripts/smart-launch.sh code code"))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd("fcitx5-remote -t"))
-- Caps Lock's XKB keycode is 66. With caps:none it switches between the two
-- configured Fcitx5 methods (keyboard-us and pinyin) without locking case.
hl.bind("code:66", hl.dsp.exec_cmd("fcitx5-remote -t"))

-- Window management.
hl.bind(mainMod .. " + V", hl.dsp.window.float())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mainMod .. " + G", hl.dsp.group.toggle())
hl.bind(mainMod .. " + Tab", hl.dsp.group.next())
hl.bind(mainMod .. " + SHIFT + Tab", hl.dsp.group.prev())
hl.bind(mainMod .. " + P", hl.dsp.window.pin())
-- dwindle.pseudotile no longer exists; pseudotiling is now per-window.
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.window.pseudo())

-- Window hiding and minimizing.
hl.bind(mainMod .. " + minus", hl.dsp.exec_cmd("~/.config/hypr/scripts/hide-window.sh"))
hl.bind(mainMod .. " + SHIFT + minus", hl.dsp.exec_cmd("~/.config/hypr/scripts/toggle-hidden.sh"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("~/.config/hypr/scripts/minimize-window.sh"))
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.workspace.toggle_special("minimized"))
hl.bind(mainMod .. " + CTRL + minus", hl.dsp.window.move({ workspace = 99, follow = false }))
hl.bind(mainMod .. " + CTRL + equal", hl.dsp.focus({ workspace = 99 }))

-- Resize mode.
hl.bind(mainMod .. " + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
    hl.bind("H", hl.dsp.window.resize({ x = -20, y = 0, relative = true }), { repeating = true })
    hl.bind("L", hl.dsp.window.resize({ x = 20, y = 0, relative = true }), { repeating = true })
    hl.bind("K", hl.dsp.window.resize({ x = 0, y = -20, relative = true }), { repeating = true })
    hl.bind("J", hl.dsp.window.resize({ x = 0, y = 20, relative = true }), { repeating = true })
    hl.bind("Escape", hl.dsp.submap("reset"))
    hl.bind("Return", hl.dsp.submap("reset"))
end)

-- Focus and move windows with vim keys.
for key, direction in pairs({ H = "l", J = "d", K = "u", L = "r" }) do
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ direction = direction }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ direction = direction }))
end

-- Workspaces 1-10.
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i, follow = true }))
    hl.bind(mainMod .. " + ALT + " .. key, hl.dsp.window.move({ workspace = i, follow = false }))
end

hl.bind(mainMod .. " + bracketleft", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + bracketright", hl.dsp.focus({ workspace = "e+1" }))

-- Multi-monitor controls.
hl.bind(mainMod .. " + CTRL + H", hl.dsp.focus({ monitor = "l" }))
hl.bind(mainMod .. " + CTRL + L", hl.dsp.focus({ monitor = "r" }))
hl.bind(mainMod .. " + O", hl.dsp.focus({ monitor = "+1" }))
hl.bind(mainMod .. " + CTRL + SHIFT + H", hl.dsp.window.move({ monitor = "l", follow = true }))
hl.bind(mainMod .. " + CTRL + SHIFT + L", hl.dsp.window.move({ monitor = "r", follow = true }))

-- Scratchpads.
hl.bind("F12", hl.dsp.exec_cmd("~/.config/hypr/scripts/toggle-dropdown.sh"), { locked = true })
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd("~/.config/hypr/scripts/toggle-monitor.sh"))
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.workspace.toggle_special("clash-verge"))

-- Media and brightness keys. Both the legacy pamixer and PipeWire bindings are
-- retained because both were present in the old config.
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pamixer -i 5"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pamixer -d 5"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("pamixer -t"))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set +10%"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 10%-"))
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%+"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%-"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))

-- Screenshots.
hl.bind("Print", hl.dsp.exec_cmd("mkdir -p ~/Pictures/Screenshots && grim ~/Pictures/Screenshots/shot-$(date +%F_%H-%M-%S).png"))
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd("mkdir -p ~/Pictures/Screenshots && grim -g \"$(slurp)\" ~/Pictures/Screenshots/shot-$(date +%F_%H-%M-%S).png"))
