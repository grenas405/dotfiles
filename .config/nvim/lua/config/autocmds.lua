-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Highlight on yank
autocmd("TextYankPost", {
  group = augroup("highlight_yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Auto-format on save for Deno files
autocmd("BufWritePre", {
  group = augroup("deno_format", { clear = true }),
  pattern = { "*.ts", "*.js", "*.tsx", "*.jsx" },
  callback = function()
    local bufname = vim.api.nvim_buf_get_name(0)
    if vim.fn.executable("deno") == 1 and 
       (vim.fn.filereadable("deno.json") == 1 or 
        vim.fn.filereadable("deno.jsonc") == 1) then
      vim.cmd("silent !deno fmt " .. bufname)
      vim.cmd("edit")
    end
  end,
})

-- Restore cursor position
autocmd("BufReadPost", {
  group = augroup("restore_cursor", { clear = true }),
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})
