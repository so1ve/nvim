return {
  "HiPhish/rainbow-delimiters.nvim",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  init = function()
    vim.g.rainbow_delimiters = {
      blacklist = {
        "html",
        "htmldjango",
        "templ",
        "xml",
      },
    }
  end,
}
