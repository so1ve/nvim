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
    local key_hints = {
      ["treesitter:@assignment.inner"] = "i=",
      ["treesitter:@assignment.outer"] = "a=",
      ["treesitter:@block.inner"] = "ib",
      ["treesitter:@block.outer"] = "ab",
      ["treesitter:@call.inner"] = "iF",
      ["treesitter:@call.outer"] = "aF",
      ["treesitter:@class.inner"] = "ic",
      ["treesitter:@class.outer"] = "ac",
      ["treesitter:@comment.inner"] = "i/",
      ["treesitter:@comment.outer"] = "a/",
      ["treesitter:@conditional.inner"] = "ii",
      ["treesitter:@conditional.outer"] = "ai",
      ["treesitter:@function.inner"] = "if",
      ["treesitter:@function.outer"] = "af",
      ["treesitter:@loop.inner"] = "il",
      ["treesitter:@loop.outer"] = "al",
      ["treesitter:@parameter.inner"] = "ia",
      ["treesitter:@parameter.outer"] = "aa",
      ["treesitter:@return.inner"] = "ir",
      ["treesitter:@return.outer"] = "ar",
      ["treesitter:@statement.outer"] = "as",
    }
    local builtin_ids = {
      "w",
      "W",
      "s",
      "p",
      '"',
      "'",
      "`",
      "(",
      ")",
      "b",
      "[",
      "]",
      "{",
      "}",
      "B",
      "<",
      ">",
      "t",
    }
    local mini_ai_ids = {
      '"',
      "'",
      "`",
      "(",
      "[",
      "{",
      "<",
      "a",
      "b",
      "f",
      "q",
      "t",
    }

    for _, id in ipairs(builtin_ids) do
      key_hints["builtin:i" .. id] = "i" .. id
      key_hints["builtin:a" .. id] = "a" .. id
    end

    for _, id in ipairs(mini_ai_ids) do
      key_hints["mini_ai:i" .. id] = "i" .. id
      key_hints["mini_ai:a" .. id] = "a" .. id
    end

    return {
      sources = {
        hud.sources.builtin,
        hud.sources.treesitter,
        hud.sources.mini_ai,
      },
      key_hints = key_hints,
    }
  end,
}
