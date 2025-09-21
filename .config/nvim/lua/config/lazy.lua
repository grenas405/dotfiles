-- lua/config/lazy.lua
-- Bootstrap and configure lazy.nvim plugin manager with LazyVim

-- Bootstrap lazy.nvim if not installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Configure lazy.nvim and LazyVim
require("lazy").setup({
  -- Plugin specifications
  spec = {
    -- LazyVim core distribution
    {
      "LazyVim/LazyVim",
      import = "lazyvim.plugins",
      opts = {
        -- LazyVim configuration options
        colorscheme = "tokyonight", -- Default colorscheme
        news = {
          -- Disable LazyVim news notifications
          enabled = false,
        },
      },
    },
    
    -- Import user plugin configurations from lua/plugins/
    { import = "plugins" },
  },
  
  -- Default plugin configuration
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded
    -- Your plugins will be lazy-loaded by default
    lazy = false,
    
    -- Use stable versions for LazyVim plugins
    version = false,
    
    -- Don't update plugin versions automatically
    cond = nil,
  },
  
  -- Package manager configuration
  pkg = {
    enabled = true,
    cache = vim.fn.stdpath("state") .. "/lazy/pkg-cache.lua",
    -- The first package source that is found for a plugin will be used
    sources = {
      "lazy",
      "rockspec", -- Luarocks support
      "packspec",
    },
  },
  
  -- Rocks configuration for Luarocks support
  rocks = {
    enabled = true,
    root = vim.fn.stdpath("data") .. "/lazy-rocks",
    server = "https://nvim-neorocks.github.io/rocks-binaries/",
  },
  
  -- Installation configuration
  install = {
    -- Install missing plugins on startup
    missing = true,
    
    -- Try to load one of these colorschemes when starting an installation during startup
    colorscheme = { "tokyonight", "habamax" },
  },
  
  -- Update configuration
  checker = {
    enabled = true, -- Enable automatic plugin update checking
    concurrency = nil, -- Use available cores for checking
    notify = false, -- Don't notify about plugin updates (use :Lazy to check manually)
    frequency = 3600, -- Check for updates every hour
    check_pinned = false, -- Don't check for updates for pinned plugins
  },
  
  -- Change detection configuration
  change_detection = {
    enabled = true, -- Enable automatic reloading when plugin files change
    notify = false, -- Don't notify about changes (reduces noise)
  },
  
  -- UI configuration
  ui = {
    -- The border style to use for the UI window
    border = "rounded",
    
    -- The backdrop transparency (0-100)
    backdrop = 60,
    
    -- Window size configuration
    size = { width = 0.8, height = 0.8 },
    
    -- Window position
    wrap = true,
    
    -- UI icons configuration
    icons = {
      cmd = " ",
      config = "",
      event = " ",
      ft = " ",
      init = " ",
      import = " ",
      keys = " ",
      lazy = "󰒲 ",
      loaded = "●",
      not_loaded = "○",
      plugin = " ",
      runtime = " ",
      require = "󰢱 ",
      source = " ",
      start = " ",
      task = "✔ ",
      list = {
        "●",
        "➜",
        "★",
        "‒",
      },
    },
    
    -- Custom commands in the UI
    custom_keys = {
      -- Open lazygit for plugin management
      ["<localleader>l"] = {
        function(plugin)
          require("lazy.util").float_term({ "lazygit", "log" }, {
            cwd = plugin.dir,
          })
        end,
        desc = "Open lazygit log",
      },
      
      -- Open terminal in plugin directory
      ["<localleader>t"] = {
        function(plugin)
          require("lazy.util").float_term(nil, {
            cwd = plugin.dir,
          })
        end,
        desc = "Open terminal in plugin dir",
      },
    },
  },
  
  -- Diff configuration for viewing plugin changes
  diff = {
    cmd = "git",
  },
  
  -- Performance optimizations
  performance = {
    -- Cache configuration
    cache = {
      enabled = true,
      path = vim.fn.stdpath("cache") .. "/lazy/cache",
      -- TTL for cached data (in ms)
      ttl = 3600 * 1000, -- 1 hour
      -- Disable cache for specific events (optional performance tuning)
      disable_events = {},
    },
    
    -- Reset package path to improve startup time
    reset_packpath = true,
    
    -- Runtime path optimizations
    rtp = {
      reset = true, -- Reset runtime path to improve startup time
      
      -- Paths to add to runtime path
      paths = {
        -- Add custom runtime paths here if needed
      },
      
      -- Disable unused built-in plugins for faster startup
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
        "rplugin", -- Remote plugin support (usually not needed)
        "syntax", -- Use Treesitter instead
        "synmenu", -- Syntax menu
        "optwin", -- Options window
        "compiler", -- Compiler support
        "bugreport", -- Bug report functionality
        "ftplugin", -- Some built-in ftplugin files (we use custom ones)
      },
    },
  },
  
  -- Development configuration
  dev = {
    -- Directory where local dev plugins are stored
    path = "~/projects",
    
    -- Patterns for local dev plugins
    patterns = {}, -- For example: { "folke" }
    
    -- Fallback to git when local plugin doesn't exist
    fallback = false,
  },
  
  -- Profiling configuration (useful for debugging startup time)
  profiling = {
    -- Enables extra stats on the debug tab related to the loader cache
    loader = false,
    
    -- Track each new require in the Lazy profiling tab
    require = false,
  },
  
  -- Lockfile configuration
  lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json",
  
  -- Git configuration
  git = {
    -- Git command timeout (in seconds)
    timeout = 120,
    
    -- Default URL format for GitHub repositories
    url_format = "https://github.com/%s.git",
    
    -- Git command arguments
    log = { "-8" }, -- Show last 8 commits
    
    -- Git filter for clone operations
    filter = {
      "blob:none", -- Partial clone without blobs (faster)
    },
  },
  
  -- Headless mode configuration (for CI/testing)
  headless = {
    -- List of plugins to install in headless mode
    -- Useful for CI environments
    process_timeout = 300, -- 5 minutes timeout
  },
  
  -- Readme configuration
  readme = {
    enabled = true,
    root = vim.fn.stdpath("state") .. "/lazy/readme",
    files = { "README.md", "lua/**/README.md" },
    
    -- Only show README if plugin doesn't have proper documentation
    skip_if_doc_exists = true,
  },
  
  -- State configuration
  state = vim.fn.stdpath("state") .. "/lazy/state.json",
  
  -- Debug configuration
  debug = false, -- Set to true for debug information
})

