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

3. **Create necessary directories**:

   ```bash
   mkdir -p ~/.config ~/bin
   ```

4. **Stow configurations using Nix**:

   Use Nix to temporarily provide GNU Stow and stow your configurations:

   ```bash
   cd ~/dotfiles
   nix shell nixpkgs#stow --command stow
   ```

   This will automatically stow the `bin`, `doom`, and `nix` directories to your home directory, placing:

   - Nix configuration in `~/.config/nix`
   - Doom Emacs configuration in `~/.config/doom`
   - Scripts in `~/bin`

5. **Build your system using Nix**:

   ```bash
   # For personal MacBook
   ~/bin/rebuild.sh home

   # For work MacBook
   ~/bin/rebuild.sh work
   ```

   The first build may take some time as it downloads and builds all packages.

   After this step, open a new terminal session for the changes to take effect. From this point on, `~/bin` will be in your PATH.

6. **Initialize Doom Emacs**:

   After Nix has installed Emacs:

   ```bash
   # Clone Doom Emacs if it doesn't exist yet
   [ ! -d ~/.config/emacs ] && git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs

   # Install Doom Emacs
   ~/.config/emacs/bin/doom install

   # Sync your configuration
   ~/.config/emacs/bin/doom sync
   ```

## Usage

### Rebuilding Your System

After making changes to your Nix configuration, rebuild your system:

```bash
rebuild.sh home
# OR
rebuild.sh work
```

### Managing Development Environments

Enable or disable specific development environments:

```bash
# Enable Python environment
rebuild.sh home "" python enable

# Disable Rust environment
rebuild.sh home "" rust disable
```

Available modules include: python, rust, go, javascript, clojure, haskell, and creative.

### Updating Packages

Update your system with the latest packages:

```bash
# Update and rebuild
rebuild.sh home update
```

### Updating Dotfiles

When you make changes to your dotfiles:

1. Commit and push changes to your repository
2. On other machines, pull the latest changes:

   ```bash
   cd ~/dotfiles
   git pull
   ```

3. Re-stow your configurations:

   ```bash
   cd ~/dotfiles
   stow
   ```

4. Rebuild your system if necessary:

   ```bash
   rebuild.sh home
   ```

## Customization

See the detailed documentation in `nix/README.md` for more information on customizing your Nix configuration.

## Troubleshooting

- **Homebrew permissions**: Ensure the user specified in Nix configuration has appropriate permissions.
- **Failed builds**: Check Nix syntax errors in your configuration files.
- **Stow conflicts**: If stow reports conflicts, use `nix shell nixpkgs#stow --command stow -n -v` to simulate stowing and identify conflicts.

## License

MIT
