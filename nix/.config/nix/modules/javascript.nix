{ config, pkgs, lib, ... }:

let
  cfg = config.modules.javascript;
in {
  options.modules.javascript = {
    enable = lib.mkEnableOption "JavaScript development environment";
    
    withTypeScript = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to include TypeScript support";
    };

    withLSP = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to include Language Server";
    };

    withLinters = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to include linting tools";
    };

    withTools = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to include additional JavaScript development tools";
    };

    nodeVersion = lib.mkOption {
      type = lib.types.enum [ "default" "lts" "current" "18" "20" "21" ];
      default = "lts";
      description = "Node.js version to use";
    };
  };

  config = lib.mkIf cfg.enable {
    # Nix packages
    environment.systemPackages = with pkgs;
      let
        # Select Node.js version based on configuration
        nodejs' = if cfg.nodeVersion == "lts" then nodejs_20
                 else if cfg.nodeVersion == "current" then nodejs
                 else if cfg.nodeVersion == "18" then nodejs_18 
                 else if cfg.nodeVersion == "20" then nodejs_20
                 else if cfg.nodeVersion == "21" then nodejs_21
                 else nodejs-slim; # default
      in [
        # Core JavaScript tools
        nodejs'
        yarn
        nodePackages.pnpm
      ] 
      ++ lib.optionals cfg.withTypeScript [
        nodePackages.typescript
        nodePackages.ts-node
        nodePackages.typescript-language-server
      ]
      ++ lib.optionals cfg.withLSP [
        nodePackages.vscode-langservers-extracted # HTML/CSS/JSON/ESLint language servers
        nodePackages.vscode-json-languageserver
        nodePackages.typescript-language-server
      ]
      ++ lib.optionals cfg.withLinters [
        nodePackages.eslint
        nodePackages.prettier
      ]
      ++ lib.optionals cfg.withTools [
        nodePackages.npm-check-updates
        nodePackages.node-gyp
        nodePackages.serve
        nodePackages.http-server
        nodePackages.json
        nodePackages.nodemon
      ];
  };
} 