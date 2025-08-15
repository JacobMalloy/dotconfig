return {
    enabled = false,
    "williamboman/mason.nvim",
    dependencies = {
        "williamboman/mason-lspconfig.nvim",
        "WhoIsSethDaniel/mason-tool-installer.nvim",
    },
    config = function()
        require("mason").setup()

        require("mason-lspconfig").setup({
            automatic_installation = true,
            ensure_installed = {
                "cssls",
                "eslint",
                "html",
                "jsonls",
                --"tsserver",
                "basedpyright",
                "tailwindcss",
                "clangd",
                "rust_analyzer",
                "texlab",
                "lua_ls",
            },
        })

        require("mason-tool-installer").setup({
            automatic_installation = true,
            ensure_installed = {
                "prettier",
                "stylua", -- lua formatter
                "isort",  -- python formatter
                "black",  -- python formatter
                "eslint_d",
            },
        })
    end,
}
