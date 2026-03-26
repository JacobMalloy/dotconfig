local return_value = {}

local parsers = {
    "json",
    "javascript",
    "typescript",
    "tsx",
    "yaml",
    "html",
    "css",
    "markdown",
    "markdown_inline",
    "bash",
    "lua",
    "vim",
    "vimdoc",
    "dockerfile",
    "gitignore",
    "c",
    "rust",
    "latex",
    "elixir",
    "zig",
}

local function is_parser_installed(lang)
    local ok = pcall(vim.treesitter.language.inspect, lang)
    return ok
end

local function run_setup()
    -- Install parsers (new main branch API), only if not already installed
    local ts = require("nvim-treesitter")
    if ts.install then
        local missing = vim.tbl_filter(function(p)
            return not is_parser_installed(p)
        end, parsers)
        if #missing > 0 then
            ts.install(missing)
        end
    end

    -- Enable treesitter highlighting for all filetypes with available parsers
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            pcall(vim.treesitter.start)
        end,
    })

    -- Incremental selection keymaps
    local ok, inc_sel = pcall(require, "nvim-treesitter.incremental_selection")
    if ok then
        vim.keymap.set("n", "<C-space>", function()
            inc_sel.init_selection()
        end, { desc = "Start incremental selection" })
        vim.keymap.set("x", "<C-space>", function()
            inc_sel.node_incremental()
        end, { desc = "Increment selection to node" })
        vim.keymap.set("x", "<bs>", function()
            inc_sel.node_decremental()
        end, { desc = "Decrement selection to node" })
    end
end

function return_value.setup()
    vim.api.nvim_create_autocmd('PackChanged', {
        callback = function(ev)
            if ev.data.spec.name == 'nvim-treesitter'
                and (ev.data.kind == 'install' or ev.data.kind == 'update') then
                vim.schedule(function() vim.cmd('TSUpdate') end)
            end
        end,
    })

    vim.pack.add({ { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' } })
    run_setup()
end

return return_value