-- Auto-install missing plugins on VimEnter
local function auto_install()
  local lazy_stats = require("lazy").stats()
  if lazy_stats.count == 0 then
    return
  end
  
  -- Check if any plugins are missing
  local has_missing = false
  for _, plugin in pairs(require("lazy").plugins()) do
    if not plugin._.installed then
      has_missing = true
      break
    end
  end
  
  if has_missing then
    vim.notify("Installing missing plugins...", vim.log.levels.INFO, { title = "Lazy" })
    require("lazy").install({ wait = true })
    vim.notify("Plugin installation complete!", vim.log.levels.INFO, { title = "Lazy" })
  end
end

-- Set up auto-installation
vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("LazyAutoInstall", { clear = true }),
  callback = auto_install,
})

-- Performance monitoring (optional)
if vim.env.LAZY_PROFILE then
  vim.api.nvim_create_autocmd("VimEnter", {
    group = vim.api.nvim_create_augroup("LazyProfile", { clear = true }),
    callback = function()
      vim.schedule(function()
        local stats = require("lazy").stats()
        local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
        vim.notify(
          string.format("Lazy loaded %d/%d plugins in %.2fms", stats.loaded, stats.count, ms),
          vim.log.levels.INFO,
          { title = "Lazy Profile" }
        )
      end)
    end,
  })
end

-- Custom keybindings for Lazy commands
vim.keymap.set("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy Plugin Manager" })
vim.keymap.set("n", "<leader>lx", "<cmd>LazyExtras<cr>", { desc = "LazyVim Extras" })
vim.keymap.set("n", "<leader>lu", "<cmd>Lazy update<cr>", { desc = "Update Plugins" })
vim.keymap.set("n", "<leader>ls", "<cmd>Lazy sync<cr>", { desc = "Sync Plugins" })
vim.keymap.set("n", "<leader>li", "<cmd>Lazy install<cr>", { desc = "Install Plugins" })
vim.keymap.set("n", "<leader>lc", "<cmd>Lazy clean<cr>", { desc = "Clean Plugins" })
vim.keymap.set("n", "<leader>lr", "<cmd>Lazy restore<cr>", { desc = "Restore Plugins" })
vim.keymap.set("n", "<leader>lp", "<cmd>Lazy profile<cr>", { desc = "Profile Plugins" })
vim.keymap.set("n", "<leader>ld", "<cmd>Lazy debug<cr>", { desc = "Debug Plugins" })
vim.keymap.set("n", "<leader>ll", "<cmd>Lazy log<cr>", { desc = "View Plugin Log" })
vim.keymap.set("n", "<leader>lh", "<cmd>Lazy health<cr>", { desc = "Plugin Health Check" })

-- Export configuration for external use
return {
  -- Configuration values that other modules might need
  config = {
    lazypath = lazypath,
    dev_mode = vim.env.LAZY_DEV ~= nil,
    profile_mode = vim.env.LAZY_PROFILE ~= nil,
  },
  
  -- Utility functions
  utils = {
    -- Check if a plugin is loaded
    is_loaded = function(plugin_name)
      return require("lazy.core.config").plugins[plugin_name] and 
             require("lazy.core.config").plugins[plugin_name]._.loaded
    end,
    
    -- Load a plugin on demand
    load_plugin = function(plugin_name)
      require("lazy").load({ plugins = { plugin_name } })
    end,
    
    -- Get plugin statistics
    get_stats = function()
      return require("lazy").stats()
    end,
  },
}