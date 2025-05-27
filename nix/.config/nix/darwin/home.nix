{ pkgs, lib, ... }:

{
  # Import home-specific modules
  imports = [
    # Add modules here that should be enabled for home machine only
    # ../modules/haskell.nix
    ../modules/creative.nix
  ];

  # Configure modules
  modules = {
    # Enable home-specific modules
    # haskell = {
    #   enable = true;
    #   withLSP = true;
    #   withLinter = true;
    #   withFormatter = true;
    #   withExtraTools = false;
    #   ghcVersion = "default";
    # };
    
    creative = {
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
  };

  # Home-specific homebrew configuration
  homebrew = {
    # Home-specific casks
    casks = [
      "spotify"
      "idagio"
      "vlc"
      "plex"
      "handbrake"
      "whatsapp"
    ];

    # Home-specific brews (if any)
    brews = [
      # Add home-specific brew packages here
    ];

    # Home-specific App Store apps
    masApps = {
      # "App Name" = app-id;
    };
  };

  # Home-specific packages
  environment.systemPackages = with pkgs; [
    # Entertainment
  ];

  # Any other home-specific darwin settings
  system.defaults = {
    # Add any home-specific macOS defaults here
    NSGlobalDomain = {
      # Example: different key repeat settings for home use
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
    };
  };
}
