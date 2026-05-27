return {
  "folke/sidekick.nvim",
  event = "InsertEnter",
  keys = {
    {
      "<leader>aa",
      function()
        require("sidekick.cli").toggle({ name = "opencode", focus = true })
      end,
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
        enabled = vim.fn.has("win32") == 0,
      },
    },
  },
}
