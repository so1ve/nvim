local M = {}

function M.offset(filetype, text, opts)
  return vim.tbl_extend("force", {
    filetype = filetype,
    text = text,
    text_align = "left",
    highlight = "Directory",
    separator = true,
  }, opts or {})
end

local function add_offset(opts, offset)
  opts.options = opts.options or {}
  opts.options.offsets = opts.options.offsets or {}
  table.insert(opts.options.offsets, offset)
end

function M.offset_spec(offset)
  return {
    "akinsho/bufferline.nvim",
    optional = true,
    opts = function(_, opts)
      add_offset(opts, offset)
    end,
  }
end

return M
