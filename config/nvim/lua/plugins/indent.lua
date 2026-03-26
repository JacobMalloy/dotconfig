local return_value = {}

local function run_setup()
    require("editorconfig")
    -- require("vim-sleuth")
end

function return_value.setup()
    vim.pack.add({
        'https://github.com/gpanders/editorconfig.nvim',
        'https://github.com/tpope/vim-sleuth',
    })
    vim.schedule(function()
        local augroup = vim.api.nvim_create_augroup('OneTimeGroup-treesitter', { clear = true })
        vim.api.nvim_create_autocmd({ 'BufReadPre', "BufNewFile" }, {
            group = augroup,
            once = true,
            callback = run_setup,
        })
    end)
end

return return_value
