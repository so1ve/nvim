return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPost", "BufWritePost" },
  opts = {
    linters_by_ft = require("config.languages").map("linters"),
  },
  config = function(_, opts)
    local lint = require("lint")

    lint.linters_by_ft = opts.linters_by_ft

    vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
      callback = function()
        lint.try_lint()
      end,
    })
  end,
}
