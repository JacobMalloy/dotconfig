local return_value = {}
local function setup_function()
  local dap = require 'dap'
  local dapui = require 'dapui'


  -- Dap UI setup
  -- For more information, see |:help nvim-dap-ui|
  dapui.setup {
    -- Set icons to characters that are more likely to work in every terminal.
    --    Feel free to remove or use ones that you like more! :)
    --    Don't feel like these are good choices.
    icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
    controls = {
      icons = {
        pause = '⏸',
        play = '▶',
        step_into = '⏎',
        step_over = '⏭',
        step_out = '⏮',
        step_back = 'b',
        run_last = '▶▶',
        terminate = '⏹',
        disconnect = '⏏',
      },
    },
  }

  -- Change breakpoint icons
  vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
  vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
  local breakpoint_icons = vim.g.have_nerd_font
      and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
      or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
  for type, icon in pairs(breakpoint_icons) do
    local tp = 'Dap' .. type
    local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
    vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
  end

  dap.listeners.after.event_initialized['dapui_config'] = dapui.open
  dap.listeners.before.event_terminated['dapui_config'] = dapui.close
  dap.listeners.before.event_exited['dapui_config'] = dapui.close

  -- Install golang specific config
  --

  dap.adapters.lldb = {
    type = "executable",
    command = "lldb-dap",   -- must be in PATH or absolute path
    name = "lldb"
  }

  dap.configurations.cpp = {
    {
      name = "Launch",
      type = "lldb",
      request = "launch",
      program = function()
        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
      end,
      cwd = "${workspaceFolder}",
      stopOnEntry = false,
      args = {},
    },
  }

  dap.configurations.c = dap.configurations.cpp
  dap.configurations.rust = dap.configurations.cpp
end

local is_loaded = false

local function lazy_require(require_name)
  if not is_loaded then
    setup_function()
    is_loaded = true
  end
  return require(require_name)
end

local function later_setup()
  vim.keymap.set({'n'},
      '<F5>',
      function()
        lazy_require('dap').continue()
      end,
      {desc='Debug: Start/Continue'}
    )
    vim.keymap.set({'n'},
      '<F1>',
      function()
        lazy_require('dap').step_into()
      end,
      {desc='Debug: Step Into'}
    )
    vim.keymap.set({'n'},
      '<F2>',
      function()
        lazy_require('dap').step_over()
      end,
      {desc='Debug: Step Over'}
    )
    vim.keymap.set({'n'},
      '<F3>',
      function()
        lazy_require('dap').step_out()
      end,
      {desc='Debug: Step Out'}
    )
    vim.keymap.set({'n'},
      '<leader>b',
      function()
        lazy_require('dap').toggle_breakpoint()
      end,
      {desc='Debug: Toggle Breakpoint'}
    )
    vim.keymap.set({'n'},
      '<leader>B',
      function()
        lazy_require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end,
      {desc='Debug: Set Breakpoint'}
    )
    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    vim.keymap.set({'n'},
      '<F7>',
      function()
        require('dapui').toggle()
      end,
      {desc='Debug: See last session result.'}
    )

end

function return_value.setup()
  local deps = require("mini.deps")
  local add, later = deps.add, deps.later
  add({ source = 'mfussenegger/nvim-dap', depends = { 'rcarriga/nvim-dap-ui', 'nvim-neotest/nvim-nio', } })
  later(later_setup)
end

return return_value

