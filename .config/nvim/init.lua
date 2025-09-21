-- ~/.config/nvim/init.lua
-- Lightweight LazyVim configuration optimized for Deno development
-- Performance-focused with automatic Deno project detection and LSP conflict resolution

-- Set leader key before loading any plugins
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Disable some built-in plugins for better performance
vim.g.loaded_gzip = 1
vim.g.loaded_zip = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_tar = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_getscript = 1
vim.g.loaded_getscriptPlugin = 1
vim.g.loaded_vimball = 1
vim.g.loaded_vimballPlugin = 1
vim.g.loaded_2html_plugin = 1
vim.g.loaded_logiPat = 1
vim.g.loaded_rrhelper = 1
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrwSettings = 1
vim.g.loaded_netrwFileHandlers = 1

-- Essential Neovim options for optimal development experience
local opt = vim.opt

-- General settings
opt.mouse = "a"                    -- Enable mouse support
opt.clipboard = "unnamedplus"      -- Use system clipboard
opt.undofile = true               -- Persistent undo
opt.swapfile = false              -- Disable swap files for better performance
opt.backup = false                -- No backup files
opt.writebackup = false           -- No backup files

-- Performance optimizations
opt.updatetime = 250              -- Faster completion and diagnostics
opt.timeoutlen = 300              -- Faster key sequence completion
opt.lazyredraw = true             -- Don't redraw during macros
opt.synmaxcol = 300               -- Limit syntax highlighting for long lines

-- Display settings
opt.number = true                 -- Show line numbers
opt.relativenumber = true         -- Relative line numbers
opt.signcolumn = "yes"            -- Always show sign column
opt.cursorline = true             -- Highlight current line
opt.wrap = false                  -- No line wrapping
opt.scrolloff = 8                 -- Keep 8 lines visible when scrolling
opt.sidescrolloff = 8             -- Keep 8 columns visible when scrolling

-- Indentation
opt.tabstop = 2                   -- Tab width
opt.shiftwidth = 2                -- Indent width
opt.expandtab = true              -- Use spaces instead of tabs
opt.smartindent = true            -- Smart indentation

-- Search settings
opt.ignorecase = true             -- Case insensitive search
opt.smartcase = true              -- Case sensitive if uppercase present
opt.hlsearch = true               -- Highlight search results
opt.incsearch = true              -- Incremental search

-- Split behavior
opt.splitbelow = true             -- Horizontal splits below
opt.splitright = true             -- Vertical splits to the right

-- Configure lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- LazyVim configuration with minimal extras for Deno development
require("lazy").setup({
  spec = {
    -- Import LazyVim core
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    
    -- Essential language support for Deno/TypeScript
    { import = "lazyvim.plugins.extras.lang.typescript" },
    
    -- Optional: Enable if you need formatting with Prettier (lightweight alternative)
    -- { import = "lazyvim.plugins.extras.formatting.prettier" },
    
    -- Import custom plugin configurations
    { import = "plugins" },
  },
  
  -- Performance optimizations
  defaults = {
    lazy = false, -- Plugins are not lazy-loaded by default for faster startup
    version = false, -- Don't use version constraints for plugins
  },
  
  -- Minimize startup impact
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = { enabled = false }, -- Disable automatic plugin updates checking
  change_detection = { enabled = false }, -- Disable file change detection for config
  
  -- UI configuration for minimal overhead
  ui = {
    icons = {
      cmd = "⌘",
      config = "🛠",
      event = "📅",
      ft = "📂",
      init = "⚙",
      keys = "🗝",
      plugin = "🔌",
      runtime = "💻",
      source = "📄",
      start = "🚀",
      task = "📌",
    },
  },
  
  -- Performance settings
  performance = {
    cache = {
      enabled = true,
    },
    reset_packpath = true,
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

-- Deno-specific LSP and tooling configuration
-- This ensures proper Deno project detection and LSP conflict resolution

-- Utility function to check if current project is a Deno project
local function is_deno_project()
  local root_patterns = { "deno.json", "deno.jsonc" }
  local root_dir = require("lspconfig.util").root_pattern(unpack(root_patterns))(vim.loop.cwd())
  return root_dir ~= nil
end

-- Auto-command for Deno-specific settings
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
  pattern = { "*.ts", "*.tsx", "*.js", "*.jsx" },
  callback = function()
    if is_deno_project() then
      -- Set Deno-specific options
      vim.bo.tabstop = 2
      vim.bo.shiftwidth = 2
      vim.bo.expandtab = true
      
      -- Enable Deno-specific features
      vim.g.deno_enabled = true
      
      -- Optional: Set up format on save for Deno projects
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = vim.api.nvim_get_current_buf(),
        callback = function()
          if vim.lsp.buf.format then
            vim.lsp.buf.format({ timeout_ms = 2000 })
          end
        end,
      })
    end
  end,
})

