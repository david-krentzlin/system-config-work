-- init.lua (minimal)
-- Bootstrap lazy.nvim (plugin manager)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Basic Neovim options
vim.o.number = true
vim.o.relativenumber = true
vim.o.clipboard = "unnamedplus"
vim.o.termguicolors = true
vim.o.cursorline = true
vim.o.swapfile = false
vim.o.backup = false
vim.o.undofile = true

-- Minimal keymap: leader
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>q", ":q<CR>", { silent = true })

-- Plugin specification (only kanagawa here)
require("lazy").setup(
 { 
	"catppuccin/nvim", 
	name = "catppuccin", 
	priority = 1000, 
	opts = { flavour = "mocha", color_overrides= { mocha = { base = "#000000"  } } },
	init = function()
		vim.cmd.colorscheme "catppuccin-mocha"
	end
  }
  ,
 {
  checker = { enabled = true }, -- optional: auto-check for plugin updates
})

-- Minimal autocommands: reapply termguicolors on VimEnter (safe)
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function() vim.o.termguicolors = true end
})
