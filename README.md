# dotfiles

Personal configuration: Neovim, plus a [sioyek build script](sioyek/README.md)
for Ubuntu.

## Neovim

`nvim/` holds the portable config:

- `init.lua` - editor options, plugin list, keymaps
- `nvim-pack-lock.json` - exact commit of every plugin, written by `vim.pack`

This repo is a recipe, not a backup. Neovim itself and the plugin code are
downloaded again on a new machine; the lockfile makes the plugin versions match.

### Setup on a new machine

1. Install the tools Neovim depends on:

   ```sh
   brew install neovim ripgrep
   brew install --cask font-meslo-lg-nerd-font
   ```

   Then select **MesloLGS Nerd Font Mono** as the font in your terminal
   (needed for file icons in oil and telescope).

   Optional:

   ```sh
   brew install fd                    # silences a telescope health warning
   brew install pngpaste imagemagick  # for :Obsidian paste_img
   ```

2. Clone this repo and copy the config into place:

   ```sh
   git clone git@github.com:jackys-95/dotfiles.git ~/github/dotfiles
   mkdir -p ~/.config/nvim
   cp ~/github/dotfiles/nvim/init.lua ~/github/dotfiles/nvim/nvim-pack-lock.json ~/.config/nvim/
   ```

3. Start `nvim`. `vim.pack` asks to confirm installing the plugins, then
   installs them at the commits recorded in the lockfile.

4. Run `:checkhealth` to confirm everything is found.

### Machine-specific settings (private)

Anything private or machine-specific lives in `~/.config/nvim/local.lua`, which is
**not** part of this repo (it is listed in `.gitignore`, and the sync command
below only copies `init.lua` and the lockfile).

Currently it holds one setting, the Obsidian vault path. Create the file by hand
on each machine:

```lua
-- ~/.config/nvim/local.lua
return {
  vault = "~/path/to/your/vault",
}
```

Then restart nvim. The Obsidian plugin is only configured when this file exists
and the folder it points to exists. Without it, the plugin installs but stays
unconfigured, and the `<leader>o` keys are not defined. Check with
`:checkhealth obsidian`.

### Keeping the repo in sync

The live config is `~/.config/nvim`; this repo holds a copy, so changes do not
flow automatically. After editing `init.lua`, or after `vim.pack.update()`
rewrites the lockfile, copy both files back and commit:

```sh
cp ~/.config/nvim/init.lua ~/.config/nvim/nvim-pack-lock.json ~/github/dotfiles/nvim/
```

### Plugins

| Plugin | Purpose |
|---|---|
| telescope.nvim (+ plenary.nvim) | fuzzy finder |
| oil.nvim | edit the filesystem like a buffer |
| obsidian.nvim | work with an Obsidian vault |
| tokyonight.nvim | colorscheme |
| nvim-web-devicons | file icons |

Key bindings (leader is space): `<leader>ff` find files, `<leader>fg` search
text, `<leader>fb` buffers, `<leader>fh` help, `-` open oil, and `<leader>o`
followed by `n`/`s`/`q`/`b`/`t` for Obsidian new/search/quick-switch/backlinks/today.
