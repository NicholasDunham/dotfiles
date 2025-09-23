# Nicholas Dunham's Dotfiles

A repository for managing and synchronizing configuration files between my home and work macOS machines.

## Overview

This dotfiles repository uses a combination of Homebrew and GNU Stow to create a consistent, reproducible environment across different machines. The setup includes:

- Homebrew for package management and applications
- GNU Stow for dotfile symlink management
- Doom Emacs configuration
- Zsh shell configuration with Powerlevel10k

## Repository Structure

- **Brewfile**: Defines all packages, applications, and VS Code extensions to install via Homebrew
- **doom/**: Configuration files for Doom Emacs
  - Organized in the `.config/doom` structure for Stow compatibility
- **zsh/**: Zsh shell configuration files
  - `.zshenv`, `.zprofile`, `.zshrc` for comprehensive shell setup
  - Includes Homebrew integration and Powerlevel10k prompt

## System Setup Guide

### Prerequisites

- macOS (Apple Silicon or Intel)
- Administrator access

### Fresh System Installation

1. **Clone this repository**:

   ```bash
   git clone https://github.com/NicholasDunham/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

2. **Install Homebrew**:

   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

   Add Homebrew to your PATH:

   ```bash
   echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
   eval "$(/opt/homebrew/bin/brew shellenv)"
   ```

3. **Install packages from Brewfile**:

   ```bash
   cd ~/dotfiles
   brew bundle install
   ```

   This installs all formulae, casks, and VS Code extensions defined in the Brewfile.

4. **Install dotfiles with Stow**:

   ```bash
   cd ~/dotfiles
   stow doom zsh
   ```

   This creates symlinks for:
   - Doom Emacs configuration in `~/.config/doom`
   - Zsh configuration files in your home directory

5. **Initialize Doom Emacs**:

   ```bash
   # Clone Doom Emacs
   git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs

   # Install Doom Emacs
   ~/.config/emacs/bin/doom install

   # Sync your configuration
   ~/.config/emacs/bin/doom sync
   ```

6. **Configure Powerlevel10k** (optional):

   ```bash
   # Run the configuration wizard
   p10k configure
   ```

7. **Reload your shell**:

   ```bash
   exec zsh -l
   ```

## Using Stow with Dotfiles

### Adding New Dotfile Packages

To add a new application's configuration:

1. **Create a package directory**:

   ```bash
   cd ~/dotfiles
   mkdir myapp
   ```

2. **Organize files in the target structure**:

   ```bash
   # For files that go in home directory
   mkdir -p myapp
   # Add your config files, e.g.:
   echo "alias myapp='myapp --flag'" > myapp/.myapprc
   
   # For files that go in ~/.config
   mkdir -p myapp/.config/myapp
   echo "setting=value" > myapp/.config/myapp/config.yml
   ```

3. **Stow the package**:

   ```bash
   stow myapp
   ```

### Managing Existing Packages

- **Stow a package**: `stow package-name`
- **Unstow a package**: `stow -D package-name`
- **Restow a package** (useful after updates): `stow -R package-name`
- **Simulate stowing** (dry run): `stow -n -v package-name`
- **Stow all packages**: `stow *` (or just `stow` with no arguments)

### Stow Best Practices

- Always run stow commands from your dotfiles directory
- Use `-n -v` flags to preview changes before applying
- Organize files exactly as they should appear in your home directory
- Use meaningful package names that match the application
- Keep related configurations in the same package

## Homebrew Maintenance

### Keeping Software Updated

```bash
# Update Homebrew itself and all packages
brew update && brew upgrade --greedy

# Update only specific packages
brew upgrade package-name

# Update from Brewfile (installs missing, doesn't remove extra)
cd ~/dotfiles
brew bundle install
```

### Cleaning Up Unused Software

To remove software that's installed but not in your Brewfile:

```bash
# Generate a new Brewfile with everything currently installed
cd ~/dotfiles
brew bundle dump --force --describe

# Compare with your existing Brewfile to see what's extra
git diff Brewfile

# Remove software not in Brewfile (use with caution)
brew bundle cleanup --force

# Or remove specific packages manually
brew uninstall package-name
brew uninstall --cask app-name
```

### Brewfile Maintenance

```bash
# Add currently installed packages to Brewfile
brew bundle dump --force --describe

# Install missing packages from Brewfile
brew bundle install

# Check what would be installed/removed
brew bundle check --verbose

# Clean up old cached downloads
brew cleanup
```

### Managing Dependencies

```bash
# See what depends on a package
brew uses package-name --installed

# See dependencies of a package
brew deps package-name

# Remove orphaned dependencies
brew autoremove
```

## Configuration Details

### Zsh Configuration

The Zsh setup includes:

- **Environment variables** (.zshenv): HOMEBREW_PREFIX and other essentials
- **Login shell setup** (.zprofile): PATH configuration, Homebrew initialization
- **Interactive shell** (.zshrc): Prompt, completions, aliases, plugins

Key features:

- Homebrew integration for both login and non-login shells
- Powerlevel10k prompt with Git integration
- FZF integration for fuzzy finding
- GNU coreutils prioritized in PATH
- Optional zsh-autosuggestions and zsh-syntax-highlighting

### Doom Emacs Configuration

Located in `doom/.config/doom/`, includes:

- Custom key bindings and workflow optimizations
- Language-specific configurations
- Package customizations

## Troubleshooting

### Stow Issues

- **"Target exists and is not a symlink"**: Remove or backup the existing file
- **Permission denied**: Ensure you have write access to the target directory
- **Broken symlinks**: Unstow and restow the package

### Homebrew Issues

- **Permission errors**: Fix Homebrew ownership with `sudo chown -R $(whoami) $(brew --prefix)`
- **Path issues**: Ensure Homebrew is in your PATH via shell configuration
- **Tap failures**: Create missing directories and fix ownership

### Zsh Issues

- **Prompt not loading**: Ensure Powerlevel10k is installed and HOMEBREW_PREFIX is set
- **Commands not found**: Check PATH configuration in .zprofile
- **Slow startup**: Review .zshrc for expensive operations

## License

MIT
