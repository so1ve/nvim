local edgy = require("ray.integrations.edgy")

local cli_view = edgy.view("AI CLI", "sidekick_terminal", {
  filter = function(_, win)
    return vim.api.nvim_win_get_config(win).relative == ""
  end,
  size = { width = 1 / 3 },
  wo = { winbar = false },
})

return {
  {
    "folke/sidekick.nvim",
    event = "InsertEnter",
    keys = {
      {
        "<leader>a.",
        function()
          require("sidekick.cli").focus()
        end,
        desc = "Focus AI CLI",
      },
      {
        "<leader>ao",
        edgy.with_focus(cli_view, function()
          require("sidekick.cli").toggle({ name = "opencode" })
        end),
        desc = "Toggle OpenCode",
      },
      -- {
      --   "<leader>as",
      --   function()
      --     require("sidekick.cli").select()
      --   end,
      --   desc = "Select AI CLI",
      -- },
      {
        "<leader>ad",
        function()
          require("sidekick.cli").close()
        end,
        desc = "Detach AI CLI",
      },
      {
        "<leader>ap",
        function()
          require("sidekick.cli").prompt()
        end,
        mode = { "n", "x" },
        desc = "Select AI Prompt",
      },
      {
        "<leader>at",
        function()
          require("sidekick.cli").send({ msg = "{this}" })
        end,
        mode = { "n", "x" },
        desc = "Send This to AI",
      },
      {
        "<leader>af",
        function()
          require("sidekick.cli").send({ msg = "{file}" })
        end,
        desc = "Send File to AI",
      },
      {
        "<leader>av",
        function()
          require("sidekick.cli").send({ msg = "{selection}" })
        end,
        mode = "x",
        desc = "Send Selection to AI",
      },
    },
    opts = {
      nes = {
        debounce = 350,
        trigger = {
          events = { "TextChangedI", "CursorHoldI", "TextChanged", "ModeChanged i:n", "User SidekickNesDone" },
        },
        clear = {
          events = { "TextChangedI", "TextChanged" },
          esc = true,
        },
      },
      cli = {
        mux = {
          backend = "zellij",
          enabled = true,
        },
      },
    },
    config = function(_, opts)
      require("ray.patch.sidekick").patch()
      require("sidekick").setup(opts)
    end,
  },
  edgy.view_spec("right", cli_view),
}
