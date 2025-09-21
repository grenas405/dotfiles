-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local keymap = vim.keymap.set

-- Leader key configuration
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Navigation
keymap("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Buffer management
keymap("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
keymap("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
keymap("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
keymap("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })

-- File operations
keymap("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New file" })
keymap("n", "<leader>fs", "<cmd>w<cr>", { desc = "Save file" })
keymap("n", "<leader>fq", "<cmd>q<cr>", { desc = "Quit" })

-- Deno-specific shortcuts
keymap("n", "<leader>dr", "<cmd>!deno run %<cr>", { desc = "Run Deno file" })
keymap("n", "<leader>dt", "<cmd>!deno test<cr>", { desc = "Run Deno tests" })
keymap("n", "<leader>df", "<cmd>!deno fmt<cr>", { desc = "Format with Deno" })
keymap("n", "<leader>dl", "<cmd>!deno lint<cr>", { desc = "Lint with Deno" })
