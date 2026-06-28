local ignore = require("ray.config.ignore")
local show_hidden = false

return {
  "mini.files",
  virtual = true,
  dependencies = { "nvim-mini/mini.nvim" },
  lazy = false,
  config = function()
    local files = require("mini.files")

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
        go_in = "L",
        go_in_plus = "<C-l>",
        go_out = "H",
        go_out_plus = "<C-h>",
        synchronize = "s",
      },
      options = {
        lsp_timeout = 0,
      },
      windows = {
        preview = true,
        width_preview = 40,
      },
    }

    files.setup(opts)

    vim.api.nvim_create_autocmd("User", {
      pattern = "MiniFilesBufferCreate",
      callback = function(args)
        vim.keymap.set("n", "<CR>", function()
          files.go_in({ close_on_file = true })
        end, { buffer = args.data.buf_id, desc = "Go in plus" })
        vim.keymap.set("n", "J", "j", { buffer = args.data.buf_id, desc = "Move down" })
        vim.keymap.set("n", "K", "k", { buffer = args.data.buf_id, desc = "Move up" })
        vim.keymap.set("n", "gh", function()
          show_hidden = not show_hidden
          require("mini.files").refresh(opts)
        end, { buffer = args.data.buf_id, desc = "Toggle hidden entries" })
      end,
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = { "MiniFilesActionRename", "MiniFilesActionMove" },
      callback = function(event)
        Snacks.rename.on_rename_file(vim.fs.normalize(event.data.from), vim.fs.normalize(event.data.to))
      end,
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = "MiniFilesActionDelete",
      callback = function(event)
        Snacks.bufdelete({ file = vim.fs.normalize(event.data.from) })
      end,
    })

    vim.keymap.set("n", "<leader>e", function()
      files.close()
      files.open(vim.fn.getcwd(), false)
    end, { desc = "Explore files" })
    vim.keymap.set("n", "<leader>E", function()
      files.close()
      local path = vim.api.nvim_buf_get_name(0)
      -- silently ignore if file doesn't exist
      if path == "" or not vim.uv.fs_stat(path) then
        files.open(vim.fn.getcwd(), false)
        return
      end

      files.open(path, false)
      files.reveal_cwd()
    end, { desc = "Reveal current file" })
  end,
}
