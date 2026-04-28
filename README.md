# LifE's DoomEmacs configuration

This is a simple NeoVim-like setup for DoomEmacs, that come with Helix-like QoLs predefined.

## Setup

``` sh
git clone https://github.com/MGlolenstine/doom_dotfiles.git ~/.config/doom
~/.config/doom/bin/bootstrap-debugging
doom sync
```

## Debugging Setup

JavaScript / TypeScript debugging uses `dape` with a pinned `vscode-js-debug`
release unpacked into `debug-adapters/js-debug/`.

Run `bin/bootstrap-debugging` after cloning the repo, or whenever the adapter is
missing. Emacs will warn at startup and when launching a debug config if either
the adapter or `tsx` is not installed.

## Doom Cheatsheet

High-ROI commands for this config.

Note: `SPC s .` is not bound in this Evil setup. Use `SPC *` for project symbol search.

## Help

| Key | Command | Why it matters |
|---|---|---|
| `SPC h b b` | Find commands available in the current buffer | Blazingly fast way of learning keybinds |
| `SPC h k` | Find what some key combination does | Useful when Emacs does something you don't want |
| `SPC :` | Open `M-x` command entry | Gives access to `M` when other programs are already using it |

## Must Use

| Key | Command | Why it matters |
|---|---|---|
| `SPC SPC` | Find file in project | Fastest way to open a file |
| `SPC /` | Search project | Best general project search |
| `SPC *` | Search symbol in project | Find symbol usage in the repo |
| `SPC s b` | Search buffer | Fast in-file search |
| `SPC s d` | Search current directory | Narrow search scope |
| `SPC s i` | Jump to symbol | File outline / function jump |
| `SPC ,` | Switch buffer | Fast buffer switching |
| `SPC b d` | Kill buffer | Good for throwaway editing |
| `SPC p p` | Switch project | Move to another repo |
| `SPC p f` | Find file in project | Project-local file picker |
| `SPC p k` | Kill project buffers | Clean repo state quickly |
| `SPC x` | Run project command | Best for package scripts / Makefile targets |
| `SPC p !` | Run command in project root | Sync shell command from Emacs |
| `SPC p &` | Async command in project root | Fire-and-forget shell command |
| `SPC g g` | Magit status | Best Git entry point |
| `SPC g s` | Stage hunk | Fast partial staging |
| `SPC a` | Embark act | Context actions on candidate/thing at point |
| `C-c C-e` | Export search to writable buffer | Edit search results in bulk |
| `C-x C-d` | consult-dir | Jump to a directory in prompts |
| `C-x C-j` | consult-dir-jump-file | Drill into files under a chosen dir |

## Also Worth Knowing

| Key | Command | Notes |
|---|---|---|
| `SPC s r` | Visual regex replace | Good for structured replacements |
| `SPC c f` | Format buffer | Clean up before saving/running |
| `SPC o d` | Start debugger | Opens `dape` |
| `SPC g t` | Git time machine | Browse file history |
| `SPC g r` | Revert hunk | Undo a bad change fast |
| `SPC v e` | Expand region | Fast selection growth |
| `SPC v c` | Contract region | Shrink selection |
| `SPC m n` | Mark next like this | Multi-cursor editing |
| `SPC m p` | Mark previous like this | Multi-cursor editing |
| `SPC m c` | Mark all like this | Multi-cursor editing |
