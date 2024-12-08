-- Set up lazy.nvim
vim.opt.rtp:prepend("~/.local/share/nvim/lazy/lazy.nvim")

-- Enable syntax and filetype settings
vim.cmd('filetype plugin indent on')
vim.cmd('syntax on')

-- Completion options for LSP
vim.o.completeopt = "menuone,noinsert,noselect"

-- Plugins using lazy.nvim
require("lazy").setup({

    require("lsp"),
    require("python-venv-selector"),
    require("syntax"),
    require("tree"),
    require("ui"),

  -- Syntax highlighting and text object support
  -- { 'sheerun/vim-polyglot' },
  { 'rust-lang/rust.vim' },
  
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
