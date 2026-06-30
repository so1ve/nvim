-- Rust-specific single-quote pairing rule for nvim-autopairs.

local M = {}

local lifetime_context_nodes = {
  "abstract_type",
  "bounded_type",
  "dynamic_type",
  "for_lifetimes",
  "reference_type",
  "trait_bound",
  "trait_bounds",
  "type_arguments",
  "type_parameters",
  "where_clause",
  "where_predicate",
}

function M.with_pair(opts)
  local after = (opts.line or ""):sub(opts.col or 1)

  if after:match("^[%w_]") then
    return false
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1] - 1
  local col = math.max((opts.col or 1) - 1, 0)
  local ok, node = pcall(vim.treesitter.get_node, { bufnr = opts.bufnr, pos = { row, col } })

  if not ok or not node or node:type() == "block" then
    return false
  end

  if vim.list_contains(lifetime_context_nodes, node:type())
    or node:__has_ancestor(vim.list_extend({ "has-ancestor?", "@node" }, lifetime_context_nodes)) then
    return false
  end

  return nil
end

return M
