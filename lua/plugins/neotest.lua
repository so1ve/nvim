local edgy = require("config.edgy")

local function current_file()
  local path = vim.fn.expand("%:p")

  return vim.uv.fs_realpath(path) or path
end

return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      adapters = {},
      status = { virtual_text = true },
      output = { open_on_run = true },
      quickfix = {
        open = function()
          require("trouble").open({ mode = "quickfix", focus = false })
        end,
      },
    },
    config = function(_, opts)
      local neotest_namespace = vim.api.nvim_create_namespace("neotest")

      vim.diagnostic.config({
        virtual_text = {
          format = function(diagnostic)
            return diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
          end,
        },
      }, neotest_namespace)

      opts.consumers = opts.consumers or {}
      opts.consumers.trouble = function(client)
        client.listeners.results = function(adapter_id, results, partial)
          if partial then
            return
          end

          local tree = assert(client:get_position(nil, { adapter = adapter_id }))
          local failed = 0

          for position_id, result in pairs(results) do
            if result.status == "failed" and tree:get_key(position_id) then
              failed = failed + 1
            end
          end

          vim.schedule(function()
            local trouble = require("trouble")

            if trouble.is_open() then
              trouble.refresh()

              if failed == 0 then
                trouble.close()
              end
            end
          end)

          return {}
        end
      end

      local adapters = {}

      for name, config in pairs(opts.adapters) do
        if type(name) == "number" then
          if type(config) == "string" then
            config = require(config)
          end

          table.insert(adapters, config)
        elseif config ~= false then
          local adapter = require(name)

          if type(config) == "table" and not vim.tbl_isempty(config) then
            local meta = getmetatable(adapter)

            if adapter.setup then
              adapter.setup(config)
            elseif adapter.adapter then
              adapter.adapter(config)
              adapter = adapter.adapter
            elseif meta and meta.__call then
              adapter = adapter(config)
            else
              error("Adapter " .. name .. " does not support setup")
            end
          end

          table.insert(adapters, adapter)
        end
      end

      opts.adapters = adapters
      require("neotest").setup(opts)
    end,
    -- stylua: ignore
    keys = {
      { "<leader>T", "", desc = "+test" },
      { "<leader>Ta", function() require("neotest").run.attach() end, desc = "Attach to test" },
      { "<leader>Tt", function() require("neotest").run.run(current_file()) end, desc = "Run test file" },
      { "<leader>TT", function() require("neotest").run.run(vim.uv.cwd()) end, desc = "Run all test files" },
      { "<leader>Tr", function() require("neotest").run.run() end, desc = "Run nearest test" },
      { "<leader>Tl", function() require("neotest").run.run_last() end, desc = "Run last test" },
      { "<leader>Ts", function() require("neotest").summary.toggle() end, desc = "Toggle test summary" },
      { "<leader>To", function() require("neotest").output.open({ enter = true, auto_close = true }) end, desc = "Show test output" },
      { "<leader>TO", function() require("neotest").output_panel.toggle() end, desc = "Toggle test output panel" },
      { "<leader>TS", function() require("neotest").run.stop() end, desc = "Stop tests" },
      { "<leader>Tw", function() require("neotest").watch.toggle(current_file()) end, desc = "Toggle test watch" },
    },
  },
  {
    "mfussenegger/nvim-dap",
    optional = true,
    keys = {
      {
        "<leader>Td",
        function()
          require("neotest").run.run({ strategy = "dap" })
        end,
        desc = "Debug nearest test",
      },
    },
  },
  edgy.view_spec("left", edgy.view("Neotest", "neotest-summary")),
  edgy.view_spec("bottom", edgy.view("Neotest Output", "neotest-output-panel", { size = { height = 15 } })),
  edgy.neo_tree_exclusion_spec({ "neotest-summary", "neotest-output-panel" }),
}
