return {
  "jake-stewart/multicursor.nvim",
  branch = "1.0",
  keys = {
    { "<leader>mk", mode = { "n", "x" }, desc = "Add cursor above" },
    { "<leader>mj", mode = { "n", "x" }, desc = "Add cursor below" },
    { "<leader>mn", mode = { "n", "x" }, desc = "Add next match cursor" },
    { "<leader>mN", mode = { "n", "x" }, desc = "Add previous match cursor" },
    { "<leader>ms", mode = { "n", "x" }, desc = "Skip next match cursor" },
    { "<leader>mS", mode = { "n", "x" }, desc = "Skip previous match cursor" },
    { "<leader>mt", mode = { "n", "x" }, desc = "Toggle cursor" },
    { "<leader>mA", mode = { "n", "x" }, desc = "Add all match cursors" },
    { "<leader>m/", mode = "n", desc = "Add all search cursors" },
    { "<leader>ma", mode = "n", desc = "Align cursors" },
    { "<leader>mr", mode = "n", desc = "Restore cursors" },
    { "<leader>mh", mode = { "n", "x" }, desc = "Previous cursor" },
    { "<leader>ml", mode = { "n", "x" }, desc = "Next cursor" },
    { "<leader>mx", mode = { "n", "x" }, desc = "Delete cursor" },
    { "<C-leftmouse>", mode = "n", desc = "Add cursor with mouse" },
    { "<C-leftdrag>", mode = "n", desc = "Drag cursor with mouse" },
    { "<C-leftrelease>", mode = "n", desc = "Release cursor with mouse" },
  },
  config = function()
    local mc = require("multicursor-nvim")
    mc.setup()

    vim.keymap.set({ "n", "x" }, "<leader>mk", function()
      mc.lineAddCursor(-1)
    end, { desc = "Add cursor above" })
    vim.keymap.set({ "n", "x" }, "<leader>mj", function()
      mc.lineAddCursor(1)
    end, { desc = "Add cursor below" })
    vim.keymap.set({ "n", "x" }, "<leader>mn", function()
      mc.matchAddCursor(1)
    end, { desc = "Add next match cursor" })
    vim.keymap.set({ "n", "x" }, "<leader>mN", function()
      mc.matchAddCursor(-1)
    end, { desc = "Add previous match cursor" })
    vim.keymap.set({ "n", "x" }, "<leader>ms", function()
      mc.matchSkipCursor(1)
    end, { desc = "Skip next match cursor" })
    vim.keymap.set({ "n", "x" }, "<leader>mS", function()
      mc.matchSkipCursor(-1)
    end, { desc = "Skip previous match cursor" })
    vim.keymap.set({ "n", "x" }, "<leader>mt", mc.toggleCursor, { desc = "Toggle cursor" })
    vim.keymap.set({ "n", "x" }, "<leader>mA", mc.matchAllAddCursors, { desc = "Add all match cursors" })
    vim.keymap.set("n", "<leader>m/", mc.searchAllAddCursors, { desc = "Add all search cursors" })
    vim.keymap.set("n", "<leader>ma", mc.alignCursors, { desc = "Align cursors" })
    vim.keymap.set("n", "<leader>mr", mc.restoreCursors, { desc = "Restore cursors" })
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
      layer_map({ "n", "x" }, "<leader>mh", mc.prevCursor)
      layer_map({ "n", "x" }, "<leader>ml", mc.nextCursor)
      layer_map({ "n", "x" }, "<leader>mx", mc.deleteCursor)
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
