return {
  "stevearc/overseer.nvim",
  cmd = {
    "OverseerOpen",
    "OverseerClose",
    "OverseerToggle",
    "OverseerRun",
    "OverseerShell",
    "OverseerTaskAction",
  },
  keys = {
    { "<leader>or", "<cmd>OverseerRun<cr>", desc = "Run task" },
    { "<leader>os", "<cmd>OverseerShell<cr>", desc = "Run shell command" },
    {
      "<leader>ot",
      function()
        require("panels").open("overseer.list", "OverseerToggle")
      end,
      desc = "Toggle tasks",
    },
    { "<leader>oa", "<cmd>OverseerTaskAction<cr>", desc = "Task action" },
  },
  opts = {
    task_list = {
      keymaps = {
        ["<C-k>"] = false,
      },
    },
    component_aliases = {
      default = {
        "on_exit_set_status",
        "on_complete_notify",
        "open_output",
        { "on_complete_dispose", require_view = { "SUCCESS", "FAILURE" } },
      },
    },
  },
}
