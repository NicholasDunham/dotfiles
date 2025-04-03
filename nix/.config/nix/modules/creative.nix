{ config, pkgs, lib, ... }:

let
  cfg = config.modules.creative;
in {
  options.modules.creative = {
    enable = lib.mkEnableOption "Creative coding and music programming environment";
    
    withCsound = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to include Csound (from Nix)";
    };

    withChucK = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to include ChucK";
    };

    withFaust = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to include Faust";
    };

    withFoxDot = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to include FoxDot";
    };

    withOrca = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to include Orca";
    };

    withProcessing = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to include Processing";
    };

    withSonicPi = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to include Sonic Pi";
    };
    
    withPlugData = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to include PlugData (Pure Data fork)";
    };
  };

  config = lib.mkIf cfg.enable {
    # Nix packages
    environment.systemPackages = with pkgs; [
      # Always included
      portmidi
      portaudio
      ffmpeg
      sox
    ]
    ++ lib.optionals cfg.withChucK [
      chuck
    ]
    ++ lib.optionals cfg.withFaust [
      faust
    ]
    ++ lib.optionals cfg.withFoxDot [
      foxdot # Optional
    ]
    ++ lib.optionals cfg.withOrca [
      orca-c # Optional
    ]
    ++ lib.optionals cfg.withProcessing [
      # Processing is installed via Homebrew
      # Quil will be available through Clojure/Leiningen dependencies
    ];

    # Homebrew packages for macOS
    homebrew.casks = [
      "supercollider" # Supercollider for macOS
      "cycling74-max" # Max/MSP
    ]
    ++ lib.optionals cfg.withPlugData [
      "plugdata" # Pure Data alternative/fork (better for macOS)
    ]
    ++ lib.optionals cfg.withProcessing [
      "processing"
    ]
    ++ lib.optionals cfg.withSonicPi [
      "sonic-pi" # Sonic Pi for macOS
    ];

    # Homebrew formulae
    homebrew.brews = [
      # Any additional brew formulae can go here
    ]
    ++ lib.optionals cfg.withCsound [
      "csound" # Install Csound via Homebrew
    ];
  };
} 