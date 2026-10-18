local ok, oil = pcall(require, 'oil')
if ok then
  oil.setup({
    default_file_explorer = true,
    view_options = {
      show_hidden = true,
    },
    float = {
      padding = 2,
      max_height = 0.55,
      max_width = 0.50,
      border = "rounded",
      win_options = { winblend = 40 }
    },
  })
end

vim.keymap.set('n', '<C-n>', '<cmd>Oil --float<CR>')
