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
            },
        },
    })

    local lsps = { "clangd", "rust_analyzer", "basedpyright", "lua_ls", "texlab", "harper_ls" }
    for _, lsp in ipairs(lsps) do
        vim.lsp.enable(lsp);
    end



    vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
            -- NOTE: Remember that Lua is a real programming language, and as such it is possible
            -- to define small helper and utility functions so you don't have to repeat yourself.
            --
            -- In this case, we create a function that lets us more easily define mappings specific
            -- for LSP related items. It sets the mode, buffer, and description for us each time.
            local map = function(keys, func, desc, mode)
                mode = mode or 'n'
                vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
            end
            -- The following two autocommands are used to highlight references of the
            -- word under your cursor when your cursor rests there for a little while.
            --    See `:help CursorHold` for information about when this is executed
            --
            -- When you move your cursor, the highlights will be cleared (the second autocommand).
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

            -- The following code creates a keymap to toggle inlay hints in your
            -- code, if the language server you are using supports them
            --
            -- This maybe unwanted, since they displace some of your code
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
    local deps = require('mini.deps')
    local add, now = deps.add, deps.now


    add({ source = "neovim/nvim-lspconfig" })



    now(function()
        -- Create an augroup (optional but recommended for organization)
        local augroup = vim.api.nvim_create_augroup('MyOneTimeGroup', { clear = true })

        -- Create an autocmd that runs only once
        vim.api.nvim_create_autocmd({ 'BufReadPre', "BufNewFile" }, {
            group = augroup,
            once = true, -- This makes it run only once
            callback = run_setup,
        })
    end)
end

return return_value
