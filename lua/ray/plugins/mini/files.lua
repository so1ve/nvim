local ignore = require("ray.config.ignore")

local M = {}

function M.setup()
  local files = require("mini.files")

  files.setup({
    content = {
      filter = function(entry)
        return not ignore.is_ignored(entry.path or entry.name)
      end,
    },
  })

  vim.keymap.set("n", "<leader>e", files.open, { desc = "Explore files" })
end

return M
