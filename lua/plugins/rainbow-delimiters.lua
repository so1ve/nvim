return {
  "HiPhish/rainbow-delimiters.nvim",
  event = { "BufReadPost", "BufNewFile" },
  main = "rainbow-delimiters.setup",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
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
