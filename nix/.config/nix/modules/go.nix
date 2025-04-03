{ config, pkgs, lib, ... }:

let
  cfg = config.modules.go;
in {
  options.modules.go = {
    enable = lib.mkEnableOption "Go development environment";
    
    withLSP = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to include gopls (Go language server)";
    };

    withLinter = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to include golangci-lint";
    };

    withDebugger = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to include delve (Go debugger)";
    };

    withExtraTools = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to include additional Go development tools";
    };

    goVersion = lib.mkOption {
      type = lib.types.enum [ "stable" "unstable" "1.20" "1.21" "1.22" ];
      default = "stable";
      description = "Go version to use (stable is the default in nixpkgs)";
    };
  };

  config = lib.mkIf cfg.enable {
    # Nix packages
    environment.systemPackages = with pkgs; [
      # Core Go package based on version
      (if cfg.goVersion == "unstable" then go_1_22
       else if cfg.goVersion == "1.20" then go_1_20
       else if cfg.goVersion == "1.21" then go_1_21
       else if cfg.goVersion == "1.22" then go_1_22
       else go) # defaults to stable
    ] 
    ++ lib.optionals cfg.withLSP [
      gopls # Official Go language server
    ]
    ++ lib.optionals cfg.withLinter [
      golangci-lint # Meta linter for Go
    ]
    ++ lib.optionals cfg.withDebugger [
      delve # Go debugger
    ]
    ++ lib.optionals cfg.withExtraTools [
      gotools      # Additional tools that come with Go
      gotests      # Generate table-driven tests
      mockgen      # Generate mocks for interfaces
      go-tools     # More tools like staticcheck
      gofumpt      # Stricter gofmt
    ];

    # Set up GOPATH in the environment
    environment.variables = {
      GOPATH = lib.mkDefault "$HOME/go";
    };
  };
} 