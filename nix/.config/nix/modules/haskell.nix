{ config, pkgs, lib, ... }:

let
  cfg = config.modules.haskell;
in {
  options.modules.haskell = {
    enable = lib.mkEnableOption "Haskell development environment";
    
    withLSP = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to include Haskell Language Server";
    };

    withLinter = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to include HLint and other linting tools";
    };

    withFormatter = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to include formatters like Ormolu or Fourmolu";
    };

    withExtraTools = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to include additional Haskell development tools";
    };

    ghcVersion = lib.mkOption {
      type = lib.types.enum [ "default" "9.2" "9.4" "9.6" "9.8" ];
      default = "default";
      description = "GHC version to use";
    };
  };

  config = lib.mkIf cfg.enable {
    # Nix packages
    environment.systemPackages = with pkgs;
      let
        # Select GHC version based on configuration
        haskellPackages' = if cfg.ghcVersion == "9.2" then haskell.packages.ghc92
                          else if cfg.ghcVersion == "9.4" then haskell.packages.ghc94
                          else if cfg.ghcVersion == "9.6" then haskell.packages.ghc96
                          else if cfg.ghcVersion == "9.8" then haskell.packages.ghc98
                          else haskellPackages; # default
      in [
        # Core Haskell tools
        haskellPackages'.ghc
        cabal-install
        stack
      ] 
      ++ lib.optionals cfg.withLSP [
        haskell-language-server
      ]
      ++ lib.optionals cfg.withLinter [
        haskellPackages'.hlint
      ]
      ++ lib.optionals cfg.withFormatter [
        haskellPackages'.ormolu
      ]
      ++ lib.optionals cfg.withExtraTools [
        haskellPackages'.hoogle
        cabal2nix
        haskell-debug-adapter
        haskellPackages'.ghcid
        haskellPackages'.implicit-hie  # Auto-generate hie.yaml files
      ];
  };
} 