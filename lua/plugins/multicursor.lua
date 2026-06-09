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

    Hydra({
      name = "Multicursor",
      mode = { "n", "x" },
      body = "<leader>m",
      heads = {
        {
          "j",
          function()
            mc.lineAddCursor(1)
          end,
          { desc = "Add below", group = "Lines" },
        },
        {
          "k",
          function()
            mc.lineAddCursor(-1)
          end,
          { desc = "Add above", group = "Lines" },
        },
        {
          "n",
          function()
            mc.matchAddCursor(1)
          end,
          { desc = "Add next", group = "Matches" },
        },
        {
          "N",
          function()
            mc.matchAddCursor(-1)
          end,
          { desc = "Add previous", group = "Matches" },
        },
        {
          "s",
          function()
            mc.matchSkipCursor(1)
          end,
          { desc = "Skip next", group = "Matches" },
        },
        {
          "S",
          function()
            mc.matchSkipCursor(-1)
          end,
          { desc = "Skip previous", group = "Matches" },
        },
        { "t", mc.toggleCursor, { desc = "Toggle", group = "Actions" } },
        { "A", mc.matchAllAddCursors, { desc = "All matches", group = "Actions" } },
        { "/", mc.searchAllAddCursors, { mode = "n", desc = "Search matches", group = "Actions" } },
        { "a", mc.alignCursors, { mode = "n", desc = "Align", group = "Utility" } },
        { "r", mc.restoreCursors, { mode = "n", desc = "Restore", group = "Utility" } },
        { "h", mc.prevCursor, { desc = "Previous cursor", group = "Lines" } },
        { "l", mc.nextCursor, { desc = "Next cursor", group = "Lines" } },
        { "x", mc.deleteCursor, { desc = "Delete", group = "Actions" } },
      },
    })

    vim.keymap.set("n", "<C-leftmouse>", mc.handleMouse, { desc = "Add cursor with mouse" })
    vim.keymap.set("n", "<C-leftdrag>", mc.handleMouseDrag, { desc = "Drag cursor with mouse" })
    vim.keymap.set("n", "<C-leftrelease>", mc.handleMouseRelease, { desc = "Release cursor with mouse" })

    local append_at_line_end = function()
      mc.action(function(ctx)
        ctx:forEachCursor(function(cursor)
          cursor:feedkeys("$")
        end)
      end)
      mc.feedkeys("a")
    end

    mc.addKeymapLayer(function(layer_map)
      layer_map("n", "A", append_at_line_end)
      layer_map("x", "I", mc.insertVisual)
      layer_map("x", "A", mc.appendVisual)
      layer_map("n", "<Esc>", function()
        if mc.cursorsEnabled() then
          mc.clearCursors()

          return
        end

        mc.enableCursors()
      end)
    end)
  end,
}
