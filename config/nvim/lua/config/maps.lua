vim.g.mapleader = " "

local function map(mode, lhs, rhs)
    vim.keymap.set(mode, lhs, rhs, { silent = true })
end


map("i", "jj", "<ESC>")
map('i', '<C-k>', vim.lsp.buf.signature_help)
map('n', '<BS>', '<C-o>')


vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, {
    noremap = true,
    silent = true,
    desc = "Show line diagnostics"
})

vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { silent = true, desc = "Next diagnostic" })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { silent = true, desc = "Previous diagnostic" })
