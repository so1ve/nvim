return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
    priority = 1000,
    opts = {
      flavour = "mocha",
      background = {
        light = "latte",
        dark = "mocha",
      },
      term_colors = true,
      default_integrations = true,
      auto_integrations = true,
    },
  },
  {
    "gbprod/nord.nvim",
    name = "nord",
    lazy = true,
    priority = 1000,
    opts = {
      transparent = false,
      terminal_colors = true,
      diff = {
        mode = "bg",
      },
      borders = true,
      styles = {
        comments = { italic = true },
      },
    },
  },
  {
    "folke/tokyonight.nvim",
    name = "tokyonight",
    lazy = true,
    priority = 1000,
    opts = {
      style = "night",
    },
  },
  {
    "rebelot/kanagawa.nvim",
    name = "kanagawa",
    lazy = true,
    priority = 1000,
    opts = {
      undercurl = true,
    },
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = true,
    priority = 1000,
    opts = {
      variant = "main",
    },
  },
  {
    "ellisonleao/gruvbox.nvim",
    name = "gruvbox",
    lazy = true,
    priority = 1000,
    opts = {
      terminal_colors = true,
    },
  },
  {
    "neanias/everforest-nvim",
    name = "everforest",
    lazy = true,
    priority = 1000,
    opts = {
      background = "medium",
    },
  },
  {
    "EdenEast/nightfox.nvim",
    name = "nightfox",
    lazy = true,
    priority = 1000,
  },
  {
    "projekt0n/github-nvim-theme",
    name = "github-theme",
    lazy = true,
    priority = 1000,
    opts = {},
  },
  {
    "nyoom-engineering/oxocarbon.nvim",
    name = "oxocarbon",
    lazy = true,
    priority = 1000,
  },
  {
    "savq/melange-nvim",
    name = "melange",
    lazy = true,
    priority = 1000,
  },
  {
    "marko-cerovac/material.nvim",
    name = "material",
    lazy = true,
    priority = 1000,
    opts = {},
  },
}
