# Nicholas Dunham's Nix Configuration

A comprehensive, modular Nix configuration for managing macOS machines with nix-darwin, Home Manager, and Homebrew integration.

## Table of Contents

- [Overview](#overview)
- [Directory Structure](#directory-structure)
- [Using Profiles](#using-profiles)
- [Managing Modules](#managing-modules)
- [Customization](#customization)
  - [Adding Packages](#adding-packages)
  - [Creating New Modules](#creating-new-modules)
  - [Adding a New Machine](#adding-a-new-machine)
- [Available Modules](#available-modules)
  - [Python Development](#python-development)
  - [Rust Development](#rust-development)
  - [Go Development](#go-development)
  - [JavaScript/Node.js Development](#javascriptnode-development)
  - [Clojure Development](#clojure-development)
  - [Haskell Development](#haskell-development)
  - [Creative Coding](#creative-coding)
- [Troubleshooting](#troubleshooting)
- [References](#references)

## Overview

This configuration manages:

- Multiple Apple Silicon MacBooks (home and work)
- Future compatibility with NixOS for potential Linux machines
- Declarative management of both Nix packages and Homebrew casks/formulae
- Modular software environments that can be enabled/disabled as needed

## Directory Structure

```
nix/
├── darwin/              # Darwin-specific configurations
│   ├── default.nix      # Common darwin configuration
│   ├── home.nix         # Personal MacBook config
│   └── work.nix         # Work MacBook config
├── home-manager/        # Home Manager configurations
│   ├── default.nix      # Common HM config
│   ├── home.nix         # Personal HM-specific config
│   └── work.nix         # Work HM-specific config
├── modules/             # Optional software modules
│   ├── python.nix       # Python development environment
│   ├── rust.nix         # Rust development environment
│   ├── go.nix           # Go development environment
│   ├── javascript.nix   # JavaScript/Node.js development
│   └── clojure.nix      # Clojure development environment
└── flake.nix            # Main entry point
```

## Using Profiles

This configuration supports multiple machine profiles, with two main ones pre-configured:

- **home**: Personal MacBook configuration
- **work/span**: Work MacBook configuration

You can select which profile to build using the rebuild script:

```bash
# For personal MacBook
rebuild.sh home

# For work MacBook
rebuild.sh work
```

The script will automatically translate these profile names to the actual hostnames configured in the flake.

## Managing Modules

This configuration uses a modular approach where development environments can be enabled or disabled as needed:

```bash
# Enable Python environment
rebuild.sh home "" python enable

# Disable Rust environment
rebuild.sh home "" rust disable

# Enable JavaScript environment on work machine
rebuild.sh work "" javascript enable
```

To update packages and rebuild:

```bash
# Update and rebuild
rebuild.sh home update
```

## Customization

### Adding Packages

#### Nix Packages

Edit the appropriate file based on where you want the package available:

- **All machines**: Edit `darwin/default.nix`
- **Personal MacBook**: Edit `darwin/home.nix`
- **Work MacBook**: Edit `darwin/work.nix`

Add packages to the `environment.systemPackages` section:

```nix
environment.systemPackages = with pkgs; [
  # Existing packages...
  ripgrep
  fd
  neovim
];
```

#### Homebrew Packages

For macOS apps or packages not available in Nixpkgs:

```nix
homebrew = {
  enable = true;

  # Homebrew apps/casks
  casks = [
    "visual-studio-code"
    "docker"
  ];

  # Homebrew formulae
  brews = [
    "mas"
    "openssl"
  ];
};
```

### Creating New Modules

1. Create a new file in the `modules/` directory (e.g., `modules/java.nix`)
2. Use this template:

```nix
{ config, pkgs, lib, ... }:

let
  cfg = config.modules.java;
in {
  options.modules.java = {
    enable = lib.mkEnableOption "Java development environment";

    # Additional options
    withMaven = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to include Maven";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      jdk
      (lib.mkIf cfg.withMaven maven)
    ];

    # Additional configuration...
  };
}
```

3. Enable your new module:

```bash
rebuild.sh home "" java enable
```

### Adding a New Machine

1. Add a configuration to `flake.nix`:

```nix
darwinConfigurations."new-hostname" = darwin.lib.darwinSystem {
  system = "aarch64-darwin"; # or x86_64-darwin for Intel
  modules = [
    ./darwin/default.nix
    ./darwin/new-machine.nix
    # Add other modules...
  ];
};
```

2. Create a configuration for your machine in `darwin/new-machine.nix`:

```nix
{ config, pkgs, ... }:

{
  # Machine-specific config goes here
  networking.hostName = "new-hostname";

  # Machine-specific packages
  environment.systemPackages = with pkgs; [
    # Your packages...
  ];
}
```

3. Create a Home Manager config in `home-manager/new-machine.nix` if needed.

4. Rebuild with:

```bash
rebuild.sh new-hostname
```

## Available Modules

### Python Development

Enable with: `rebuild.sh home "" python enable`

Includes:

- Python interpreter
- pip
- venv
- Common development libraries

### Rust Development

Enable with: `rebuild.sh home "" rust enable`

Includes:

- Rustup
- Cargo
- rustc
- Development tools

### Go Development

Enable with: `rebuild.sh home "" go enable`

Includes:

- Go compiler
- Development tools
- Common Go utilities

### JavaScript/Node.js Development

Enable with: `rebuild.sh home "" javascript enable`

Includes:

- Node.js
- npm/yarn
- TypeScript
- Development tools

### Clojure Development

Enable with: `rebuild.sh home "" clojure enable`

Includes:

- Clojure
- Leiningen
- Development tools

### Haskell Development

Enable with: `rebuild.sh home "" haskell enable`

Includes:

- GHC (Glasgow Haskell Compiler)
- Cabal & Stack build tools
- Haskell Language Server (optional)
- HLint and formatting tools (optional)
- Additional development tools (optional)

Options can be configured in your profile's .nix file:

```nix
modules.haskell = {
  enable = true;
  withLSP = true;
  withLinter = true;
  withFormatter = true;
  withExtraTools = true;
  ghcVersion = "default";  # Options: "default", "9.2", "9.4", "9.6", "9.8"
};
```

### Creative Coding

Enable with: `rebuild.sh home "" creative enable`

A comprehensive environment for music programming and creative coding.

Includes by default:

- SuperCollider (via Homebrew)
- Max/MSP (via Homebrew)
- Core audio libraries (portmidi, portaudio, ffmpeg, sox)

Optional components:

- Csound (`withCsound = true`)
- ChucK (`withChucK = true`)
- Faust (`withFaust = true`)
- FoxDot (`withFoxDot = true`)
- Orca (`withOrca = true`)
- Processing (`withProcessing = true`)
- Sonic Pi (`withSonicPi = true`)
- PlugData (`withPlugData = true`)

Configure in your profile's .nix file:

```nix
modules.creative = {
  enable = true;
  withCsound = true;
  withChucK = true;
  withFaust = true;
  withFoxDot = false;
  withOrca = false;
  withProcessing = false;
  withSonicPi = false;
  withPlugData = false;
};
```

**Dependencies and Prerequisites:**

- The **Haskell module** is recommended if you want to use TidalCycles.
- The **Clojure module** is recommended for Overtone (audio synthesis) and Quil (Clojure interface for Processing).

**Installing TidalCycles:**

TidalCycles is managed via Cabal (Haskell's package manager) rather than Nix. After enabling the Haskell module:

```bash
# Install TidalCycles
cabal update
cabal install tidal

# SuperCollider is already installed by the creative module
```

For more information, visit [TidalCycles' official documentation](https://tidalcycles.org/docs/getting-started/installation/).

**Using Overtone with Clojure:**

Overtone is a Clojure library and should be added as a dependency in your Clojure project:

```clojure
;; In your project.clj
:dependencies [[overtone "0.10.6"]]
```

or with deps.edn:

```clojure
;; In your deps.edn
{:deps {overtone/overtone {:mvn/version "0.10.6"}}}
```

For more information, visit [Overtone's GitHub repository](https://github.com/overtone/overtone).

## Troubleshooting

### Common Issues

- **Homebrew permissions**: Ensure the user specified in `nix-homebrew.user` exists and has appropriate permissions.
- **Failed builds**: Check Nix syntax errors in your configuration files.
- **Module not found**: Verify the module path and ensure the file exists.

### Debugging Nix

Show detailed build information:

```bash
nix build --verbose ".#darwinConfigurations.$HOST.system"
```

Check Nix store paths:

```bash
nix-store -q --references ./result
```

## References

- [Determinate Nix Installer](https://github.com/DeterminateSystems/nix-installer)
- [nix-darwin Manual](https://github.com/LnL7/nix-darwin)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nixpkgs Manual](https://nixos.org/manual/nixpkgs/stable/)
- [nix-homebrew](https://github.com/zhaofengli-wip/nix-homebrew)
