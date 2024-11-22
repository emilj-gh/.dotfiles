-- Set up lazy.nvim
vim.opt.rtp:prepend("~/.local/share/nvim/lazy/lazy.nvim")

-- Enable syntax and filetype settings
vim.cmd('filetype plugin indent on')
vim.cmd('syntax on')

-- Completion options for LSP
vim.o.completeopt = "menuone,noinsert,noselect"

-- Plugins using lazy.nvim
require("lazy").setup({
  -- Devicons for file icons
  { "kyazdani42/nvim-web-devicons" },

  -- File explorer
  { 
    "kyazdani42/nvim-tree.lua",
    requires = { "kyazdani42/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        filters = {
          dotfiles = false,
        },
        renderer = {
          icons = {
            glyphs = {
              default = "",
              symlink = "",
            },
          },
        },
        on_attach = function(bufnr)
          local api = require('nvim-tree.api')

          -- Key mappings for nvim-tree
          local function opts(desc)
            return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
          end

          api.config.mappings.default_on_attach(bufnr)
          vim.keymap.set('n', '<CR>', api.node.open.edit, opts('Open'))
          vim.keymap.set('n', 'v', api.node.open.vertical, opts('Open in vertical split'))
          vim.keymap.set('n', 's', api.node.open.horizontal, opts('Open in horizontal split'))
          vim.keymap.set('n', 't', api.node.open.tab, opts('Open in new tab'))
          vim.keymap.set('n', 'q', api.tree.close, opts('Close nvim-tree'))
        end,
      })
    end,
  },

  -- Syntax highlighting and text object support
  { 'sheerun/vim-polyglot' },
  { 'rust-lang/rust.vim' },
  
  -- Statusline
  { 
    "nvim-lualine/lualine.nvim",
    requires = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          icons_enabled = true,
          theme='nordic'
        },
      })
    end,
  },

  -- Treesitter for syntax highlighting
  { "nvim-treesitter/nvim-treesitter", version = false,
      build = function()
        require("nvim-treesitter.install").update({ with_sync = true })
      end,
      config = function()
        require("nvim-treesitter.configs").setup({
          ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "python", "javascript" },
          auto_install = false,
          highlight = { enable = true, additional_vim_regex_highlighting = false },
          incremental_selection = {
            enable = true,
            keymaps = {
              init_selection = "<C-Right>",
              node_incremental = "<C-Right>",
              scope_incremental = "<C-s>",
              node_decremental = "<C-m>",
            }
          }
        })
      end
    },

  -- Autocompletion setup with nvim-cmp
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",  -- LSP source for nvim-cmp
      "hrsh7th/cmp-buffer",    -- Buffer completion source
      "hrsh7th/cmp-path",      -- Path completion source
      "saadparwaiz1/cmp_luasnip",  -- Snippet completion source
      "L3MON4D3/LuaSnip"       -- Snippet engine
    },
    config = function()
      local has_words_before = function()
          unpack = unpack or table.unpack
          local line, col = unpack(vim.api.nvim_win_get_cursor(0))
          return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end 

      local cmp = require("cmp")
      local luasnip = require("luasnip")
      cmp.setup({
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)  -- Snippet support
          end,
        },
        mapping = cmp.mapping.preset.insert ({
            ["<c-e>"] = cmp.mapping.abort(),
            ["<CR>"] = cmp.mapping.confirm({ select=true }),
        }), 
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'buffer' },
        }),
      })
    end,
  },

  -- Colorscheme
  { 
    'AlexvZyl/nordic.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      require('nordic').load()
    end,
  },

  -- Python virtual environment selector
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

  -- LSP configuration with pyright
  { 
    'neovim/nvim-lspconfig',
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

      -- Mason setup
      require('mason').setup()
      local mason_lspconfig = require("mason-lspconfig")
      mason_lspconfig.setup {
        ensure_installed = { "pyright" }
      }

      -- lsp configuration
      local lspconfig = require("lspconfig")
      
      lspconfig.pyright.setup({
        capabilities = capabilities,
        on_attach = function(client, bufnr)
            vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

            local opts = { noremap = true, silent = true }
            vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-b>', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
            vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
        end,
      })
    end,
  },

    -- Conform formatter
    {
      "stevearc/conform.nvim",
      event = { "BufWritePre" },
      cmd = { "ConformInfo" },
      keys = {
        {
          -- Customize or remove this keymap to your liking
          "<leader>f",
          function()
            require("conform").format({ async = true })
          end,
          mode = "",
          desc = "Format buffer",
        },
      },
      -- This will provide type hinting with LuaLS
      ---@module "conform"
      ---@type conform.setupOpts
      opts = {
        -- Define your formatters
        formatters_by_ft = {
          lua = { "stylua" },
          python = { "isort", "black" },
          javascript = { "prettierd", "prettier", stop_after_first = true },
        },
        -- Set default options
        default_format_opts = {
          lsp_format = "fallback",
        },
        -- Set up format-on-save
        format_on_save = { timeout_ms = 500 },
        -- Customize formatters
        formatters = {
          shfmt = {
            prepend_args = { "-i", "2" },
          },
        },
      },
      init = function()
        -- If you want the formatexpr, here is the place to set it
        vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
      end,
    },

  -- Custom plugin (local directory)
  {
    dir = "/home/emilj/repos/typeit.nvim",
    config = function()
      require('typeit').setup({
        default_speed = 30,
        default_pause = 'line',
      })
    end,
  },
})

-- Basic settings
vim.opt.number = true             -- Show line numbers
vim.opt.tabstop = 4               -- Number of spaces that a <Tab> counts for
vim.opt.shiftwidth = 4            -- Number of spaces to use for autoindent
vim.opt.expandtab = true          -- Use spaces instead of tabs
vim.opt.cursorline = true         -- Highlight the current line
vim.opt.wildmenu = true           -- Enhanced command-line completion

-- Autocmd for syntax highlighting after save
vim.api.nvim_create_autocmd("BufWritePost", {
  callback = function()
    vim.cmd("syntax on")
  end,
})

-- NvimTree toggle key mapping
vim.api.nvim_set_keymap('n', '<C-n>', ':NvimTreeToggle<CR>', { noremap = true, silent = true })

-- Split terminal with custom size
vim.api.nvim_set_keymap('n', '<C-t>', ':split | terminal<CR>', { noremap = true, silent = true })
vim.cmd [[ autocmd TermOpen * resize 10 ]]

-- Insert mode undo break mappings to create granular undo points
vim.cmd [[
  inoremap <Space> <Space><C-g>u
  inoremap . .<C-g>u
  inoremap , ,<C-g>u
  inoremap ( (<C-g>u
  inoremap ) )<C-g>u
  inoremap ; ;<C-g>u
  inoremap : :<C-g>u
  inoremap " "<C-g>u
  inoremap ' '<C-g>u
  inoremap = =<C-g>u
  inoremap <CR> <CR><C-g>u
]]

-- Key mappings for custom commands
vim.api.nvim_set_keymap('v', '<C-c>', '"+y', { noremap = true, silent = true })   -- Copy in visual mode only
vim.api.nvim_set_keymap('i', '<C-z>', '<C-o>u', { noremap = true, silent = true })  -- Undo in insert mode only
vim.api.nvim_set_keymap('i', '<C-p>', '<C-r>+', { noremap = true, silent = true })  -- Paste in insert mode
vim.api.nvim_set_keymap('n', '<C-b>', '<cmd>lua vim.lsp.buf.definition()<CR>', { noremap = true, silent = true })  -- Go to definition
