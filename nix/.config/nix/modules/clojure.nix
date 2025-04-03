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

    jdkVersion = lib.mkOption {
      type = lib.types.enum [ 8 11 17 21 ];
      default = 17;
      description = "JDK version to use";
    };
  };

  config = lib.mkIf cfg.enable {
    # Nix packages
    environment.systemPackages = with pkgs; [
      # Core Clojure packages
      (
        if cfg.jdkVersion == 8 then jdk8
        else if cfg.jdkVersion == 11 then jdk11
        else if cfg.jdkVersion == 21 then jdk21
        else jdk17
      )
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
    environment.variables = lib.mkIf (cfg.jdkVersion != null) {
      JAVA_HOME = lib.mkDefault (
        if cfg.jdkVersion == 8 then "${pkgs.jdk8}/lib/openjdk"
        else if cfg.jdkVersion == 11 then "${pkgs.jdk11}/lib/openjdk"
        else if cfg.jdkVersion == 21 then "${pkgs.jdk21}/lib/openjdk"
        else "${pkgs.jdk17}/lib/openjdk"
      );
    };
  };
} 