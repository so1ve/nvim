return {
  "jake-stewart/multicursor.nvim",
  branch = "1.0",
  dependencies = {
    "nvimtools/hydra.nvim",
  },
  keys = {
    { "<leader>m", mode = { "n", "x" }, desc = "Multicursor Hydra" },
    { "<C-leftmouse>", mode = "n", desc = "Add cursor with mouse" },
    { "<C-leftdrag>", mode = "n", desc = "Drag cursor with mouse" },
    { "<C-leftrelease>", mode = "n", desc = "Release cursor with mouse" },
  },
  config = function()
    local Hydra = require("integrations.hydra")
    local mc = require("multicursor-nvim")

    mc.setup()

    local append_at_line_end = function()
      mc.action(function(ctx)
        ctx:forEachCursor(function(cursor)
          cursor:feedkeys("$")
        end)
      end)
      mc.feedkeys("a")
    end

    Hydra({
      name = "Multicursor",
      mode = { "n", "x" },
      body = "<leader>m",
      config = {
        on_exit = function()
          if mc.hasCursors() and not mc.cursorsEnabled() then
            mc.enableCursors()
          end
        end,
      },
      heads = {
        { "t", mc.toggleCursor, { desc = "Toggle", group = "Actions" } },
      },
    })

    vim.keymap.set("n", "<C-leftmouse>", mc.handleMouse, { desc = "Add cursor with mouse" })
    vim.keymap.set("n", "<C-leftdrag>", mc.handleMouseDrag, { desc = "Drag cursor with mouse" })
    vim.keymap.set("n", "<C-leftrelease>", mc.handleMouseRelease, { desc = "Release cursor with mouse" })
    vim.keymap.set("n", "<Esc>", function()
      if mc.hasCursors() then
        mc.clearCursors()
      else
        vim.cmd("nohlsearch")
      end
    end, { desc = "Clear search highlight or multicursors" })

    mc.addKeymapLayer(function(layer_map)
      layer_map("n", "A", append_at_line_end)
      layer_map("x", "I", mc.insertVisual)
      layer_map("x", "A", mc.appendVisual)
      layer_map("n", "<Esc>", function()
        if not mc.cursorsEnabled() then
          mc.enableCursors()
        else
          mc.clearCursors()
        end
      end)
    end)
  end,
}
