return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      typescript = { "deno_fmt" },
      javascript = { "deno_fmt" },
      typescriptreact = { "deno_fmt" },
      javascriptreact = { "deno_fmt" },
      json = { "deno_fmt" },
      jsonc = { "deno_fmt" },
      markdown = { "deno_fmt" },
      lua = { "stylua" },
    },
    
    formatters = {
      deno_fmt = {
        command = "deno",
        args = { "fmt", "-" },
        stdin = true,
        condition = function(ctx)
          return vim.fn.executable("deno") == 1 and 
                 (vim.fn.filereadable(ctx.dirname .. "/deno.json") == 1 or
                  vim.fn.filereadable(ctx.dirname .. "/deno.jsonc") == 1)
        end,
      },
    },
    
    format_on_save = {
      timeout_ms = 500,
      lsp_fallback = true,
    },
  },
}