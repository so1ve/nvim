return {
  languages = {
    lua = {
      treesitter = "lua",
      lsp = { "lua_ls" },
      tools = { "stylua" },
      formatters = { "stylua" },
    },
  },
  plugins = {
    {
      "folke/lazydev.nvim",
      ft = "lua",
      opts = {
        library = {
          { path = "${3rd}/luv/library", words = { "vim%.uv" } },
          { path = "snacks.nvim", words = { "Snacks" } },
          { path = "wezterm-types", mods = { "wezterm" } },
        },
      },
    },
    { "DrKJeff16/wezterm-types", lazy = true },
    { "Bilal2453/luvit-meta", lazy = true },
  },
  servers = {
    lua_ls = {
      settings = {
        Lua = {
          completion = {
            callSnippet = "Replace",
          },
          codeLens = {
            enable = true,
          },
          diagnostics = {
            globals = { "vim" },
          },
          runtime = {
            path = { "lua/?.lua", "lua/?/init.lua" },
            version = "LuaJIT",
          },
          telemetry = {
            enable = false,
          },
          workspace = {
            checkThirdParty = false,
          },
          doc = {
            privateName = { "^_" },
          },
          hint = {
            enable = true,
            setType = false,
            paramType = true,
            paramName = "Disable",
            semicolon = "Disable",
            arrayIndex = "Disable",
          },
        },
      },
    },
  },
}
