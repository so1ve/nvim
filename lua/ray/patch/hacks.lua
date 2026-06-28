local M = {}

local PREFIX = "_ray_hack_"
local module_hooks = {}

M._cleanup = {}

local function mark_key(key)
  return PREFIX .. key
end

function M.once(target, key, fn)
  local field = mark_key(key)

  if target[field] then
    return false
  end

  target[field] = true
  M.cleanup(function()
    target[field] = nil
  end)
  fn()

  return true
end

function M.cleanup(fn)
  table.insert(M._cleanup, fn)

  return fn
end

function M.replace(target, key, name, replacement)
  return M.once(target, key, function()
    local original = target[name]

    target[name] = replacement
    M.cleanup(function()
      target[name] = original
    end)
  end)
end

function M.wrap(target, key, name, wrapper)
  return M.once(target, key, function()
    local original = target[name]

    target[name] = wrapper(original)
    M.cleanup(function()
      target[name] = original
    end)
  end)
end

function M.on_module(module, fn)
  local loaded = package.loaded[module]

  if loaded then
    fn(loaded)

    return
  end

  local hook = module_hooks[module]

  if hook then
    table.insert(hook.callbacks, fn)

    return
  end

  hook = {
    callbacks = { fn },
    preload = package.preload[module],
  }
  module_hooks[module] = hook

  package.preload[module] = function()
    package.preload[module] = hook.preload
    module_hooks[module] = nil
    package.loaded[module] = nil

    local loaded = require(module)

    for _, callback in ipairs(hook.callbacks) do
      callback(loaded)
    end

    return loaded
  end

  M.cleanup(function()
    if module_hooks[module] ~= hook then
      return
    end

    package.preload[module] = hook.preload
    module_hooks[module] = nil
  end)
end

return M
