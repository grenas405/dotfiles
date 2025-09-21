return {
  -- Deno LSP Configuration
  {
    "neovim/nvim-lspconfig",
    dependencies = { "sigmaSd/deno-nvim" },
    opts = {
      servers = {
        denols = {
          root_dir = function(fname)
            local util = require("lspconfig.util")
            return util.root_pattern("deno.json", "deno.jsonc", "deno.lock")(fname)
          end,
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
                    ["https://esm.sh"] = true,
                    ["https://cdn.skypack.dev"] = true,
                    ["https://unpkg.com"] = true,
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
      },
      setup = {
        denols = function(_, opts)
          require("deno-nvim").setup({ server = opts })
          return true
        end,
      },
    },
  },

  -- Prevent TypeScript server conflicts
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ts_ls = {
          root_dir = function(fname)
            local util = require("lspconfig.util")
            local deno_root = util.root_pattern("deno.json", "deno.jsonc")(fname)
            if deno_root then
              return nil
            end
            return util.root_pattern("package.json", "tsconfig.json")(fname)
          end,
          single_file_support = false,
        },
      },
    },
  },

  -- Deno debugging support
  {
    "mfussenegger/nvim-dap",
    dependencies = { "rcarriga/nvim-dap-ui" },
    opts = function()
      local dap = require("dap")
      
      dap.configurations.typescript = {
        {
          type = 'pwa-node',
          request = 'launch',
          name = "Launch Deno file",
          runtimeExecutable = "deno",
          runtimeArgs = { "run", "--inspect-wait", "--allow-all" },
          program = "${file}",
          cwd = "${workspaceFolder}",
          attachSimplePort = 9229,
        },
      }
    end,
  },
}