-- Keep MiniSnippets: nested sessions are required so snippets can expand inside active snippets.
-- could be replaced by native vim.snippet after upgrading to nvim 0.13
-- (that's why I move from mini.snippets -> vim.snippet and then back to mini.snippets btw)
local M = {}

function M.setup()
  local snippets = require("mini.snippets")
  local gen_loader = snippets.gen_loader

  snippets.setup({
    snippets = {
      gen_loader.from_lang({
        lang_patterns = {
          javascriptreact = { "**/javascript.json" },
          typescript = { "**/javascript.json" },
          typescriptreact = { "**/javascript.json" },
          vue = { "**/vue.json", "**/javascript.json" },
        },
      }),
    },
    mappings = {
      expand = "",
      jump_next = "",
      jump_prev = "",
    },
    expand = {
      insert = function(snippet)
        return snippets.default_insert(snippet, {
          empty_tabstop = "",
          empty_tabstop_final = "",
        })
      end,
    },
  })

  vim.api.nvim_create_autocmd("ModeChanged", {
    pattern = "*:n",
    callback = function()
      while snippets.session.get() do
        snippets.session.stop()
      end
    end,
  })
end

return M
