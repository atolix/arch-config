-- Desktop services are managed by Home Manager's session target.
hl.on("hyprland.start", function()
    hl.exec_cmd("@SESSION_START@")
end)

hl.env("QT_IM_MODULE", "fcitx")
hl.env("GTK_THEME", "Adwaita:dark")
hl.env("GTK_APPLICATION_PREFER_DARK_THEME", "1")
hl.env("XMODIFIERS", "@im=fcitx")
hl.env("INPUT_METHOD", "fcitx")

hl.bind("SUPER + G", hl.dsp.exec_cmd("ghostty"))
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + CTRL + Q", hl.dsp.exec_cmd("hyprlock"))
hl.bind("SUPER + F", hl.dsp.exec_cmd("thunar"))
hl.bind("SUPER + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind("SUPER + R", hl.dsp.exec_cmd('wofi --show drun --prompt ""'))
hl.bind("SUPER + SHIFT + C", hl.dsp.exec_cmd("@LINUX_CONFIG_DIR@/quickshell/scripts/clipboard-picker.sh"))
for i = 1, 5 do
    hl.bind("SUPER + " .. i, hl.dsp.focus({ workspace = i }))
end
hl.bind("CTRL + S", hl.dsp.exec_cmd("@LINUX_CONFIG_DIR@/quickshell/scripts/window-switcher.py"))
hl.bind("SUPER + SHIFT + 4", hl.dsp.exec_cmd("@LINUX_CONFIG_DIR@/quickshell/scripts/screenshot.sh"))
hl.bind("SUPER + SHIFT + 5", hl.dsp.exec_cmd("@LINUX_CONFIG_DIR@/quickshell/scripts/screen-record.sh"))
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })
dofile("@HOME@/.config/hypr/hyprland-osd.lua")

hl.window_rule({ name = "ghostty-no-blur", match = { class = "com.mitchellh.ghostty" }, no_blur = true })
hl.window_rule({ name = "chromium-defaults", match = { class = "chromium" }, no_blur = true, size = "1100 650", center = true })

hl.config({
    general = {
        gaps_in = 0,
        gaps_out = 0,
        border_size = 0,
        col = { active_border = "rgba(5f73d9cc)", inactive_border = "rgba(30384fff)" },
        resize_on_border = false,
    },
    decoration = { rounding = 8 },
    input = {
        sensitivity = 0.5,
        kb_options = "ctrl:nocaps",
        touchpad = { tap_and_drag = false, drag_lock = false },
    },
})
