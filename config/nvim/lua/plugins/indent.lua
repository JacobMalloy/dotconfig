local return_value = {}

local function run_setup()
    require("editorconfig")
    -- require("vim-sleuth")
end

function return_value.setup()
    local deps = require('mini.deps')
    local add, later = deps.add, deps.later
    add({source = "gpanders/editorconfig.nvim"})
    add({source = "tpope/vim-sleuth" })
    later(function()
        -- Create an augroup (optional but recommended for organization)
        local augroup = vim.api.nvim_create_augroup('OneTimeGroup-treesitter', { clear = true })

        -- Create an autocmd that runs only once
        vim.api.nvim_create_autocmd({ 'BufReadPre', "BufNewFile" }, {
            group = augroup,
            once = true, -- This makes it run only once
            callback = run_setup,
        })
    end)
end



return return_value


