# Nicholas Dunham's Dotfiles

A repository for managing and synchronizing configuration files between my home and work macOS machines.

## Overview

This dotfiles repository uses a combination of Nix, GNU Stow, and Doom Emacs to create a consistent, reproducible environment across different machines. The setup includes:

- Declarative system configuration with Nix/nix-darwin
- Homebrew integration for macOS-specific applications
- Doom Emacs configuration
- Utility scripts

## Repository Structure

- **bin/**: Scripts that will be symlinked to `~/bin` and included in `$PATH`
  - Contains utility scripts like `rebuild.sh` for Nix configuration
- **doom/**: Configuration files for Doom Emacs
  - Organized in the `.config/doom` structure for Stow compatibility
- **nix/**: Nix flake configuration
  - Contains darwin configurations for home and work environments
  - Includes modular setup for different development environments

## Setup Instructions

### Prerequisites

- macOS (Apple Silicon or Intel)
- Administrator access

### Installation Steps

1. **Clone this repository**:

   ```bash
   git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

2. **Install Nix**:

   Install using the Determinate Systems installer:

   ```bash
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```

   Reload your shell after installation:

   ```bash
   source ~/.zshrc
   ```

3. **Install GNU Stow**:

   Temporarily install GNU Stow using Homebrew (it will be managed by Nix later):

   ```bash
   brew install stow
   ```

4. **Create necessary directories**:

   ```bash
   mkdir -p ~/.config
   ```

5. **Use Stow to place Nix configuration**:

   ```bash
   cd ~/dotfiles
   stow -t ~ nix
   ```

   This will place the Nix configuration in `~/.config/nix`.

6. **Build your system using Nix**:

   ```bash
   # For personal MacBook
   ~/bin/rebuild.sh home

   # For work MacBook
   ~/bin/rebuild.sh work
   ```

   The first build may take some time as it downloads and builds all packages.

7. **Stow other configurations**:

   After Nix has installed all required packages:

   ```bash
   cd ~/dotfiles
   stow -t ~ bin
   stow -t ~ doom
   ```

8. **Initialize Doom Emacs**:

   After Nix has installed Emacs:

   ```bash
   # Clone Doom Emacs if it doesn't exist yet
   [ ! -d ~/.emacs.d ] && git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.emacs.d

   # Install Doom Emacs
   ~/.emacs.d/bin/doom install

   # Sync your configuration
   ~/.emacs.d/bin/doom sync
   ```

## Usage

### Rebuilding Your System

After making changes to your Nix configuration, rebuild your system:

```bash
~/bin/rebuild.sh home
# OR
~/bin/rebuild.sh work
```

### Managing Development Environments

Enable or disable specific development environments:

```bash
# Enable Python environment
~/bin/rebuild.sh home "" python enable

# Disable Rust environment
~/bin/rebuild.sh home "" rust disable
```

Available modules include: python, rust, go, javascript, clojure, haskell, and creative.

### Updating Packages

Update your system with the latest packages:

```bash
# Update and rebuild
~/bin/rebuild.sh home update
```

### Updating Dotfiles

When you make changes to your dotfiles:

1. Commit and push changes to your repository
2. On other machines, pull the latest changes:

   ```bash
   cd ~/dotfiles
   git pull
   ```

3. Re-run stow for any affected components:

   ```bash
   stow -R -t ~ bin
   stow -R -t ~ doom
   ```

4. Rebuild your system if necessary:

   ```bash
   ~/bin/rebuild.sh
   ```

## Customization

See the detailed documentation in `nix/README.md` for more information on customizing your Nix configuration.

## Troubleshooting

- **Homebrew permissions**: Ensure the user specified in Nix configuration has appropriate permissions.
- **Failed builds**: Check Nix syntax errors in your configuration files.
- **Stow conflicts**: If stow reports conflicts, use `stow -n -v -t ~ <package>` to simulate stowing and identify conflicts.

## License

MIT
