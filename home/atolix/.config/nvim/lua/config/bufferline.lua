local ok, bufferline = pcall(require, 'bufferline')
if ok then
  bufferline.setup({
    options = {
      style_preset = bufferline.style_preset.no_italic
    }
  })
end

vim.keymap.set('n', '<C-o>', '<cmd>bprev<CR>') -- `ctrl + o` -> Move to previous buffer
vim.keymap.set('n', '<C-p>', '<cmd>bnext<CR>') -- `ctrl + p` -> Move to next buffer
