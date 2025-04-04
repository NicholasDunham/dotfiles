{ config, pkgs, lib, ... }:

{
  # Work-specific Home Manager configuration
  
  # Work-specific Git configuration
  programs.git.extraConfig = {
  };
  
  # Work-specific terminal customizations
  programs.zsh = {
    # Add work-specific shell customization
    shellAliases = {
      # Work-specific aliases
      span = "cd ~/repos/span";
      apple = "cd ~/repos/apple";
    };
    
    initExtra = ''
      # Work-specific shell configuration
    '';
  };
} 