return { -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
        {
            '<leader>f',
            function()
                require('conform').format { async = true, lsp_format = 'fallback' }
            end,
            mode = 'n',
            desc = '[F]ormat buffer',
        },
    },
    opts = {
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
            python = { "isort", "black" } --{ "isort", "black" },
            --
            -- You can use 'stop_after_first' to run the first available formatter from the list
            -- javascript = { "prettierd", "prettier", stop_after_first = true },
        },
    },
}
