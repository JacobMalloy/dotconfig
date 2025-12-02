local return_value = {}


local function run_setup()
    local treesitter = require("nvim-treesitter")

    treesitter.setup({
        highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
        },
        indent = { enable = false },
        autotag = {
            enable = true,
        },
        ensure_installed = {
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
            "dockerfile",
            "gitignore",
            "c",
            "rust",
            "latex",
            "elixir",
        },
        incremental_selection = {
            enable = true,
            keymaps = {
                init_selection = "<C-space>",
                node_incremental = "<C-space>",
                scope_incremental = false,
                node_decremental = "<bs>",
            },
        },
        rainbow = {
            enable = true,
            disable = { "html" },
            extended_mode = false,
            max_file_lines = nil,
        },
        context_commentstring = {
            enable = true,
            enable_autocmd = false,
        },
    })
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
