return {
  "HiPhish/rainbow-delimiters.nvim",
  event = { "BufReadPost", "BufNewFile" },
  main = "rainbow-delimiters.setup",
  dependencies = {
    "so1ve/tiny-treesitter.nvim",
  },
  opts = {
    blacklist = {
      "html",
      "htmldjango",
      "templ",
      "xml",
    },
  },
}
