return {
  "mfussenegger/nvim-lint",
  event = "VeryLazy",
  opts = {
    linters_by_ft = require("config.languages").map("linters"),
  },
  config = function(_, opts)
    local lint = require("lint")

    lint.linters_by_ft = opts.linters_by_ft

    vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile", "BufWritePost", "InsertLeave" }, {
      callback = function(args)
        if vim.bo[args.buf].buftype ~= "" then
          return
        end

        lint.try_lint()
      end,
    })
  end,
}
