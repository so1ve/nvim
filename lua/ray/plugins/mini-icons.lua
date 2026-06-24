return {
  "mini.icons",
  virtual = true,
  dependencies = { "nvim-mini/mini.nvim" },
  lazy = false,
  priority = 1000,
  config = function()
    local icons = require("mini.icons")

    local tsconfig_icon = { glyph = "", hl = "MiniIconsAzure" }

    icons.setup({
      file = {
        ["package.json"] = { glyph = "", hl = "MiniIconsRed" },
        ["tsconfig.json"] = tsconfig_icon,
      },
    })

    local get_icon = icons.get
    icons.get = function(category, name)
      if category == "file" and type(name) == "string" then
        local basename = vim.fn.fnamemodify(name, ":t")
        if basename:match("^tsconfig") then
          return tsconfig_icon.glyph, tsconfig_icon.hl, false
        end
      end

      return get_icon(category, name)
    end

    icons.mock_nvim_web_devicons()
  end,
}
