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

local function start_opencode_server()
  Snacks.terminal.open(opencode_cmd, terminal_opts)
end

local function stop_opencode_server()
  local opts = vim.tbl_deep_extend("force", {}, terminal_opts, { create = false })
  local terminal = Snacks.terminal.get(opencode_cmd, opts)

  if terminal then
    terminal:close()
  end
end

local function toggle_opencode_terminal()
  Snacks.terminal.toggle(opencode_cmd, terminal_opts)
end

return {
  "nickjvandyke/opencode.nvim",
  version = "*",
  keys = {
    {
      "<leader>oa",
      function()
        require("opencode").ask("@this: ", { submit = true })
      end,
      mode = { "n", "x" },
      desc = "Ask opencode",
    },
    {
      "<leader>oo",
      function()
        require("opencode").select()
      end,
      desc = "Select opencode action",
    },
    {
      "<leader>op",
      function()
        require("opencode").prompt("@this")
      end,
      mode = { "n", "x" },
      desc = "Prompt opencode",
    },
    {
      "<leader>ot",
      function()
        require("opencode").toggle()
      end,
      desc = "Toggle opencode terminal",
    },
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
        start = start_opencode_server,
        stop = stop_opencode_server,
        toggle = toggle_opencode_terminal,
      },
    }
  end,
}
