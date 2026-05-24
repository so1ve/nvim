return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  opts = {
    check_ts = true,
  },
  config = function(_, opts)
    local npairs = require("nvim-autopairs")
    local rust_lifetime_quote = require("utils.rust-lifetime-quote")

    npairs.setup(opts)

    for _, rule in ipairs(npairs.get_rules("'")) do
      if vim.list_contains(rule.filetypes or {}, "rust") then
        rule:with_pair(rust_lifetime_quote.with_pair, 1)
      end
    end
  end,
}
