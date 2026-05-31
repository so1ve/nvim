return {
  "so1ve/textobject-hud.nvim",
  dependencies = {
    "nvim-mini/mini.nvim",
    "nvim-treesitter/nvim-treesitter-textobjects",
  },
  cmd = {
    "TextobjectHud",
    "TextobjectHudInspect",
  },
  keys = {
    {
      "<leader>o",
      function()
        require("textobject-hud").open()
      end,
      desc = "Open textobject HUD",
    },
  },
  opts = function()
    local hud = require("textobject-hud")

    return {
      sources = {
        hud.sources.treesitter,
        hud.sources.mini_ai,
      },
      key_hints = {
        ["treesitter:@function.outer"] = { "]f", "[f", "]F", "[F" },
        ["treesitter:@parameter.inner"] = { "]a", "[a", "]A", "[A" },
      },
    }
  end,
}
