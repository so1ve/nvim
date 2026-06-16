local ignore = require("ray.config.ignore")
local show_hidden = false

return {
  "mini.files",
  virtual = true,
  dependencies = { "nvim-mini/mini.nvim" },
  lazy = false,
  config = function()
    local files = require("mini.files")

    vim.api.nvim_set_hl(0, "MiniFilesHidden", { link = "Comment", default = true })

    local opts = {
      content = {
        filter = function(entry)
          return show_hidden or not ignore.is_ignored(entry.path or entry.name)
        end,
        highlight = function(entry)
          if ignore.is_ignored(entry.path or entry.name) then
            return "MiniFilesHidden"
          end

          return files.default_highlight(entry)
        end,
      },
      mappings = {
        synchronize = "s",
      },
    }

    files.setup(opts)

    vim.api.nvim_create_autocmd("User", {
      pattern = "MiniFilesBufferCreate",
      callback = function(args)
        vim.keymap.set("n", "gh", function()
          show_hidden = not show_hidden
          require("mini.files").refresh(opts)
        end, { buffer = args.data.buf_id, desc = "Toggle hidden entries" })
      end,
    })

    vim.keymap.set("n", "<leader>e", files.open, { desc = "Explore files" })
  end,
}
