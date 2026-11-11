# mdterm

mdterm is a Rust terminal Markdown viewer. This guide reproduces the build tested in Rex on 2026-11-11.

## Install the tested revision

Install Rust and Cargo 1.85 or newer, then clone and build the tested upstream revision:

```sh
git clone https://github.com/bahdotsh/mdterm.git ~/github/mdterm
git -C ~/github/mdterm checkout 5560db756e60
cargo install --path ~/github/mdterm
```

Cargo installs the `mdterm` executable under `~/.cargo/bin` by default. To try another upstream revision, check it out and rebuild with `cargo install --path ~/github/mdterm --force`.

## Use in Rex

Open a Markdown file with:

```sh
mdterm "/path/to/note.md"
```

mdterm watches the open file and reloads it after changes are saved. Use `j`/`k` or the arrow keys to scroll, `o` to open the table of contents, and `/` to search.

Rex can display Kitty graphics, but mdterm does not identify Rex automatically. In Rex, automatic image mode falls back to Unicode half-blocks, which makes photos look blocky. Force Kitty graphics only in Rex by adding this to `~/.zshrc`:

```zsh
if [[ -n "${REX_SESSION:-}" ]]; then
  export MDTERM_IMAGE_PROTOCOL=kitty
fi
```

Reload the shell with `source ~/.zshrc` or open a new Rex shell. To force the protocol for one launch only:

```sh
MDTERM_IMAGE_PROTOCOL=kitty mdterm "/path/to/note.md"
```

## Mermaid and image limitations

- Mermaid flowcharts render as terminal box-drawing characters. They do not use Kitty graphics, and mdterm has no diagram zoom or pan controls.
- Inline photos render through Kitty graphics when the Rex override is active. For native-size inspection on macOS, use `open -a Preview "/path/to/image.png"` and choose View > Actual Size.
- Leave automatic image protocol detection enabled outside Rex unless the terminal is known to support Kitty graphics.

These behaviors were checked in Rex with an actual photo and a Mermaid flowchart on 2026-11-11.
