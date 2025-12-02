local return_value = {}

local opts = {
    picker = {
        -- Your picker configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
    },
    bigfile =
    ---@class snacks.bigfile.Config
    ---@field enabled? boolean
    {
        notify = true,                -- Show notification when big file detected
        size = 1.5 * 1024 * 1024,     -- 1.5MB
        line_length = 1000,           -- Average line length (useful for minified files)
        -- Enable or disable features when big file detected
        ---@param ctx {buf: number, ft:string}
        setup = function(ctx)
            if vim.fn.exists(":NoMatchParen") ~= 0 then
                vim.cmd([[NoMatchParen]])
            end
            Snacks.util.wo(0, { foldmethod = "manual", statuscolumn = "", conceallevel = 0 })
            vim.b.minianimate_disable = true
            vim.schedule(function()
                if vim.api.nvim_buf_is_valid(ctx.buf) then
                    vim.bo[ctx.buf].syntax = ctx.ft
                end
            end)
        end,
    },
}

local function snacks_setup()
    local Snacks = require("snacks")
    Snacks.setup(opts)


    vim.keymap.set({ 'n' }, "<leader>ff", function() Snacks.picker.files() end, { desc = "Find Files" })
    vim.keymap.set({ 'n' }, "<tab>", function() Snacks.picker.buffers() end, { desc = "Buffers" })
    vim.keymap.set({ 'n' }, "<leader>gg", function() Snacks.picker.grep() end, { desc = "Grep" })

    vim.keymap.set({ 'n' }, "gd", function() Snacks.picker.lsp_definitions() end, { desc = "Goto Definition" })
    vim.keymap.set({ 'n' }, "gD", function() Snacks.picker.lsp_declarations() end, { desc = "Goto Declaration" })
    vim.keymap.set({ 'n' }, "gr", function() Snacks.picker.lsp_references() end,
        { nowait = true, desc = "References" })
    vim.keymap.set({ 'n' }, "gi", function() Snacks.picker.lsp_implementations() end, { desc = "Goto Implementation" })
    vim.keymap.set({ 'n' }, "gy", function() Snacks.picker.lsp_type_definitions() end, { desc = "Goto T[y]pe Definition" })
    vim.keymap.set({ 'n' }, "<leader>ss", function() Snacks.picker.lsp_symbols() end, { desc = "LSP Symbols" })
    vim.keymap.set({ 'n' }, "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end,
        { desc = "LSP Workspace Symbols" })
end

function return_value.setup()
    local deps = require('mini.deps')
    local add, now, later = deps.add, deps.now, deps.later
    add({ source = 'folke/snacks.nvim' })
    later(snacks_setup)
end

return return_value
