local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local function load_config(name)
  return function()
    require(('config.%s'):format(name))
  end
end

require("lazy").setup({
  -- UI & Appearance
  { 'projekt0n/github-nvim-theme', tag = 'v0.0.7' },
  { 'akinsho/bufferline.nvim' },
  { 'mvllow/modes.nvim', event = 'VeryLazy', config = load_config('modes') },
  { 'b0o/incline.nvim', event = 'VeryLazy', config = load_config('incline') },

  -- Code analysis & Completion
  { 'nvim-treesitter/nvim-treesitter', branch = 'master', lazy = false, build = ":TSUpdate" },
  { 'neovim/nvim-lspconfig' },
  { 'hrsh7th/nvim-cmp', dependencies = { 'hrsh7th/cmp-nvim-lsp', 'hrsh7th/cmp-path', 'L3MON4D3/LuaSnip' } },

  -- Git integration
  { 'lewis6991/gitsigns.nvim' },

  -- Navigation & File explorer
  { 'ibhagwan/fzf-lua' },
  { 'stevearc/oil.nvim', opts = {}, lazy = false },

  -- Utility tools
  { 'windwp/nvim-autopairs' },
})
