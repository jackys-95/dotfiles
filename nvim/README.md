# Neovim

This directory holds the portable Neovim config:

- `init.lua` - editor options and plugin list
- `lua/notes.lua` - Markdown keymaps and Obsidian setup
- `nvim-pack-lock.json` - exact commit of every plugin, written by `vim.pack`

This repo is a recipe, not a backup. Neovim itself and the plugin code are
downloaded again on a new machine; the lockfile makes the plugin versions match.

## Setup on a new machine

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
   mkdir -p ~/.config/nvim/lua
   cp ~/github/dotfiles/nvim/init.lua ~/github/dotfiles/nvim/nvim-pack-lock.json ~/.config/nvim/
   cp ~/github/dotfiles/nvim/lua/notes.lua ~/.config/nvim/lua/
   ```

3. Start `nvim`. `vim.pack` asks to confirm the main plugin list, then installs
   the plugins at the commits recorded in the lockfile. `md-render.nvim` is
   added separately with confirmation disabled for that plugin only.

4. Run `:checkhealth` to confirm everything is found.

## Machine-specific settings (private)

Anything private or machine-specific lives in `~/.config/nvim/local.lua`, which is
**not** part of this repo (it is listed in `.gitignore`, and the sync commands
below copy only the portable config files).

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

## Keeping the repo in sync

The live config is `~/.config/nvim`; this repo holds a copy, so changes do not
flow automatically. After editing the config or after `vim.pack.update()`
rewrites the lockfile, sync the portable files back and commit:

```sh
cp ~/.config/nvim/init.lua ~/.config/nvim/nvim-pack-lock.json ~/github/dotfiles/nvim/
cp ~/.config/nvim/lua/notes.lua ~/github/dotfiles/nvim/lua/
```

## Plugins

| Plugin | Purpose |
|---|---|
| telescope.nvim (+ plenary.nvim) | fuzzy finder |
| oil.nvim | edit the filesystem like a buffer |
| obsidian.nvim | work with an Obsidian vault |
| md-render.nvim | render Markdown inside Neovim |
| tokyonight.nvim | colorscheme |
| nvim-web-devicons | file icons |

Key bindings (leader is space): `<leader>ff` find files, `<leader>fg` search
text, `<leader>fb` buffers, `<leader>fh` help, `-` open oil, `<leader>mp` Markdown
preview, `<leader>ms` source and preview split, and `<leader>o` followed by
`n`/`s`/`q`/`b`/`t` for Obsidian new/search/quick-switch/backlinks/today.

## Markdown preview limitations

`md-render.nvim` requires Neovim 0.12 or newer. It renders Markdown text in
Neovim. Inline images use Kitty graphics; Mermaid diagrams rendered as images
depend on the same image output path.

### Rex limitation (checked 2026-11-11)

In Rex, a shell can display the Kitty checkerboard test image, but Neovim cannot:

- Sending the same Kitty commands through `nvim_ui_send()` in a clean Neovim
  session produced no visible image.
- Opening `/dev/tty` from Neovim failed with `E5108: Device not configured`.
- `md-render.nvim` does not detect `TERM_PROGRAM=rex`; forcing its detector did
  not make the image appear.

Markdown text preview works in Rex; inline images and Mermaid image output do not.
This appears to be a Rex/Neovim UI integration limitation to investigate with the
Rex, Neovim, and md-render.nvim maintainers. No workaround has been verified.
