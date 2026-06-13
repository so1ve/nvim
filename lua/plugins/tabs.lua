return {
  {
    "tiagovla/scope.nvim",
    lazy = false,
    config = true,
  },
  {
    "stevearc/stickybuf.nvim",
    event = "VeryLazy",
    opts = {},
  },
  {
    "nvimtools/hydra.nvim",
    event = "VeryLazy",
    config = function()
      local Hydra = require("integrations.hydra")

      Hydra({
        name = "Tab",
        mode = "n",
        body = "<leader><Tab>",
        heads = {
          { "h", "<cmd>tabprevious<cr>", { desc = "Previous", group = "Move" } },
          { "l", "<cmd>tabnext<cr>", { desc = "Next", group = "Move" } },
          { "H", "<cmd>tabmove -1<cr>", { desc = "Move left", group = "Move" } },
          { "L", "<cmd>tabmove +1<cr>", { desc = "Move right", group = "Move" } },
          { "n", "<cmd>tabnew<cr>", { desc = "New", group = "Open" } },
          { "s", "<cmd>tab split<cr>", { desc = "Split here", group = "Open" } },
          { "c", "<cmd>tabclose<cr>", { desc = "Close", group = "Close" } },
          { "o", "<cmd>tabonly<cr>", { desc = "Close others", group = "Close" } },
        },
      })
    end,
  },
}
