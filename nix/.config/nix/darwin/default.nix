{ pkgs, lib, username, ... }:

{
  # Import modules
  imports = [
    # Add modules here that should be enabled for all machines
    # Example: ../modules/python.nix
    ../modules/clojure.nix
    ../modules/go.nix
    ../modules/javascript.nix
    ../modules/python.nix
    ../modules/rust.nix
  ];

  # Configure modules
  modules = {
    # Enable Go module with all options
    go = {
      enable = true;
      withLSP = true;
      withLinter = true;
      withDebugger = true;
      withExtraTools = true;
      goVersion = "stable";
    };

    # Enable Clojure module with all options
    clojure = {
      enable = true;
      withLSP = true;
      withFormattingTools = true;
      withExtraTools = true;
      # Using default JDK version (17)
    };

    # Enable JavaScript module with all options
    javascript = {
      enable = true;
      withTypeScript = true;
      withLSP = true;
      withLinters = true;
      withTools = true;
      nodeVersion = "lts";  # Using LTS version
    };
    
    # Enable Python module with all options
    python = {
      enable = true;
      withLSP = true;
      withJupyter = false;
      extraPackages = with pkgs.python3Packages; [
        pyyaml
      ];
    };

    # Enable Rust module with all options
    rust = {
      enable = true;
      withLSP = true;
      withExtras = true;
    };
  };

  # Enable Homebrew using nix-darwin's built-in module
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "uninstall"; # Less aggressive than "zap"
      upgrade = true;
    };
    
    # Homebrew packages (formulae)
    brews = [
      "emacs-plus@30" # Emacs Plus version 30
    ];

    # Mac App Store apps
    masApps = {
      # Add Mac App Store apps here
      # "App Name" = app-id;
    };

    # Common Homebrew casks for both machines
    casks = [
      # Browsers
      "firefox"
      "google-chrome"

      # Media editing
      "gimp"
      "audacity"

      # IDEs
      "cursor"
      "visual-studio-code"

      # Other dev tools
      "podman"
      "podman-compose"
      "podman-desktop"

      # Communication
      "slack"
      "zoom"

      # System utilities
      "1password"
      "bartender"
      "iterm2"
      "mac-mouse-fix"
      "raycast"
    ];
  };

  # Shared fonts
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    fira-sans
  ];

  # Common packages for all systems
  environment.systemPackages = with pkgs; [
    # Development tools
    bat
    difftastic
    fd
    fzf
    gh
    git
    gnumake
    ripgrep

    # Nix tools
    nil 
    nixfmt-rfc-style

    # Shells and terminal utilities
    bash
    bash-language-server
    btop
    htop
    stow
    tmux
    shellcheck
    shfmt
    tldr
    zsh
    
    # Text editors
    neovim
    zstd # Seems to be required for Emacs
    
    # Network tools
    curl
    wget
    
    # System tools
    coreutils
    findutils
    fontconfig
    gawk
    gnused

    # Other utilities
    tree
    unzip
  ];

  # Basic darwin configuration
  system = {
    # System defaults
    defaults = {
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        AppleKeyboardUIMode = 3;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
      };
      
      dock = {
        autohide = true;
        show-recents = false;
        mru-spaces = false;
      };
      
      finder = {
        AppleShowAllExtensions = true;
        QuitMenuItem = true;
        FXEnableExtensionChangeWarning = false;
      };
    };
    
    # Custom activation script to set up Emacs
    activationScripts.postActivation.text = ''
      # Finish Emacs Plus post-install
      echo "Running post-install script for emacs-plus@30"
      if [ -d "/opt/homebrew/opt/emacs-plus@30" ]; then
        # First ensure the post-install is completed
        sudo -u ${username} /opt/homebrew/bin/brew postinstall d12frosted/emacs-plus/emacs-plus@30 || true
        
        # Create Applications alias
        echo "Creating alias in Applications for Emacs.app"
        sudo -u ${username} osascript -e 'tell application "Finder" to make alias file to posix file "/opt/homebrew/opt/emacs-plus@30/Emacs.app" at posix file "/Applications" with properties {name:"Emacs.app"}' || true
        
        # Create bin directory if it doesn't exist
        mkdir -p "/Users/${username}/bin"
        chown ${username}:staff "/Users/${username}/bin"
        
        # Create a symlink to emacs in the user's bin directory, which should be in PATH
        echo "Linking emacs-plus binary to ~/bin/emacs"
        sudo -u ${username} ln -sf /opt/homebrew/opt/emacs-plus@30/bin/emacs "/Users/${username}/bin/emacs"
        sudo -u ${username} ln -sf /opt/homebrew/opt/emacs-plus@30/bin/emacsclient "/Users/${username}/bin/emacsclient"
        
        # Start the Emacs daemon service
        echo "Starting Emacs daemon service"
        sudo -u ${username} /opt/homebrew/bin/brew services start d12frosted/emacs-plus/emacs-plus@30 || true
        
        # Create an alias for quickly connecting to the daemon
        echo "Creating alias for emacsclient"
        cat > "/Users/${username}/bin/ec" <<EOF
#!/bin/bash
/opt/homebrew/opt/emacs-plus@30/bin/emacsclient -c -a "" "\$@"
EOF
        chmod +x "/Users/${username}/bin/ec"
        chown ${username}:staff "/Users/${username}/bin/ec"
      else
        echo "Emacs Plus not found at /opt/homebrew/opt/emacs-plus@30"
      fi
    '';
    
    # Auto-upgrade nix package and the daemon service
    stateVersion = 6;
  };

  # Nix configuration
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
    };
    optimise = {
      automatic = true;
    };
    gc = {
      automatic = true;
      interval = { Day = 7; };
      options = "--delete-older-than 30d";
    };
  };

  # Default user shell
  programs.zsh.enable = true;
  users.users.nicholasdunham = {
    name = "nicholasdunham";
    home = "/Users/nicholasdunham";
    shell = pkgs.zsh;
  };
}
