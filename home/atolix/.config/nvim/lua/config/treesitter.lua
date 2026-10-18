local ok, configs = pcall(require, 'nvim-treesitter.configs')
if not ok then
  return
end

configs.setup({
  auto_install = true,
  endwise = { enable = true },
  ensure_installed = {
    'ruby',
    'elixir',
    'lua',
    'vim',
    'go',
    'rust',
    'typescript',
  },
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  indent = { enable = true },
  sync_install = true,
})