-- Essential keymaps for Deno development
local keymap = vim.keymap.set

-- LSP keymaps (these will be available when LSP attaches)
keymap("n", "gd", vim.lsp.buf.definition, { desc = "Go to Definition" })
keymap("n", "gr", vim.lsp.buf.references, { desc = "Go to References" })
keymap("n", "gI", vim.lsp.buf.implementation, { desc = "Go to Implementation" })
keymap("n", "gy", vim.lsp.buf.type_definition, { desc = "Go to Type Definition" })
keymap("n", "K", vim.lsp.buf.hover, { desc = "Hover Documentation" })
keymap("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Actions" })
keymap("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename Symbol" })
keymap("n", "<leader>f", vim.lsp.buf.format, { desc = "Format Document" })

-- Diagnostic keymaps
keymap("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous Diagnostic" })
keymap("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })
keymap("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show Diagnostic" })
keymap("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostic List" })

-- Deno-specific keymaps
keymap("n", "<leader>dr", "<cmd>!deno run %<cr>", { desc = "Deno Run Current File" })
keymap("n", "<leader>dt", "<cmd>!deno test<cr>", { desc = "Deno Test" })
keymap("n", "<leader>dc", "<cmd>!deno cache %<cr>", { desc = "Deno Cache Current File" })
keymap("n", "<leader>df", "<cmd>!deno fmt %<cr>", { desc = "Deno Format Current File" })
keymap("n", "<leader>dl", "<cmd>!deno lint %<cr>", { desc = "Deno Lint Current File" })

-- Quick file navigation
keymap("n", "<leader><space>", "<cmd>find .<cr>", { desc = "Find Files" })
keymap("n", "<leader>/", "<cmd>grep<cr>", { desc = "Search in Files" })

-- Buffer navigation
keymap("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete Buffer" })
keymap("n", "[b", "<cmd>bprevious<cr>", { desc = "Previous Buffer" })
keymap("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })

-- Window navigation
keymap("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window" })

-- Clear search highlighting
keymap("n", "<leader>h", "<cmd>nohlsearch<cr>", { desc = "Clear Search Highlight" })

-- Terminal toggle (useful for running Deno commands)
keymap("n", "<leader>t", "<cmd>terminal<cr>", { desc = "Toggle Terminal" })
keymap("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit Terminal Mode" })

-- Auto-commands for enhanced development experience
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking text",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Auto-resize splits when window is resized
vim.api.nvim_create_autocmd("VimResized", {
  desc = "Resize splits when window is resized",
  group = vim.api.nvim_create_augroup("resize-splits", { clear = true }),
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- Performance monitoring (optional - comment out for production use)
-- vim.api.nvim_create_autocmd("VimEnter", {
--   callback = function()
--     local stats = require("lazy").stats()
--     local startup_time = (math.floor(stats.startuptime * 100 + 0.5) / 100)
--     print(string.format("⚡ Neovim loaded %d plugins in %.2fms", stats.count, startup_time))
--   end,
-- })