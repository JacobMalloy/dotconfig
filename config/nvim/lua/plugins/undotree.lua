local return_value = {}


function return_value.setup()
    vim.cmd.packadd('nvim.undotree')
end

return return_value
