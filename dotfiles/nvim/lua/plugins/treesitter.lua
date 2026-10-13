-- 1.6 TREESITTER CONFIG
require("nvim-treesitter.config").setup({
  ensure_installed = { "go", "lua", "markdown", "vim", "rust", "haskell", "erlang" },
  highlight = { enable = true },
})