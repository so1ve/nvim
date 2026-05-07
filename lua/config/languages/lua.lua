return {
  languages = {
    lua = {
      treesitter = "lua",
      lsp = { "lua_ls" },
      tools = { "stylua" },
      formatters = { "stylua" },
    },
  },
  servers = {
    lua_ls = {
      settings = {
        Lua = {
          completion = {
            callSnippet = "Replace",
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
            library = { vim.env.VIMRUNTIME },
          },
        },
      },
    },
  },
}
