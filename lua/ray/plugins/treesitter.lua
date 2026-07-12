local languages = require("ray.config.languages")

return {
  {
    "so1ve/tiny-treesitter.nvim",
    lazy = false,
    opts = {
      ensure_installed = languages.collect("treesitter", {
        extra = {
          "bash",
          "diff",
          "gitcommit",
          "lua",
          "markdown",
          "markdown_inline",
          "regex",
          "vim",
        },
        fallback = vim.treesitter.language.get_lang,
      }),
      auto_install = true,
    },
    config = function(_, opts)
      require("tiny-treesitter").setup(opts)

      local aliases = {}
      for filetype, language in pairs(languages.by_filetype) do
        local parser = language.treesitter
        if parser and parser ~= filetype then
          aliases[parser] = aliases[parser] or {}
          table.insert(aliases[parser], filetype)
        end
      end
      for parser, filetypes in pairs(aliases) do
        vim.treesitter.language.register(parser, filetypes)
      end

      vim.api.nvim_create_autocmd("FileType", {
        callback = function(event)
          local filetype = vim.bo[event.buf].filetype
          local parser = languages.get(filetype, "treesitter", vim.treesitter.language.get_lang)
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
    branch = "main",
    opts = {
      move = { set_jumps = true },
    },
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
