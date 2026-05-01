return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPost", "BufWritePost", "InsertLeave" },
  config = function()
    local lint = require("lint")

    lint.linters_by_ft = {}

    vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
      group = vim.api.nvim_create_augroup("RayLint", { clear = true }),
      desc = "Run configured external linters",
      callback = function(args)
        local linters = lint.linters_by_ft[vim.bo[args.buf].filetype]
        if not linters or vim.tbl_isempty(linters) then
          return
        end

        lint.try_lint()
      end,
    })
  end,
}
