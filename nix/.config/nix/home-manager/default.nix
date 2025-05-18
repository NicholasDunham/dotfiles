{ config, pkgs, lib, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should manage
  home.username = "nicholasdunham";
  home.homeDirectory = "/Users/nicholasdunham";
  
  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # Set XDG directories
  xdg = {
    enable = true;
    cacheHome = "${config.home.homeDirectory}/.cache";
    dataHome = "${config.home.homeDirectory}/.local/share";
    configHome = "${config.home.homeDirectory}/.config";
  };

  # Add to PATH
  home.sessionPath = [ "${config.home.homeDirectory}/bin" ];

  # Environment variables
  home.sessionVariables = {
    # JAVA_HOME is conditionally set to avoid circular dependencies with the system Clojure module
    JAVA_HOME = lib.mkIf (pkgs ? graalvm-ce) "${pkgs.graalvm-ce}";
  };

  # Homebrew integration
  programs.zsh.profileExtra = ''
    # Set up Homebrew (Apple Silicon)
    eval "$(/opt/homebrew/bin/brew shellenv)"
  '';

  home.shellAliases = {
    ls = "ls --color";
  };

  # Configure git
  # programs.git = {
  #   enable = false;
  #   userName = "Nicholas Dunham";
  #   userEmail = "nicholasdunham@example.com"; # Replace with your email
  #   extraConfig = {
  #     init.defaultBranch = "main";
  #     pull.rebase = false;
  #     push.autoSetupRemote = true;
  #   };
  # };

  # FZF configuration
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f --hidden --exclude .git";
    defaultOptions = [ "--height 40%" "--layout=reverse" "--border" ];
  };

  # Configure zsh with native Home Manager options
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    
    history = {
      size = 5000;
      save = 5000;
      path = "${config.home.homeDirectory}/.zsh_history";
      ignoreAllDups = true;
      ignoreDups = true;
      ignoreSpace = true;
      expireDuplicatesFirst = true;
      share = true;
    };
    
    # Default key bindings (emacs style)
    defaultKeymap = "emacs";
    
    # We'll install and manage these plugins manually to always get the latest versions
    initContent = lib.mkOrder 550 ''
      # Additional key bindings
      bindkey '^p' history-search-backward
      bindkey '^n' history-search-forward
      
      # Install powerlevel10k and fzf-tab manually if they don't exist
      PLUGINS_DIR="$HOME/.zsh-plugins"
      
      if [ ! -d "$PLUGINS_DIR" ]; then
        mkdir -p "$PLUGINS_DIR"
      fi
      
      # Clone plugins if they don't exist (but don't update on every shell start)
      if [ ! -d "$PLUGINS_DIR/powerlevel10k" ]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$PLUGINS_DIR/powerlevel10k"
      fi
      
      if [ ! -d "$PLUGINS_DIR/fzf-tab" ]; then
        git clone https://github.com/Aloxaf/fzf-tab.git "$PLUGINS_DIR/fzf-tab"
      fi
      
      # Source the plugins
      source "$PLUGINS_DIR/powerlevel10k/powerlevel10k.zsh-theme"
      source "$PLUGINS_DIR/fzf-tab/fzf-tab.plugin.zsh"
      
      # Load P10K configuration if it exists
      [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
      
      # Create a function to update plugins manually or on a schedule
      update_zsh_plugins() {
        echo "Updating zsh plugins..."
        if [ -d "$PLUGINS_DIR/powerlevel10k" ]; then
          (cd "$PLUGINS_DIR/powerlevel10k" && git pull)
        fi
        
        if [ -d "$PLUGINS_DIR/fzf-tab" ]; then
          (cd "$PLUGINS_DIR/fzf-tab" && git pull)
        fi
        echo "Done updating plugins."
      }

      # P10K instant prompt setup
      typeset -g POWERLEVEL9K_INSTANT_PROMPT=verbose
      if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi
    '';

    # ZSH completions configuration
    completionInit = ''
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
      zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
      zstyle ':completion:*' menu no
      zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
    '';
    
    shellAliases = {
      nix-clean = "nix-collect-garbage --delete-older-than 14d && nix-store --optimise";
    };
  };

  # Configure neovim
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
  };
  
  # Configure tmux
  programs.tmux = {
    enable = true;
    shortcut = "a";
    keyMode = "vi";
    clock24 = true;
    historyLimit = 10000;
    terminal = "screen-256color";
    
    extraConfig = ''
      # Enable mouse support
      set -g mouse on
      
      # Start window numbering at 1
      set -g base-index 1
      
      # Start pane numbering at 1
      setw -g pane-base-index 1
    '';
  };

  # This value determines the Home Manager release that your configuration is compatible with
  home.stateVersion = "23.11";
}
