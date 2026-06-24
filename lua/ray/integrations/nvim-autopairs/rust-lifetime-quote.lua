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

local function has_ancestor_predicate(node_types)
  return vim.list_extend({ "has-ancestor?", "@node" }, node_types)
end

local lifetime_context_ancestors = has_ancestor_predicate(lifetime_context_nodes)

local function current_node(opts)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1] - 1
  local col = math.max((opts.col or 1) - 1, 0)
  local ok, node = pcall(vim.treesitter.get_node, { bufnr = opts.bufnr, pos = { row, col } })

  if ok then
    return node
  end

  return nil
end

local function is_treesitter_lifetime_context(node)
  return vim.list_contains(lifetime_context_nodes, node:type()) or node:__has_ancestor(lifetime_context_ancestors)
end

local function is_label_context(node)
  return node:type() == "block"
end

function M.with_pair(opts)
  local after = (opts.line or ""):sub(opts.col or 1)

  if after:match("^[%w_]") then
    return false
  end

  local node = current_node(opts)

  if not node or is_label_context(node) or is_treesitter_lifetime_context(node) then
    return false
  end

  return nil
end

return M
