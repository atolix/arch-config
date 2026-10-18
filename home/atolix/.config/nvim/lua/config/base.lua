-- Keymap Summary:
-- +-----------+-------------------------------+
-- | Keybinding| Action                        |
-- +-----------+-------------------------------+
-- | <C-h>     | Horizontal split window       |
-- | <C-v>     | Vertical split window         |
-- | <C-o>     | Move to previous buffer       |
-- | <C-p>     | Move to next buffer           |
-- | <C-f>     | Open FzfLua file finder       |
-- | <C-b>     | Open FzfLua buffer list       |
-- | <C-g>     | Open FzfLua live grep         |
-- | <C-[>     | Jump to definition            |
-- | <C-]>     | Jump to references            |
-- +-----------+-------------------------------+

vim.opt.clipboard:append({ 'unnamedplus' })
vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.fileencoding = "utf-8"
vim.opt.hidden = true
vim.opt.number = true
vim.opt.pumblend = 20
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.termguicolors = true
vim.opt.winblend = 30

vim.opt.showmode = false
vim.opt.laststatus = 0
vim.opt.cmdheight = 0
vim.opt.statusline = "─"
vim.opt.ruler = false
vim.opt.fillchars:append({ stl = "─", stlnc = "─" })

vim.keymap.set('n', '<C-h>', '<cmd>split<CR>') -- `ctrl + h` -> Horizontal split window
vim.keymap.set('n', '<C-v>', '<cmd>vsplit<CR>') -- `ctrl + v` -> Vertical split window
