return {
  {
    "nvimtools/hydra.nvim",
  },
  {
    "saghen/filler-begone.nvim",
    event = "VeryLazy",
  },
  {
    "mrjones2014/codesettings.nvim",
    lazy = false,
    opts = {
      loader_extensions = {
        "codesettings.extensions.vscode",
        "ray.integrations.codesettings",
      },
      live_reload = true,
    },
  },
}
