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
}

local function run_setup()
    -- Install parsers (this is now a separate step in the new API)
    require("nvim-treesitter").install(parsers)

    -- Enable treesitter highlighting for all filetypes with available parsers
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            pcall(vim.treesitter.start)
        end,
    })

    -- Incremental selection keymaps
    vim.keymap.set("n", "<C-space>", function()
        require("nvim-treesitter.incremental_selection").init_selection()
    end, { desc = "Start incremental selection" })
    vim.keymap.set("x", "<C-space>", function()
        require("nvim-treesitter.incremental_selection").node_incremental()
    end, { desc = "Increment selection to node" })
    vim.keymap.set("x", "<bs>", function()
        require("nvim-treesitter.incremental_selection").node_decremental()
    end, { desc = "Decrement selection to node" })
end

local function build()
    vim.schedule(function()
        vim.cmd('TSUpdate')
    end)
end

function return_value.setup()
    local deps = require('mini.deps')
    local add, now = deps.add, deps.now


    add({ source = "nvim-treesitter/nvim-treesitter", checkout = 'main', hooks = { post_checkout = build, post_install = build } })



    now(function()
        -- Create an augroup (optional but recommended for organization)
        local augroup = vim.api.nvim_create_augroup('OneTimeGroup-treesitter', { clear = true })

        -- Create an autocmd that runs only once
        vim.api.nvim_create_autocmd({ 'BufReadPre', "BufNewFile" }, {
            group = augroup,
            once = true, -- This makes it run only once
            callback = run_setup,
        })
    end)
end

return return_value
