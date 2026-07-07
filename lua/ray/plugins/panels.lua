local function trouble_filter(position)
  return function(_, win)
    local trouble = vim.w[win].trouble

    return trouble
      and trouble.position == position
      and trouble.type == "split"
      and trouble.relative == "editor"
      and not vim.w[win].trouble_preview
  end
end

return {
  "so1ve/panels.nvim",
  opts = {
    panels = {
      ["grug-far"] = {
        title = "Search & Replace",
        position = "right",
        ft = "grug-far",
      },
      ["neotest.output"] = {
        title = "Neotest Output",
        position = "bottom",
        ft = "neotest-output-panel",
        size = 15,
      },
      ["neotest.summary"] = {
        title = "Neotest",
        position = "left",
        ft = "neotest-summary",
        wo = { winbar = false },
      },
      ["overseer.list"] = {
        title = "Tasks",
        position = "bottom",
        ft = "OverseerList",
      },
      ["overseer.output"] = {
        title = "Task Output",
        position = "bottom",
        ft = "OverseerOutput",
      },
      ["sidekick.cli"] = {
        title = "AI CLI",
        position = "right",
        ft = "sidekick_terminal",
        size = 1 / 3,
        wo = { winbar = false },
      },
      ["snacks.terminal"] = {
        title = "Terminal",
        position = "bottom",
        ft = "snacks_terminal",
        filter = function(_, win)
          local snacks_win = vim.w[win].snacks_win

          return snacks_win and snacks_win.position == "bottom" and snacks_win.relative == "editor"
        end,
      },
      ["trouble.lsp"] = {
        title = "LSP",
        position = "right",
        ft = "trouble",
        filter = trouble_filter("right"),
      },
      ["trouble.problems"] = {
        title = "Problems",
        position = "bottom",
        ft = "trouble",
        filter = trouble_filter("bottom"),
      },
      help = {
        title = "Help",
        position = "bottom",
        ft = "help",
        size = 20,
        filter = function(buf)
          return vim.bo[buf].buftype == "help"
        end,
      },
      quickfix = {
        title = "Quickfix",
        position = "bottom",
        ft = "qf",
      },
      terminal = {
        title = "Terminal Buffer",
        position = "bottom",
        ft = "",
        filter = function(buf)
          return vim.bo[buf].buftype == "terminal"
        end,
      },
    },
  },
}
