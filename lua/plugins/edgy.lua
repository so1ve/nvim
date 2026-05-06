local layout = {
  left = {
    width = 0.25,
  },
  right = {
    width = 0.25,
  },
  bottom = {
    height = 12,
  },
}

local neo_tree_exclusions = {
  "terminal",
  "Trouble",
  "trouble",
  "qf",
  "edgy",
  "grug-far",
  "snacks_terminal",
  "noice",
  "help",
}

local function view(title, ft, opts)
  return vim.tbl_deep_extend("force", {
    title = title,
    ft = ft,
  }, opts or {})
end

local function trouble_filter(position)
  return function(_, win)
    local trouble = vim.w[win].trouble

    return trouble
      and trouble.position == position
      and trouble.type == "split"
      and trouble.relative == "editor"
      and not vim.w[win].trouble_preview
  end
end

local function snacks_position_filter(position)
  return function(buf, win)
    local snacks_win = vim.w[win].snacks_win

    return snacks_win and snacks_win.position == position and snacks_win.relative == "editor"
  end
end

return {
  {
    "folke/edgy.nvim",
    event = "VeryLazy",
    init = function()
      vim.opt.laststatus = 3
      vim.opt.splitkeep = "screen"
    end,
    keys = {
      {
        "<leader>uw",
        function()
          require("edgy").select()
        end,
        desc = "Select layout window",
      },
    },
    opts = {
      animate = {
        enabled = false,
      },
      options = {
        left = { size = layout.left.width },
        right = { size = layout.right.width },
        bottom = { size = layout.bottom.height },
      },
      left = {
        view("Explorer", "neo-tree", {
          filter = function(buf)
            local source = vim.b[buf].neo_tree_source

            return source == nil or source == "filesystem"
          end,
          open = "Neotree show",
        }),
      },
      right = {
        view("Search & Replace", "grug-far", {
          size = { width = layout.right.width },
        }),
        view("LSP", "trouble", {
          filter = trouble_filter("right"),
          size = { width = layout.right.width },
        }),
      },
      bottom = {
        view("Problems", "trouble", {
          filter = trouble_filter("bottom"),
        }),
        view("Quickfix", "qf"),
        view("Terminal", "snacks_terminal", {
          filter = snacks_position_filter("bottom"),
        }),
        view("Help", "help", {
          size = { height = 20 },
        }),
      },
    },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    optional = true,
    opts = function(_, opts)
      opts.open_files_do_not_replace_types = opts.open_files_do_not_replace_types or {}
      local types = opts.open_files_do_not_replace_types
      for _, filetype in ipairs(neo_tree_exclusions) do
        if not vim.tbl_contains(types, filetype) then
          table.insert(types, filetype)
        end
      end
    end,
  },
}
