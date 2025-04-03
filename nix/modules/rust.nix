{ config, pkgs, lib, ... }:

let
  cfg = config.modules.rust;
in {
  options.modules.rust = {
    enable = lib.mkEnableOption "Rust development environment";
    
    withLSP = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to include Rust Analyzer";
    };

    withExtras = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to include extra Rust tools";
    };
  };

  config = lib.mkIf cfg.enable {
    # Nix packages
    environment.systemPackages = with pkgs; [
      rustup
      cargo
      rustc
    ] 
    ++ lib.optionals cfg.withLSP [
      rust-analyzer
    ]
    ++ lib.optionals cfg.withExtras [
      cargo-edit
      cargo-watch
      cargo-audit
      cargo-outdated
      cargo-release
    ];

    # No Homebrew packages for Rust as the Nix ones are usually better
  };
} 