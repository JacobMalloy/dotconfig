local return_value = {}

function return_value.setup()
    local deps = require('mini.deps')
    local add, later = deps.add, deps.later

    add({ source = 'folke/which-key.nvim' })

    later(function()
        require('which-key').setup()
    end)
end

return return_value
