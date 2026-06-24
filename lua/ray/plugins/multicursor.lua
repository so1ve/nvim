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
    local Hydra = require("ray.integrations.hydra")
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
        {
          "a",
          function()
            local mode = vim.fn.mode()
            local cursor = vim.fn.getpos(".")
            local anchor = vim.fn.getpos("v")

            mc.matchAllAddCursors()

            if mode == "n" then
              mc.feedkeys("e")
              return
            end

            local cursor_before_anchor = cursor[2] < anchor[2] or (cursor[2] == anchor[2] and cursor[3] < anchor[3])
            local start = cursor_before_anchor and cursor or anchor
            local row = cursor[2] - start[2]
            local col = cursor[3] - (row == 0 and start[3] or 1)

            mc.action(function(ctx)
              ctx:forEachCursor(function(curr)
                curr:setPos({
                  curr:line() + row,
                  row == 0 and curr:col() + col or col + 1,
                })
              end)
            end)
          end,
          { desc = "All", exit = true, group = "Add" },
        },
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
