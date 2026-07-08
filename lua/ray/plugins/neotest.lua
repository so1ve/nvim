local function current_file()
  local path = vim.fn.expand("%:p")

  return vim.uv.fs_realpath(path) or path
end

return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "so1ve/tiny-treesitter.nvim",
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
    consumers = {
      trouble = function(client)
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

    local adapters = {}

    for name, config in pairs(opts.adapters) do
      if config ~= false then
        adapters[#adapters + 1] = require(name)
      end
    end

    opts.adapters = adapters

    local neotest = require("neotest")
    neotest.setup(opts)

    -- register q to close neotest output and output panel windows
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "neotest-output-panel", "neotest-output" },
      callback = function(args)
        vim.keymap.set("n", "q", function()
          local filetype = vim.bo[args.buf].filetype

          if filetype == "neotest-output-panel" then
            neotest.output_panel.close()
          elseif filetype == "neotest-output" then
            vim.api.nvim_win_close(0, true)
          end
        end, { buffer = args.buf, desc = "Close neotest window", nowait = true, silent = true })
      end,
    })

    local map = function(keys, rhs, desc)
      vim.keymap.set("n", "<leader>T" .. keys, rhs, { desc = desc })
    end

    map("r", function()
      neotest.run.run()
    end, "Run nearest test")
    map("t", function()
      neotest.run.run(current_file())
    end, "Run test file")
    map("T", function()
      neotest.run.run(vim.uv.cwd())
    end, "Run all test files")
    map("l", function()
      neotest.run.run_last()
    end, "Run last test")
    map("s", function()
      require("panels").open("neotest.summary", function()
        neotest.summary.toggle()
      end)
    end, "Toggle test summary")
    map("o", function()
      neotest.output.open({ enter = true, auto_close = true })
    end, "Open test output")
    map("O", function()
      require("panels").open("neotest.output", function()
        neotest.output_panel.toggle()
      end)
    end, "Toggle test output panel")
    map("a", function()
      neotest.run.attach()
    end, "Attach to test")
    map("w", function()
      neotest.watch.toggle(current_file())
    end, "Watch test file")
    map("S", function()
      neotest.run.stop()
    end, "Stop test")
    map("d", function()
      neotest.run.run({ strategy = "dap" })
    end, "Debug nearest test")
  end,
  keys = {
    { "<leader>T", desc = "Test" },
  },
}
