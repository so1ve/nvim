return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPost", "BufWritePost" },
  opts = {
    linters_by_ft = require("config.languages").linters_by_ft(),
  },
  config = function(_, opts)
    local lint = require("lint")

    lint.linters_by_ft = opts.linters_by_ft

    vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
      group = vim.api.nvim_create_augroup("RayLint", { clear = true }),
      callback = function()
        lint.try_lint()
      end,
    })
  end,
}
