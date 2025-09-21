-- ~/.config/nvim/init.lua
-- Neovim configuration entry point for LazyVim + Deno development environment
-- 
-- This file serves as the bootstrap for the entire Neovim configuration.
-- It sets up the foundation before loading LazyVim and user configurations.

-- ============================================================================
-- ENVIRONMENT SETUP AND COMPATIBILITY
-- ============================================================================

-- Ensure we're running a compatible version of Neovim
if vim.fn.has("nvim-0.9.0") == 0 then
  vim.api.nvim_echo({
    { "LazyVim requires Neovim >= 0.9.0\n", "ErrorMsg" },
    { "Please upgrade your Neovim installation\n", "WarningMsg" },
    { "Current version: " .. tostring(vim.version()), "Normal" },
  }, true, {})
  return
end

-- Set up global environment variables for debugging/development
vim.g.lazyvim_version = "12.0.0" -- Track LazyVim version for compatibility
vim.g.deno_development = true -- Flag for Deno-specific configurations

-- ============================================================================
-- LEADER KEY CONFIGURATION (Must be set before plugins load)
-- ============================================================================

-- Set leader keys early so plugins can use them in their configurations
vim.g.mapleader = " " -- Space as leader key
vim.g.maplocalleader = "\\" -- Backslash as local leader

-- ============================================================================
-- CRITICAL NEOVIM OPTIONS (Set before plugin loading)
-- ============================================================================

-- Enable filetype detection and plugin loading
vim.cmd("filetype plugin indent on")

-- Set encoding for compatibility
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"

-- Disable some built-in plugins early for performance
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
vim.g.loaded_logipat = 1
vim.g.loaded_rrhelper = 1
vim.g.loaded_spellfile_plugin = 1
vim.g.loaded_matchit = 1
vim.g.loaded_matchparen = 1
vim.g.loaded_spec = 1

-- Disable netrw early (we'll use nvim-tree or oil.nvim)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- ============================================================================
-- PERFORMANCE OPTIMIZATIONS
-- ============================================================================

-- Improve startup time by reducing unnecessary operations
vim.opt.lazyredraw = true -- Don't redraw during macros
vim.opt.regexpengine = 1 -- Use old regexp engine (sometimes faster)
vim.opt.synmaxcol = 240 -- Don't highlight very long lines

-- Set reasonable timeouts
vim.opt.updatetime = 200 -- Faster completion (default: 4000ms)
vim.opt.timeoutlen = 300 -- Time to wait for key sequences (default: 1000ms)
vim.opt.ttimeoutlen = 0 -- Remove delay when exiting insert mode

-- Configure clipboard early for better performance
if vim.fn.has("wsl") == 1 then
  -- WSL-specific clipboard configuration
  vim.g.clipboard = {
    name = "WslClipboard",
    copy = {
      ["+"] = "clip.exe",
      ["*"] = "clip.exe",
    },
    paste = {
      ["+"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
      ["*"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
    },
    cache_enabled = 0,
  }
elseif vim.fn.has("macunix") == 1 then
  -- macOS clipboard
  vim.opt.clipboard = "unnamedplus"
else
  -- Linux clipboard (requires xclip or wl-clipboard)
  vim.opt.clipboard = "unnamedplus"
end

-- ============================================================================
-- DENO ENVIRONMENT DETECTION AND SETUP
-- ============================================================================

-- Function to detect if we're in a Deno project
local function is_deno_project()
  local markers = { "deno.json", "deno.jsonc", "deno.lock", "import_map.json" }
  for _, marker in ipairs(markers) do
    if vim.fn.filereadable(marker) == 1 then
      return true
    end
  end
  return false
end

-- Set up Deno-specific environment if detected
if is_deno_project() then
  vim.g.deno_project = true
  
  -- Disable Node.js type checking in favor of Deno
  vim.g.node_host_prog = ""
  
  -- Set environment variable for Deno
  vim.env.DENO_DIR = vim.env.DENO_DIR or (vim.fn.stdpath("cache") .. "/deno")
  
  -- Add Deno to PATH if not already present
  if vim.fn.executable("deno") == 1 then
    local deno_path = vim.fn.system("which deno"):gsub("\n", "")
    local deno_dir = vim.fn.fnamemodify(deno_path, ":h")
    if not string.find(vim.env.PATH, deno_dir) then
      vim.env.PATH = deno_dir .. ":" .. vim.env.PATH
    end
  end
end

-- ============================================================================
-- PYTHON PROVIDER SETUP (for plugins that need it)
-- ============================================================================

-- Configure Python providers for better performance
local function setup_python_provider()
  -- Try to find Python 3 installation
  local python3_paths = {
    "/usr/bin/python3",
    "/usr/local/bin/python3",
    vim.fn.exepath("python3"),
    vim.fn.exepath("python"),
  }
  
  for _, path in ipairs(python3_paths) do
    if vim.fn.executable(path) == 1 then
      vim.g.python3_host_prog = path
      break
    end
  end
  
  -- Disable Python 2 provider (deprecated)
  vim.g.loaded_python_provider = 0
end

setup_python_provider()

-- ============================================================================
-- NODE.JS PROVIDER SETUP (for non-Deno projects)
-- ============================================================================

-- Only set up Node.js if not in a Deno project
if not vim.g.deno_project then
  local function setup_node_provider()
    local node_paths = {
      vim.fn.exepath("node"),
      "/usr/local/bin/node",
      "/usr/bin/node",
    }
    
    for _, path in ipairs(node_paths) do
      if vim.fn.executable(path) == 1 then
        vim.g.node_host_prog = path
        break
      end
    end
  end
  
  setup_node_provider()
end

-- ============================================================================
-- ERROR HANDLING AND DEBUGGING SETUP
-- ============================================================================

-- Enhanced error reporting for development
if vim.env.NVIM_DEBUG then
  vim.opt.verbose = 1
  vim.opt.debug = "msg"
end

-- Set up global error handler
vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("InitErrorHandler", { clear = true }),
  callback = function()
    -- Override vim.notify for better error visibility
    local orig_notify = vim.notify
    vim.notify = function(msg, level, opts)
      opts = opts or {}
      if level == vim.log.levels.ERROR then
        opts.title = opts.title or "Neovim Error"
        opts.timeout = 5000 -- Keep errors visible longer
      end
      orig_notify(msg, level, opts)
    end
  end,
})

-- ============================================================================
-- BOOTSTRAP LAZY.NVIM AND LAZYVIM
-- ============================================================================

-- Bootstrap function with enhanced error handling
local function bootstrap_lazy()
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  
  if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable",
      lazypath,
    })
    
    -- Verify installation
    if not (vim.uv or vim.loop).fs_stat(lazypath) then
      vim.api.nvim_echo({
        { "Failed to install lazy.nvim!\n", "ErrorMsg" },
        { "Please check your internet connection and try again.\n", "WarningMsg" },
        { "Manual installation: git clone https://github.com/folke/lazy.nvim.git " .. lazypath, "Normal" },
      }, true, {})
      return false
    end
  end
  
  vim.opt.rtp:prepend(lazypath)
  return true
