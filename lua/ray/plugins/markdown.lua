return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = "markdown",
    dependencies = {
      "nvim-mini/mini.nvim",
      "so1ve/tiny-treesitter.nvim",
    },
    opts = {
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
    },
  },
  {
    "so1ve/tiny-md.nvim",
    dependencies = {
      "MeanderingProgrammer/render-markdown.nvim",
    },
    opts = {
      render_markdown = {
        bullet = {
          enabled = true,
        },
        html = {
          comment = {
            conceal = false,
          },
        },
      },
    },
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
