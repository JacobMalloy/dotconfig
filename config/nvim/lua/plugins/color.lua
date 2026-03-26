vim.pack.add({
    'https://github.com/tiagovla/tokyodark.nvim',
    'https://github.com/navarasu/onedark.nvim',
})

-- Apply colorscheme safely
local ok = pcall(vim.cmd.colorscheme, vim.o.termguicolors and "onedark" or "desert")
if not ok then
    vim.cmd.colorscheme("default")
end
