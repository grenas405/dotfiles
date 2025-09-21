-- ~/.config/nvim/lua/plugins/deno.lua
-- Deno-specific LSP configuration with automatic conflict resolution

return {
  -- Core LSP configuration with Deno support
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "sigmaSd/deno-nvim", -- Enhanced Deno integration
    },
    opts = {
      -- Configure LSP servers
      servers = {
        -- Deno Language Server
        denols = {
          enabled = true,
          root_dir = function(fname)
            return require("lspconfig.util").root_pattern("deno.json", "deno.jsonc")(fname)
          end,
          init_options = {
            lint = true,
            unstable = true,
            suggest = {
              imports = {
                hosts = {
                  ["https://deno.land"] = true,
                  ["https://cdn.nest.land"] = true,
                  ["https://crux.land"] = true,
                }
              }
            }
          },
          settings = {
            deno = {
              enable = true,
              lint = true,
              unstable = true,
              suggest = {
                imports = {
                  hosts = {
                    ["https://deno.land"] = true,
                    ["https://cdn.nest.land"] = true,
                    ["https://crux.land"] = true,
                  },
                },
              },
              inlayHints = {
                parameterNames = { enabled = "all" },
                parameterTypes = { enabled = true },
                variableTypes = { enabled = true },
                propertyDeclarationTypes = { enabled = true },
                functionLikeReturnTypes = { enabled = true },
                enumMemberValues = { enabled = true },
              },
            },
          },
        },
        
        -- TypeScript Language Server (for Node.js projects)
        -- This will be automatically disabled in Deno projects
        vtsls = {
          enabled = true,
          root_dir = function(fname)
            local deno_root = require("lspconfig.util").root_pattern("deno.json", "deno.jsonc")(fname)
            if deno_root then
              return nil -- Disable vtsls in Deno projects
            end
            return require("lspconfig.util").root_pattern("package.json", "tsconfig.json")(fname)
          end,
        },
      },
      
      -- Setup function for enhanced Deno integration
      setup = {
        denols = function(_, opts)
          require("deno-nvim").setup({
            server = opts,
            dap = {
              -- Enable debugging support (optional)
              adapter = {
                type = "executable",
                command = "deno",
                args = { "run", "--inspect-wait", "--allow-all" },
              },
            },
          })
          return true
        end,
      },
    },
  },

  -- Enhanced completion for Deno
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      -- Add additional completion sources for Deno
      table.insert(opts.sources, { name = "nvim_lsp" })
      
      -- Configure completion behavior for TypeScript/Deno
      opts.completion = opts.completion or {}
      opts.completion.completeopt = "menu,menuone,noinsert"
      
      return opts
    end,
  },

  -- Treesitter configuration optimized for TypeScript/Deno
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "typescript",
        "tsx",
        "javascript",
        "json",
        "jsonc",
        "lua",
        "vim",
        "vimdoc",
        "markdown",
        "markdown_inline",
      },
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = {
        enable = true,
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<c-space>",
          node_incremental = "<c-space>",
          scope_incremental = "<c-s>",
          node_decremental = "<M-space>",
        },
      },
    },
  },

  -- File explorer optimized for Deno project structure
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        filtered_items = {
          visible = false,
          hide_dotfiles = false,
          hide_gitignored = true,
          hide_by_name = {
            "node_modules",
            ".DS_Store",
            ".git",
          },
          never_show = {
            ".cache",
            ".deno",
          },
        },
        follow_current_file = {
          enabled = true,
        },
      },
      window = {
        mappings = {
          -- Add Deno-specific commands
          ["<leader>dr"] = function(state)
            local node = state.tree:get_node()
            if node.type == "file" and node.name:match("%.ts$") then
              vim.cmd("!deno run " .. node.path)
            end
          end,
          ["<leader>dt"] = function(state)
            local node = state.tree:get_node()
            if node.type == "file" and node.name:match("_test%.ts$") then
              vim.cmd("!deno test " .. node.path)
            end
          end,
        },
      },
    },
  },

  -- Telescope configuration for Deno projects
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      defaults = {
        file_ignore_patterns = {
          "node_modules",
          ".git/",
          ".cache",
          "%.lock",
          ".deno/",
        },
      },
      pickers = {
        find_files = {
          -- Include TypeScript files and Deno config files
          find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
        },
      },
    },
  },

  -- Disable plugins that might conflict or add unnecessary overhead
  {
    "folke/noice.nvim",
    enabled = false, -- Disable for better performance
  },
  
  {
    "lukas-reineke/indent-blankline.nvim",
    enabled = false, -- Disable for better performance
  },

  -- Optional: Add deno-specific status line information
  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    opts = function(_, opts)
      -- Add Deno status to lualine
      table.insert(opts.sections.lualine_x, 1, {
        function()
          local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
          if buf_ft == "typescript" or buf_ft == "typescriptreact" then
            local root_dir = require("lspconfig.util").root_pattern("deno.json", "deno.jsonc")(vim.loop.cwd())
            if root_dir then
              return "🦕 Deno"
            else
              return "📦 Node"
            end
          end
          return ""
        end,
        color = { fg = "#6CB6FF" },
      })
      return opts
    end,
  },
}