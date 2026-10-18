local ok, theme = pcall(require, 'github-theme')
if ok then
  theme.setup({
    transparent = true,
    comment_style = 'NONE',
    function_style = 'NONE',
    keyword_style = 'NONE',
  })
end

vim.cmd([[
  autocmd ColorScheme * highlight Normal ctermbg=none guibg=none
  autocmd ColorScheme * highlight NonText ctermbg=none guibg=none
  autocmd ColorScheme * highlight LineNr ctermbg=none guibg=none
  autocmd ColorScheme * highlight Folded ctermbg=none guibg=none
  autocmd ColorScheme * highlight EndOfBuffer ctermbg=none guibg=none
]])
