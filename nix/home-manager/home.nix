{ config, pkgs, lib, ... }:

{
  # Home-specific Home Manager configuration
  
  # Personal-specific Git configuration
  programs.git.extraConfig = {
    # Add personal-specific git configuration if needed
  };
  
  # Personal terminal customizations
  programs.zsh = {
    # Add personal-specific shell customization
    shellAliases = {
      # Personal-specific aliases
    };
  };
} 