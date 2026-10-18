local osdControl = "@LINUX_CONFIG_DIR@/quickshell/scripts/osd-control.py"
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(osdControl .. " volume down"), { locked = true, repeating = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(osdControl .. " volume up"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(osdControl .. " volume mute"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(osdControl .. " brightness up"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(osdControl .. " brightness down"), { locked = true, repeating = true })
