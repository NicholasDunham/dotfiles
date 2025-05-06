{ config, pkgs, lib, ... }:

let
  cfg = config.modules.clojure;
in {
  options.modules.clojure = {
    enable = lib.mkEnableOption "Clojure development environment";
    
    withLSP = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to include Clojure LSP";
    };

    withFormattingTools = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to include formatting and linting tools";
    };

    withExtraTools = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to include extra Clojure tools (jet, neil, babashka)";
    };
  };

  config = lib.mkIf cfg.enable {
    # Nix packages
    environment.systemPackages = with pkgs; [
      # Core Clojure packages
      graalvm-ce
      clojure
      leiningen
    ] 
    ++ lib.optionals cfg.withFormattingTools [
      cljfmt
      clj-kondo
    ]
    ++ lib.optionals cfg.withLSP [
      clojure-lsp
    ]
    ++ lib.optionals cfg.withExtraTools [
      babashka
      jet
      neil
    ];

    # Set JAVA_HOME in system environment variables
    environment.variables = {
      JAVA_HOME = lib.mkDefault (
        "${pkgs.graalvm-ce}"
      );
    };
  };
} 