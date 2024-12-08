return {
    {
        "linux-cultist/venv-selector.nvim",
        dependencies = {
            "neovim/nvim-lspconfig",
            "mfussenegger/nvim-dap", "mfussenegger/nvim-dap-python", -- Optional
            { "nvim-telescope/telescope.nvim", branch = "0.1.x", dependencies = { "nvim-lua/plenary.nvim" } },
        },
        lazy = false,
        branch = "regexp", -- Use the regexp branch for the latest version
        config = function()
            require("venv-selector").setup({
                stay_on_this_version = true,
            })
        end,
        keys = {
            { ",v", "<cmd>VenvSelect<cr>" },
        },
    },
}
