local opencode_cmd = "opencode --port"

local terminal_opts = {
  win = {
    position = "right",
    enter = false,
    on_win = function(win)
      require("opencode.terminal").setup(win.win)
    end,
  },
}

return {
  "nickjvandyke/opencode.nvim",
  version = "*",
  keys = {
    { "<leader>oa", function() require("opencode").ask("@this: ", { submit = true }) end, mode = { "n", "x" }, desc = "Ask opencode" },
    { "<leader>oo", function() require("opencode").select() end, desc = "Select opencode action" },
    { "<leader>op", function() require("opencode").prompt("@this") end, mode = { "n", "x" }, desc = "Prompt opencode" },
    { "<leader>ot", function() require("opencode").toggle() end, desc = "Toggle opencode terminal" },
  },
  dependencies = {
    {
      "folke/snacks.nvim",
      opts = {
        input = {},
        picker = {
          actions = {
            opencode_send = function(...)
              return require("opencode").snacks_picker_send(...)
            end,
          },
          win = {
            input = {
              keys = {
                ["<a-a>"] = { "opencode_send", mode = { "n", "i" } },
              },
            },
          },
        },
      },
    },
  },
  config = function()
    vim.g.opencode_opts = {
      server = {
        start = function()
          Snacks.terminal.open(opencode_cmd, terminal_opts)
        end,
        stop = function()
          local opts = vim.tbl_deep_extend("force", {}, terminal_opts, { create = false })
          local terminal = Snacks.terminal.get(opencode_cmd, opts)

          if terminal then
            terminal:close()
          end
        end,
        toggle = function()
          Snacks.terminal.toggle(opencode_cmd, terminal_opts)
        end,
      },
    }
  end,
}
