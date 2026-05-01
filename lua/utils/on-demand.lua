local M = {}

local notify = require("utils.notify")

local installing_packages = {}
local package_callbacks = {}
local enabled_lsp_servers = {}

local function flush_package_callbacks(package_name)
  local callbacks = package_callbacks[package_name] or {}
  package_callbacks[package_name] = nil

  for _, callback in ipairs(callbacks) do
    callback()
  end
end

local function fail_package(package_name, err, title)
  installing_packages[package_name] = nil
  package_callbacks[package_name] = nil
  notify("Failed to install " .. package_name .. ": " .. tostring(err), vim.log.levels.ERROR, title)
end

function M.ensure_package(package_name, opts)
  opts = opts or {}
  local title = opts.title or "Tools"

  if opts.on_ready then
    package_callbacks[package_name] = package_callbacks[package_name] or {}
    table.insert(package_callbacks[package_name], opts.on_ready)
  end

  local registry = require("mason-registry")
  if registry.is_installed(package_name) then
    flush_package_callbacks(package_name)
    return
  end

  if installing_packages[package_name] then
    return
  end

  installing_packages[package_name] = true
  notify("Installing " .. package_name, vim.log.levels.INFO, title)

  registry.refresh(function(success)
    vim.schedule(function()
      if not success then
        fail_package(package_name, "registry refresh failed", title)
        return
      end

      if not registry.has_package(package_name) then
        fail_package(package_name, "package not found in registry", title)
        return
      end

      local package = registry.get_package(package_name)

      if package:is_installed() then
        installing_packages[package_name] = nil
        notify("Installed " .. package_name, vim.log.levels.INFO, title)
        flush_package_callbacks(package_name)
        return
      end

      package:once("install:success", function()
        vim.schedule(function()
          installing_packages[package_name] = nil
          notify("Installed " .. package_name, vim.log.levels.INFO, title)
          flush_package_callbacks(package_name)
        end)
      end)

      package:once("install:failed", function(err)
        vim.schedule(function()
          fail_package(package_name, err, title)
        end)
      end)

      if package:is_installing() then
        return
      end

      if package:is_uninstalling() then
        fail_package(package_name, "package is uninstalling", title)
        return
      end

      package:install()
    end)
  end)
end

function M.ensure_lsp(server_name, package_name, opts)
  opts = opts or {}
  local on_ready = opts.on_ready

  M.ensure_package(package_name, {
    title = opts.title,
    on_ready = function()
      if not enabled_lsp_servers[server_name] then
        enabled_lsp_servers[server_name] = true
        vim.lsp.enable(server_name)
      end

      if on_ready then
        on_ready()
      end
    end,
  })
end

function M.ensure_language(lang)
  if lang == "rust" then
    M.ensure_lsp("rust_analyzer", "rust-analyzer", { title = "Rust" })
  end
end

return M
