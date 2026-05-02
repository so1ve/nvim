return {
  "folke/sidekick.nvim",
  event = "InsertEnter",
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
      },
    },
  },
}
