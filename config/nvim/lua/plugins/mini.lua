return {
  'echasnovski/mini.nvim',
  enabled=false,
  version = '*',
  config = function(_, _)
    require('mini.pick').setup()

    -- Set up keymaps after the plugin is loaded
    vim.keymap.set('n', '<leader>ff', function()
      require('mini.pick').builtin.files()
    end, { desc = 'Find files (mini.pick)' })

    vim.keymap.set('n', '<tab>', function()
      require('mini.pick').builtin.buffers()
    end, { desc = 'Find buffers (mini.pick)' })
  end,
}
