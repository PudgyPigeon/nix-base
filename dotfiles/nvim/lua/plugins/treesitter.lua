-- 1.6 TREESITTER CONFIG
require("nvim-treesitter.config").setup({
  ensure_installed = { "go", "lua", "markdown", "vim", "rust", "haskell", "erlang" },
  sync_install = false,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
})