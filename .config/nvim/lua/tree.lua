return {
    { "kyazdani42/nvim-web-devicons" },

    {
        "kyazdani/nvim-tree.lua",
        requires = { "kyazdani42/nvim-web-devicons" },
        config = function()
            require("nvim-tree").setup({
                filters = { 
                    dotfiles = false,
                    custom = {},
                    exclude = { "scripts" },
                },
                renderer = {
                    icons = {
                        glyphs = {
                            default = "",
                            symlink = "",
                        },
                    }
                },
                on_attach = function(bufnr)
                    local api = require('nvim-tree.api')
                    
                    local function opts(desc)
                        return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
                    end

                    api.config.mappings.default_on_attach(bufnr)
                    vim.keymap.set('n', '<CR>', api.node.open.edit, opts('Open'))
                    vim.keymap.set('n', 'v', api.node.open.vertical, opts('Open in vertical split'))
                    vim.keymap.set('n', 's', api.node.open.horizontal, opts('Open in horizontal split'))
                    vim.keymap.set('n', 't', api.node.open.tab, opts('Open in new tab'))
                    vim.keymap.set('n', 'q', api.tree.close, opts('Close nvim-tree'))
                end
            })
        end,
    },
}

