local group = vim.api.nvim_create_augroup("RayMenu", { clear = true })

local lsp_menu_items = {
  { priority = "1.30", path = "PopUp.Go\\ to\\ definition", rhs = "<Cmd>lua Snacks.picker.lsp_definitions()<CR>" },
  { priority = "1.31", path = "PopUp.Go\\ to\\ declaration", rhs = "<Cmd>lua Snacks.picker.lsp_declarations()<CR>" },
  { priority = "1.32", path = "PopUp.Go\\ to\\ implementation", rhs = "<Cmd>lua Snacks.picker.lsp_implementations()<CR>" },
  { priority = "1.33", path = "PopUp.Go\\ to\\ type\\ definition", rhs = "<Cmd>lua Snacks.picker.lsp_type_definitions()<CR>" },
  { priority = "1.34", path = "PopUp.References", rhs = "<Cmd>lua Snacks.picker.lsp_references()<CR>" },
}

local popup_menu_items = {
  { command = "amenu", priority = "1.10", path = "PopUp.Open\\ in\\ web\\ browser", rhs = "gx" },
  { command = "anoremenu", priority = "1.20", path = "PopUp.Inspect", rhs = "<Cmd>Inspect<CR>" },
}

for _, item in ipairs(lsp_menu_items) do
  table.insert(popup_menu_items, item)
end

for _, item in ipairs({
  {
    command = "anoremenu",
    priority = "1.40",
    path = "PopUp.Show\\ Diagnostics",
    rhs = "<Cmd>lua vim.diagnostic.open_float()<CR>",
  },
  {
    command = "anoremenu",
    priority = "1.41",
    path = "PopUp.Show\\ All\\ Diagnostics",
    rhs = "<Cmd>lua vim.diagnostic.setqflist()<CR>",
  },
  { command = "anoremenu", priority = "1.50", path = "PopUp.-1-", rhs = "<Nop>" },
  { command = "vnoremenu", priority = "1.60", path = "PopUp.Cut", rhs = '"+x' },
  { command = "vnoremenu", priority = "1.61", path = "PopUp.Copy", rhs = '"+y' },
  { command = "anoremenu", priority = "1.62", path = "PopUp.Paste", rhs = '"+gP' },
  { command = "vnoremenu", priority = "1.62", path = "PopUp.Paste", rhs = '"+P' },
  { command = "vnoremenu", priority = "1.63", path = "PopUp.Delete", rhs = '"_x' },
  { command = "nnoremenu", priority = "1.64", path = "PopUp.Select\\ All", rhs = "ggVG" },
  { command = "vnoremenu", priority = "1.64", path = "PopUp.Select\\ All", rhs = "gg0oG$" },
  { command = "inoremenu", priority = "1.64", path = "PopUp.Select\\ All", rhs = "<C-Home><C-O>VG" },
}) do
  table.insert(popup_menu_items, item)
end

local function run_menu_command(command)
  pcall(vim.cmd, command)
end

local function delete_popup_menu_items()
  run_menu_command("silent! aunmenu PopUp")
end

local function define_popup_menu_items()
  delete_popup_menu_items()

  for _, item in ipairs(popup_menu_items) do
    local command = ("%s %s %s %s"):format(
      item.command or "anoremenu",
      item.priority,
      item.path,
      item.rhs
    )

    run_menu_command(command)
  end
end

define_popup_menu_items()

vim.api.nvim_create_autocmd("MenuPopup", {
  group = group,
  desc = "Toggle LSP popup menu items",
  callback = function()
    local command = vim.lsp.get_clients({ bufnr = 0 })[1] and "anoremenu enable" or "amenu disable"

    for _, item in ipairs(lsp_menu_items) do
      run_menu_command(("%s %s"):format(command, item.path))
    end
  end,
})
