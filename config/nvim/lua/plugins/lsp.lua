local return_value = {}


local function run_setup()
    local harper_default_config = require('lspconfig.configs.harper_ls')
    vim.lsp.config("harper_ls", {
        filetypes = vim.list_extend(
            vim.deepcopy(harper_default_config.default_config.filetypes or {}),
            { 'tex' }
        )
    })


    vim.lsp.config("rust_analyzer", {
        settings = {
            ["rust-analyzer"] = {
                check = {
                    command = "clippy",
                },
                procMacro = {
                    enable = true,
                },
                cargo = {
                    buildScripts = {
                        enable = true,
                    },
                },
            },
        },
    })

    local lsps = { "clangd", "rust_analyzer", "basedpyright", "lua_ls", "texlab", "harper_ls" ,"zls"}
    for _, lsp in ipairs(lsps) do
        vim.lsp.enable(lsp);
    end



    vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
            local map = function(keys, func, desc, mode)
                mode = mode or 'n'
                vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
            end
            local client = vim.lsp.get_client_by_id(event.data.client_id)
            if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
                local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
                vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                    buffer = event.buf,
                    group = highlight_augroup,
                    callback = vim.lsp.buf.document_highlight,
                })

                vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                    buffer = event.buf,
                    group = highlight_augroup,
                    callback = vim.lsp.buf.clear_references,
                })

                vim.api.nvim_create_autocmd('LspDetach', {
                    group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
                    callback = function(event2)
                        vim.lsp.buf.clear_references()
                        vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
                    end,
                })
            end

            map('K', vim.lsp.buf.hover, 'Hover Documentation')
            map('<leader>rn', vim.lsp.buf.rename, 'Rename')
            map('<leader>ca', vim.lsp.buf.code_action, 'Code Action')

            if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
                map('<leader>th', function()
                    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
                end, '[T]oggle Inlay [H]ints')
                vim.lsp.inlay_hint.enable(true)
            end
        end,
    })
end

function return_value.setup()
    vim.pack.add({ 'https://github.com/neovim/nvim-lspconfig' })

    local augroup = vim.api.nvim_create_augroup('MyOneTimeGroup', { clear = true })
    vim.api.nvim_create_autocmd({ 'BufReadPre', "BufNewFile" }, {
        group = augroup,
        once = true,
        callback = run_setup,
    })
end

return return_value
