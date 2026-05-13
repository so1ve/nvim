return {
  "saghen/blink.pairs",
  version = "*",
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = { "saghen/blink.lib" },
  opts = {
    highlights = {
      groups = {
        "BlinkPairsRed",
        "BlinkPairsYellow",
        "BlinkPairsBlue",
        "BlinkPairsOrange",
        "BlinkPairsGreen",
        "BlinkPairsMagenta",
        "BlinkPairsCyan",
      },
    },
  },
}