end

-- Bootstrap lazy.nvim
if not bootstrap_lazy() then
  return -- Exit if bootstrap failed
end

-- ============================================================================
-- LOAD CONFIGURATION MODULES
-- ============================================================================

-- Function to safely require modules with error handling
local function safe_require(module)
  local ok, result = pcall(require, module)
  if not ok then
    vim.notify(
      string.format("Failed to load module '%s': %s", module, result),
      vim.log.levels.ERROR,
      { title = "Configuration Error" }
    )
    return nil
  end
  return result
end

-- Load lazy configuration (this sets up the plugin manager)
safe_require("config.lazy")

-- ============================================================================
-- POST-LOAD CONFIGURATION
-- ============================================================================

-- Set up post-load configurations that depend on plugins being available
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  group = vim.api.nvim_create_augroup("PostLoadConfig", { clear = true }),
  callback = function()
    -- Load additional configurations after all plugins are loaded
    
    -- Set up custom highlights for Deno files
    if vim.g.deno_project then
      vim.api.nvim_set_hl(0, "DenoImport", { link = "Include" })
      vim.api.nvim_set_hl(0, "DenoUrl", { link = "Underlined" })
    end
    
    -- Set up custom file associations
    vim.filetype.add({
      extension = {
        ["ts"] = "typescript",
        ["tsx"] = "typescriptreact", 
        ["js"] = "javascript",
        ["jsx"] = "javascriptreact",
        ["mjs"] = "javascript",
        ["cjs"] = "javascript",
      },
      filename = {
        ["deno.json"] = "jsonc",
        ["deno.jsonc"] = "jsonc",
        ["deno.lock"] = "json",
        [".denorc"] = "json",
      },
      pattern = {
        [".*%.deno%..*"] = "typescript", -- Files like main.deno.ts
      },
    })
    
    -- Set up Deno-specific auto-commands
    if vim.g.deno_project then
      local deno_group = vim.api.nvim_create_augroup("DenoConfig", { clear = true })
      
      -- Auto-format Deno files on save
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = deno_group,
        pattern = { "*.ts", "*.tsx", "*.js", "*.jsx" },
        callback = function()
          if vim.fn.executable("deno") == 1 then
            local file = vim.api.nvim_buf_get_name(0)
            vim.fn.system("deno fmt " .. vim.fn.shellescape(file))
            vim.cmd("checktime") -- Reload file if changed
          end
        end,
      })
      
      -- Set up import completion for Deno URLs
      vim.api.nvim_create_autocmd("FileType", {
        group = deno_group,
        pattern = { "typescript", "javascript", "typescriptreact", "javascriptreact" },
        callback = function()
          -- Enable URL completion for import statements
          vim.opt_local.iskeyword:append(":")
          vim.opt_local.iskeyword:append("/")
          vim.opt_local.iskeyword:append(".")
        end,
      })
    end
    
    -- Performance monitoring (optional)
    if vim.env.NVIM_PROFILE then
      local start_time = vim.fn.reltime()
      vim.defer_fn(function()
        local load_time = vim.fn.reltimestr(vim.fn.reltime(start_time))
        vim.notify(
          string.format("Neovim loaded in %sms", load_time),
          vim.log.levels.INFO,
          { title = "Performance" }
        )
      end, 0)
    end
  end,
})

