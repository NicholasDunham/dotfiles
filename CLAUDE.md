# Dotfiles

Shared shell config, scripts, and Homebrew packages for three Macs (including a
Mac mini and a work laptop), managed with Homebrew and GNU Stow. See README.md
for the full setup guide.

## Working in this repo

- Ask before uninstalling software, deleting user data, or running anything
  with `sudo`. For `sudo` commands, give the user the command to run themselves.
- Commit directly to `main` with short, imperative subject lines. Don't push
  without asking; the repository is public.

## Layout and conventions

- Stow packages: `bin/` (scripts, linked into `~/bin`) and `zsh/` (`.zshenv`,
  `.zprofile`, `.zshrc`, `.p10k.zsh`). Run `stow` from the repo root.
- Keep `~/bin` a real directory (`mkdir -p ~/bin` before `stow bin`), so Stow
  links individual scripts instead of replacing `~/bin` with a symlink into the
  repo.
- `HOMEBREW_PREFIX` is set only in `.zshenv`. `.zshenv` also has
  `typeset -U PATH path FPATH fpath`; all four are needed because macOS
  `path_helper` assigns `PATH` directly.
- In `.zshrc`, keep the `source ~/.p10k.zsh` spelling. `p10k configure` doesn't
  recognize `"$HOME/.p10k.zsh"` and appends a duplicate source line if it can't
  find one. The wizard writes through the symlink, so changes land in the repo.
- `bin/bin/brewup` replaces the old `brewup` alias. It doesn't use the Brewfile;
  it updates whatever is installed on the machine it runs on.

## Brewfile

- The Brewfile currently matches one personal Mac only, not the work laptop or
  the Mac mini.
- Never run `brew bundle install` or `brew bundle cleanup` on the work laptop
  without asking: `install` would add personal software, and `cleanup --force`
  would uninstall work tools that aren't listed.
- Regenerate with `brew bundle dump --force` (`--describe` is disabled in
  current Homebrew; descriptions are included by default). Then remove
  `go "ankiprep/cmd/ankiprep"`: it's built from a local module, so `go install`
  can't fetch it and `brew bundle install` would fail.
- Planned but not done yet: split per-machine software into extra files (e.g.
  `Brewfile.work`) installed with `brew bundle install --file=...`.

## Setting up a machine that predates the 2026-10 cleanup

The work laptop and Mac mini still have the old `brewup` alias in a local,
uncommitted `.zshrc` edit and may have the leftovers listed below.

1. `git pull`. If it's blocked by local edits to the zsh files, review them
   with the user; the `brewup` alias line can be discarded.
2. `mkdir -p ~/bin && stow bin && stow -R zsh`. If `~/.p10k.zsh` is a regular
   file, move it aside first and compare it with `zsh/.p10k.zsh`.
3. Make sure `neovim` (for `EDITOR`), `zsh-autosuggestions`, and
   `zsh-syntax-highlighting` are installed.
4. In a new shell, `whence -v brewup` should show `~/bin/brewup`, not an alias.

## Known leftovers to check for

First check whether each tool is actually still installed. If it is, removing
it is the user's decision.

- **Nix / nix-darwin / nix-homebrew / Home Manager**
  - `brew doctor` says "Your Homebrew installation is managed by Nix" if
    `$(brew --prefix)/.managed_by_nix_darwin` exists (see
    `Library/Homebrew/os.rb`, `nix_homebrew?`). Delete that marker file.
  - `/etc/nix` (only `macos-keychain.crt`, a copy of Keychain CAs),
    `/etc/bash.bashrc` (only a Nix block; macOS doesn't ship it), and an empty
    `/Applications/Nix Apps` all need `sudo`.
  - `~/.nix-defexpr`, `~/.nix-profile`, `~/.nix-channels`, `~/.local/state/nix`,
    `~/.local/state/home-manager`, `~/.cache/nix`.
  - Broken symlinks into `/nix/store`, e.g. `~/Applications/Home Manager Apps`
    and config files that Home Manager managed (such as
    `~/.config/tmux/tmux.conf`). The real files were only in the store, so the
    content is gone. Find them with:
    `find ~ -maxdepth 4 -path ~/Library -prune -o -type l -lname '/nix/*' -print`
  - Also check `/etc/synthetic.conf`, `/etc/fstab`, `diskutil apfs list`
    ("Nix Store" volume), `nixbld` users/groups, and launchd daemons
    (`org.nixos.*`, `systems.determinate.*`).
- **OrbStack**: `~/.orbstack`, the `Include ~/.orbstack/ssh/config` block at the
  top of `~/.ssh/config`, a `source ~/.orbstack/shell/init.zsh` line in
  `.zprofile`, and in `~/.docker`: `"currentContext": "orbstack"` in
  `config.json`, its context under `contexts/meta/`, `buildx/current`, and
  broken links in `cli-plugins/`. Keep other `config.json` settings (e.g.
  `credHelpers`).
- **Podman**: `~/.config/containers` and `~/.local/share/containers` (VM and
  Podman Desktop data, ~7 GB on one machine), plus any `docker='podman'` alias.
- **Emacs / Doom**: `~/.config/emacs`, `~/.config/doom`, `~/.local/share/doom`,
  `~/.cache/emacs`, `/Applications/Emacs.app` (a link to a removed
  `emacs-plus`), and `emacs`/`emacsclient`/`ec` in `~/bin`.
- **Duplicate `container`**: the old `container` cask (a `.pkg` in `/usr/local`)
  next to the `container` formula. Uninstalling the cask needs `sudo`.

## Gotchas

- In zsh, an unmatched glob aborts the whole command ("no matches found"), so
  one missing path can silently skip every other check on the same line. Loop
  over paths with `[ -e ]` tests instead.
- `status` is a read-only special variable in zsh; don't use it as a variable
  name in scripts.
- `xattr -dr com.apple.quarantine` succeeds when the attribute is absent, but
  fails if the path doesn't exist.
