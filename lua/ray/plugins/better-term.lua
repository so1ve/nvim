return {
  "CRAG666/betterTerm.nvim",
  keys = {
    {
      "<leader>tt",
      function()
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "better_term" then
            if vim.api.nvim_get_current_win() == win then
              require("betterTerm").open()
            else
              vim.api.nvim_win_hide(win)
            end
            return
          end
        end

        require("panels").open("better-term", function()
          require("betterTerm").open()
        end, { reuse = false })
      end,
      mode = { "n", "t" },
      desc = "Toggle terminal",
    },
    {
      "<C-q>",
      function()
        require("betterTerm").close(vim.fn.bufname("%"))
      end,
      mode = "t",
      desc = "Close current terminal",
    },
    {
      "<leader>ts",
      function()
        require("betterTerm").select()
      end,
      desc = "Select terminal",
    },
    {
      "<leader>tr",
      function()
        require("betterTerm").rename()
      end,
      desc = "Rename terminal",
    },
  },
  opts = {
    new_tab_mapping = "<C-n>",
    jump_tab_mapping = "<A-$tab>",
    index_base = 1,
    predefined = {
      { index = 1, name = "Main" },
      { index = 2, name = "Server" },
    },
  },
}
