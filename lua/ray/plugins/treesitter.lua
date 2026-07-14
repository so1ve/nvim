local parser_overrides = {
  javascriptreact = "javascript",
  jsonc = "json",
  plaintex = "latex",
  ps1 = "powershell",
  tex = "latex",
  typescriptreact = "tsx",
  ["yaml.docker-compose"] = "yaml",
  ["yaml.github-actions"] = "yaml",
}

return {
  {
    "so1ve/tiny-treesitter.nvim",
    lazy = false,
    opts = {
      ensure_installed = {
        "bib",
        "c",
        "cpp",
        "css",
        "dockerfile",
        "go",
        "gomod",
        "gosum",
        "gotmpl",
        "gowork",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "latex",
        "powershell",
        "python",
        "rust",
        "scss",
        "toml",
        "typescript",
        "tsx",
        "typst",
        "vue",
        "yaml",
        "zig",
        "bash",
        "diff",
        "gitcommit",
        "markdown_inline",
        "regex",
        "vim",
      },
      auto_install = true,
    },
    config = function(_, opts)
      require("tiny-treesitter").setup(opts)

      for filetype, parser in pairs(parser_overrides) do
        vim.treesitter.language.register(parser, filetype)
      end

      vim.api.nvim_create_autocmd("FileType", {
        callback = function(event)
          local filetype = vim.bo[event.buf].filetype
          local parser = parser_overrides[filetype] or vim.treesitter.language.get_lang(filetype)
          if parser and vim.treesitter.language.add(parser) == true then
            vim.treesitter.start(event.buf, parser)
          end
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      max_lines = 4,
      mode = "topline",
      multiline_threshold = 4,
    },
    keys = {
      {
        "gC",
        function()
          require("treesitter-context").go_to_context(vim.v.count1)
        end,
        desc = "Go to sticky context",
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    keys = {
      {
        "]f",
        function()
          require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer")
        end,
        mode = { "n", "x", "o" },
        desc = "Next function start",
      },
      {
        "[f",
        function()
          require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer")
        end,
        mode = { "n", "x", "o" },
        desc = "Previous function start",
      },
      {
        "]F",
        function()
          require("nvim-treesitter-textobjects.move").goto_next_end("@function.outer")
        end,
        mode = { "n", "x", "o" },
        desc = "Next function end",
      },
      {
        "[F",
        function()
          require("nvim-treesitter-textobjects.move").goto_previous_end("@function.outer")
        end,
        mode = { "n", "x", "o" },
        desc = "Previous function end",
      },
      {
        "]a",
        function()
          require("nvim-treesitter-textobjects.move").goto_next_start("@parameter.inner")
        end,
        mode = { "n", "x", "o" },
        desc = "Next parameter",
      },
      {
        "[a",
        function()
          require("nvim-treesitter-textobjects.move").goto_previous_start("@parameter.inner")
        end,
        mode = { "n", "x", "o" },
        desc = "Previous parameter",
      },
      {
        "]A",
        function()
          require("nvim-treesitter-textobjects.swap").swap_next("@parameter.inner")
        end,
        desc = "Swap next parameter",
      },
      {
        "[A",
        function()
          require("nvim-treesitter-textobjects.swap").swap_previous("@parameter.inner")
        end,
        desc = "Swap previous parameter",
      },
    },
  },
  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
  },
}
