vim.g.mapleader = " "

local function map(mode, lhs, rhs)
  vim.keymap.set(mode, lhs, rhs, { silent = true })
end


map("i", "jj", "<ESC>")
map('i', '<C-k>', vim.lsp.buf.signature_help)
