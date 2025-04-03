{ config, pkgs, lib, ... }:

let
  cfg = config.modules.python;
in {
  options.modules.python = {
    enable = lib.mkEnableOption "Python development environment";
    
    withLSP = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to include Python language server";
    };

    withJupyter = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to include Jupyter notebooks";
    };

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Additional Python packages to install";
    };
  };

  config = lib.mkIf cfg.enable {
    # Nix packages
    environment.systemPackages = with pkgs; [
      python3
      python3Packages.pip
      black
      python3Packages.flake8
      python3Packages.pytest
      poetry
    ] 
    ++ lib.optionals cfg.withLSP [
      python3Packages.python-lsp-server
      python3Packages.python-lsp-black
      python3Packages.pyls-isort
    ]
    ++ lib.optionals cfg.withJupyter [
      python3Packages.jupyter
      python3Packages.notebook
    ]
    ++ cfg.extraPackages;
  };
} 