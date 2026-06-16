return {
  "esmuellert/codediff.nvim",
  cmd = "CodeDiff",
  opts = {
    diff = {
      compute_moves = true,
    },
    explorer = {
      initial_focus = "explorer",
      visible_groups = {
        staged = true,
        unstaged = true,
        conflicts = true,
      },
    },
    keymaps = {
      view = {
        toggle_stage = false,
        stage_hunk = "s",
        unstage_hunk = "u",
        discard_hunk = "x",
      },
      explorer = {
        refresh = "<c-r>",
        stage_all = "S",
        unstage_all = "U",
        restore = "x",
      },
      conflict = {
        next_conflict = "<leader>gcn",
        prev_conflict = "<leader>gcp",
        accept_incoming = "<leader>gci",
        accept_current = "<leader>gcc",
        accept_both = "<leader>gcb",
        discard = "<leader>gcB",
        accept_all_incoming = "<leader>gcI",
        accept_all_current = "<leader>gcC",
        accept_all_both = "<leader>gcA",
        discard_all = "<leader>gcX",
        diffget_incoming = "2do",
        diffget_current = "3do",
      },
    },
  },
  config = function(_, opts)
    require("codediff").setup(opts)

    local function stage_current_file(unstage)
      local explorer = require("codediff.ui.lifecycle").get_explorer(vim.api.nvim_get_current_tabpage())
      local node = explorer and explorer.tree and explorer.tree:get_node()
      local data = node and node.data

      if not explorer or not explorer.git_root or not data or data.type == "group" then
        return
      end

      local path = data.type == "directory" and data.dir_path or data.path

      if not path then
        return
      end

      local git = require("codediff.core.git")
      local action = unstage and git.unstage_file or git.stage_file

      action(explorer.git_root, path, function(err)
        if err then
          vim.schedule(function()
            vim.notify(err, vim.log.levels.ERROR)
          end)
        end
      end)
    end

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "codediff-explorer",
      callback = function(event)
        vim.keymap.set("n", "s", function()
          stage_current_file(false)
        end, { buffer = event.buf, desc = "Stage file" })
        vim.keymap.set("n", "u", function()
          stage_current_file(true)
        end, { buffer = event.buf, desc = "Unstage file" })
      end,
    })
  end,
}