-- ============================================================================
-- HEALTH CHECK INTEGRATION
-- ============================================================================

-- Set up health check command for easy troubleshooting
vim.api.nvim_create_user_command("CheckHealth", function()
  vim.cmd("checkhealth")
end, { desc = "Run Neovim health check" })

-- Custom health check for our configuration
vim.health = vim.health or {}
vim.health.check_deno_setup = function()
  vim.health.start("Deno Development Environment")
  
  -- Check Deno installation
  if vim.fn.executable("deno") == 1 then
    local version = vim.fn.system("deno --version"):match("deno ([%d%.]+)")
    vim.health.ok("Deno found: " .. (version or "unknown version"))
  else
    vim.health.error("Deno not found in PATH", {
      "Install Deno: curl -fsSL https://deno.land/install.sh | sh",
      "Or visit: https://deno.land/manual/getting_started/installation"
    })
  end
  
  -- Check for Deno project
  if vim.g.deno_project then
    vim.health.ok("Deno project detected")
  else
    vim.health.info("Not in a Deno project")
  end
  
  -- Check LSP setup
  local clients = vim.lsp.get_active_clients()
  local deno_lsp_found = false
  for _, client in ipairs(clients) do
    if client.name == "denols" then
      deno_lsp_found = true
      break
    end
  end
  
  if deno_lsp_found then
    vim.health.ok("Deno LSP is active")
  else
    vim.health.warn("Deno LSP not active", {
      "Open a TypeScript/JavaScript file in a Deno project",
      "Run :LspInfo to see active language servers"
    })
  end
end

-- ============================================================================
-- FINAL SETUP AND EXPORTS
-- ============================================================================

-- Create a global table for configuration access
_G.LazyVimConfig = {
  version = vim.g.lazyvim_version,
  deno_project = vim.g.deno_project or false,
  
  -- Utility functions
  utils = {
    safe_require = safe_require,
    is_deno_project = is_deno_project,
    
    -- Reload configuration
    reload_config = function()
      for name, _ in pairs(package.loaded) do
        if name:match("^config") or name:match("^plugins") then
          package.loaded[name] = nil
        end
      end
      dofile(vim.env.MYVIMRC)
      vim.notify("Configuration reloaded!", vim.log.levels.INFO)
    end,
    
    -- Get plugin statistics
    get_stats = function()
      if package.loaded["lazy"] then
        return require("lazy").stats()
      else
        return { count = 0, loaded = 0 }
      end
    end,
  },
}

-- Set up global keybinding for config reload
vim.keymap.set("n", "<leader>R", function()
  _G.LazyVimConfig.utils.reload_config()
end, { desc = "Reload Configuration" })

-- Final status message (only in debug mode)
if vim.env.NVIM_DEBUG then
  vim.defer_fn(function()
    local stats = _G.LazyVimConfig.utils.get_stats()
    vim.notify(
      string.format(
        "LazyVim initialized with %d plugins (%d loaded) in Deno mode: %s",
        stats.count,
        stats.loaded,
        tostring(vim.g.deno_project or false)
      ),
      vim.log.levels.INFO,
      { title = "Configuration Loaded" }
    )
  end, 100)
end

-- ============================================================================
-- END OF CONFIGURATION
-- ============================================================================

-- The configuration continues in:
-- - lua/config/options.lua (editor options)
-- - lua/config/keymaps.lua (key bindings)  
-- - lua/config/autocmds.lua (automatic commands)
-- - lua/plugins/*.lua (plugin configurations)