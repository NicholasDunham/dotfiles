{ pkgs, lib, ... }:

{
  # Import work-specific modules
  imports = [
    # Add modules here that should be enabled for work machine only
  ];

  # Configure modules

  # Work-specific homebrew configuration
  homebrew = {
    # Work-specific casks
    casks = [
    ];

    # Work-specific brews
    brews = [
      "presidium"
    ];

    # Work-specific App Store apps
    masApps = {
      # "App Name" = app-id;
    };
  };

  # Work-specific packages
  environment.systemPackages = with pkgs; [
    # Documentation tools
    pandoc
    hugo
  ];

  # Any other work-specific darwin settings
  system.defaults = {
    # Add any work-specific macOS defaults here
    NSGlobalDomain = {
      # Example: different key repeat settings for work
      InitialKeyRepeat = 25; 
      KeyRepeat = 4;
    };
  };
} 