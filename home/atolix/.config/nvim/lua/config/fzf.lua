local ok, fzf = pcall(require, 'fzf-lua')
if ok then
  fzf.setup({
    winopts = {
      height = 0.85,
      width = 0.80,
      row = 0.35,
      col = 0.50,
      border = 'rounded',
      backdrop = 0.0,
    },
  })

  vim.cmd([[
    highlight FzfLuaNormal ctermbg=none guibg=none
    highlight FzfLuaBorder ctermbg=none guibg=none
  ]])
end

vim.keymap.set('n', '<C-f>', '<cmd>FzfLua files<CR>') -- `ctrl + f` -> Open FzfLua file finder
vim.keymap.set('n', '<C-b>', '<cmd>FzfLua buffers<CR>') -- `ctrl + b` -> Open FzfLua buffer list
vim.keymap.set('n', '<C-g>', '<cmd>FzfLua live_grep<CR>') -- `ctrl + g` -> Open FzfLua live grep search
