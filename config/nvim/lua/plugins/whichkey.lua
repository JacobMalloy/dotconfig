local return_value = {}

function return_value.setup()
    vim.pack.add({ 'https://github.com/folke/which-key.nvim' })
    vim.schedule(function()
        require('which-key').setup()
    end)
end

return return_value
