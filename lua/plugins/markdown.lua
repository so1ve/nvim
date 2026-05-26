return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "noice_hover" },
    dependencies = {
      "nvim-mini/mini.nvim",
      "so1ve/tiny-treesitter.nvim",
    },
    opts = {
      file_types = { "markdown", "noice_hover" },
      heading = {
        backgrounds = {
          "RenderMarkdownH1Bg",
          "RenderMarkdownH2Bg",
          "RenderMarkdownH3Bg",
          "RenderMarkdownH4Bg",
          "RenderMarkdownH5Bg",
          "RenderMarkdownH6Bg",
        },
        foregrounds = {
          "RenderMarkdownH1",
          "RenderMarkdownH2",
          "RenderMarkdownH3",
          "RenderMarkdownH4",
          "RenderMarkdownH5",
          "RenderMarkdownH6",
        },
      },
      bullet = {
        enabled = false,
      },
      overrides = {
        filetype = {
          noice_hover = {
            render_modes = true,
            bullet = { enabled = false },
            checkbox = { enabled = false },
            code = { enabled = false },
            dash = { enabled = false },
            document = { enabled = false },
            heading = { enabled = true },
            html = { enabled = false },
            indent = { enabled = false },
            inline_highlight = { enabled = true },
            latex = { enabled = false },
            link = { enabled = false },
            paragraph = { enabled = false },
            pipe_table = { enabled = false },
            quote = { enabled = true },
            sign = { enabled = true },
          },
        },
      },
    },
    config = function(_, opts)
      vim.treesitter.language.register("markdown", "noice_hover")

      require("render-markdown").setup(opts)
    end,
  },
  {
    "YousefHadder/markdown-plus.nvim",
    ft = "markdown",
    opts = {
      keymaps = {
        enabled = false,
      },
    },
  },
}
