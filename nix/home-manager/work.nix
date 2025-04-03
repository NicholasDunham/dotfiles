{ config, pkgs, lib, ... }:

{
  # Work-specific Home Manager configuration
  
  # Work-specific Git configuration
  programs.git = {
    # Use work email for Git at work
    userEmail = "nicholas.dunham@work.com"; # Replace with your actual work email
    
    extraConfig = {
      # Work-specific signing key for commits if needed
      # user.signingKey = "your-gpg-key-id";
      # commit.gpgSign = true;
    };
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