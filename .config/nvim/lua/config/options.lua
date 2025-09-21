-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
-- Editor Behavior
vim.opt.conceallevel = 0        -- Show concealed text
vim.opt.wrap = true             -- Enable line wrapping
vim.opt.linebreak = true        -- Break lines at word boundaries
vim.opt.showbreak = "↪ "        -- Show line break indicator

-- Indentation (Optimized for Deno/TypeScript)
vim.opt.tabstop = 2             -- Tab width
vim.opt.shiftwidth = 2          -- Indentation width
vim.opt.expandtab = true        -- Use spaces instead of tabs
vim.opt.smartindent = true      -- Smart auto-indentation

-- Search and Navigation
vim.opt.ignorecase = true       -- Case-insensitive search
vim.opt.smartcase = true        -- Case-sensitive if uppercase present
vim.opt.hlsearch = false        -- Don't highlight search results
vim.opt.incsearch = true        -- Incremental search

-- File Handling
vim.opt.undofile = true         -- Persistent undo
vim.opt.backup = false          -- No backup files
vim.opt.swapfile = false        -- No swap files
vim.opt.autoread = true         -- Auto-reload changed files

-- Performance
vim.opt.updatetime = 250        -- Faster completion
vim.opt.timeoutlen = 300        -- Faster key sequence timeout
vim.opt.lazyredraw = true       -- Don't redraw during macros
