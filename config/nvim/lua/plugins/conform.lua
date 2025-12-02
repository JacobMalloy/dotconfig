local return_value = {}

local opts = {
    notify_on_error = false,
    -- format_on_save = function(bufnr)
    --     local disable_filetypes = {}
    --     local lsp_format_opt
    --     if disable_filetypes[vim.bo[bufnr].filetype] then
    --         lsp_format_opt = 'never'
    --     else
    --         lsp_format_opt = 'fallback'
    --     end
    --     return {
    --         timeout_ms = 500,
    --         lsp_format = lsp_format_opt,
    --     }
    -- end,
    formatters_by_ft = {
        --lua = { 'stylua' },

        -- Conform can also run multiple formatters sequentially
        rust = { "rust-analyzer" },
        cpp = { "clang-format" },
        c = { "clang-format" },
        python = { "isort", "black" }     --{ "isort", "black" },
        --
        -- You can use 'stop_after_first' to run the first available formatter from the list
        -- javascript = { "prettierd", "prettier", stop_after_first = true },
    },
}

local is_setup = false;

local function lazy_require()
    local conform = require('conform')
    if not is_setup then
        conform.setup(opts)
        is_setup = true;
    end
    return conform
end

local function my_setup()
    vim.keymap.set({ 'n' }, '<leader>f',
        function()
            lazy_require().format { async = true, lsp_format = 'fallback' }
        end, { desc = "[F]ormat buffer" })
end

function return_value.setup()
    local deps = require('mini.deps')
    local add, later = deps.add, deps.later
    add({ source = 'stevearc/conform.nvim' })
    later(my_setup)
end

return return_value
