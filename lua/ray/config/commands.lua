vim.api.nvim_create_user_command("RayHealth", function()
  vim.cmd.checkhealth("ray")
end, { desc = "Run Ray's Neovim health checks" })

local function pack_lock_plugins()
  local lines = vim.fn.readfile(vim.fn.stdpath("config") .. "/nvim-pack-lock.json")

  return vim.json.decode(table.concat(lines, "\n")).plugins
end

vim.api.nvim_create_user_command("RayPackReinstall", function(args)
  local plugins = pack_lock_plugins()
  local specs = {}

  for _, name in ipairs(args.fargs) do
    local plugin = plugins[name]

    specs[#specs + 1] = {
      name = name,
      src = plugin.src,
    }
  end

  vim.pack.del(args.fargs, { force = true })
  vim.pack.add(specs, { confirm = false })
end, {
  nargs = "+",
  complete = function(arg_lead)
    local plugins = pack_lock_plugins()
    local names = {}

    for name in pairs(plugins) do
      if vim.startswith(name, arg_lead) then
        names[#names + 1] = name
      end
    end

    table.sort(names)

    return names
  end,
  desc = "Reinstall vim.pack plugins by lockfile name",
})

vim.api.nvim_create_user_command("RayFormatToggle", function(args)
  if args.bang then
    vim.g.disable_autoformat = not vim.g.disable_autoformat
    vim.notify("Global format-on-save: " .. (vim.g.disable_autoformat and "disabled" or "enabled"))

    return
  end

  vim.b.disable_autoformat = not vim.b.disable_autoformat
  vim.notify("Buffer format-on-save: " .. (vim.b.disable_autoformat and "disabled" or "enabled"))
end, { bang = true, desc = "Toggle format-on-save for buffer, or globally with !" })

vim.api.nvim_create_user_command("TSReset", function()
  local bufnr = vim.api.nvim_get_current_buf()
  vim.treesitter.stop(bufnr)
  vim.defer_fn(function()
    vim.treesitter.start(bufnr)
    vim.notify("Treesitter reset for current buffer", vim.log.levels.INFO)
  end, 100)
end, { desc = "Reset treesitter for current buffer" })
