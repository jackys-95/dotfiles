-- Leader key (must be set before any <leader> mappings)
vim.g.mapleader = " "

-- Editor options
vim.opt.number = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true -- case-sensitive only if the search has a capital
vim.opt.showmatch = true
vim.opt.wildmode = "longest,list"
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Soft wrap: break long lines at word boundaries, keep wrapped lines indented
vim.opt.linebreak = true
vim.opt.breakindent = true

-- 2-space indent for web filetypes
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascript", "typescript", "html", "css" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
  end,
})

-- Markdown: hide link/emphasis syntax (needed by obsidian.nvim's UI too)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.conceallevel = 2
  end,
})

-- Plugins (built-in vim.pack; exact commits are recorded in nvim-pack-lock.json)
vim.pack.add({
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/nvim-tree/nvim-web-devicons",
  { src = "https://github.com/nvim-telescope/telescope.nvim", version = "v0.2.2" },
  "https://github.com/stevearc/oil.nvim",
  { src = "https://github.com/folke/tokyonight.nvim", version = "v4.14.1" },
  { src = "https://github.com/obsidian-nvim/obsidian.nvim", version = vim.version.range("*") },
})

-- Colorscheme (variants: tokyonight-night / -storm / -moon / -day)
vim.cmd.colorscheme("tokyonight")

-- Telescope: fuzzy finder (live_grep needs ripgrep)
local builtin = require("telescope.builtin")
require("telescope").setup({})
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Search text in files" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Open buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })

-- Oil: edit the filesystem like a buffer; replaces netrw for directory opens
require("oil").setup({ default_file_explorer = true })
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

-- Obsidian (uses telescope as the picker). The vault path is machine-specific
-- and private, so it lives in an untracked local.lua next to this file:
--   return { vault = "~/path/to/vault" }
-- Without that file (or if the folder is missing), Obsidian is not set up.
local has_local, localcfg = pcall(dofile, vim.fn.stdpath("config") .. "/local.lua")
local vault = has_local and type(localcfg) == "table" and localcfg.vault and vim.fn.expand(localcfg.vault) or nil
if vault and vim.fn.isdirectory(vault) == 1 then
  require("obsidian").setup({
    legacy_commands = false,
    workspaces = { { name = "notes", path = vault } },
    picker = { name = "telescope.nvim" },
  })
  vim.keymap.set("n", "<leader>on", "<CMD>Obsidian new<CR>", { desc = "Obsidian: new note" })
  vim.keymap.set("n", "<leader>os", "<CMD>Obsidian search<CR>", { desc = "Obsidian: search notes" })
  vim.keymap.set("n", "<leader>oq", "<CMD>Obsidian quick_switch<CR>", { desc = "Obsidian: quick switch" })
  vim.keymap.set("n", "<leader>ob", "<CMD>Obsidian backlinks<CR>", { desc = "Obsidian: backlinks" })
  vim.keymap.set("n", "<leader>ot", "<CMD>Obsidian today<CR>", { desc = "Obsidian: today's note" })
end
