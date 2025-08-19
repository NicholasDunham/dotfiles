{
  description = "Nicholas Dunham's Nix Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
      # Don't override inputs - let nix-homebrew use its own versions
    };

    # Homebrew taps
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-emacs-plus = {
      url = "github:d12frosted/homebrew-emacs-plus";
      flake = false;
    };
    homebrew-span-tap = {
      url = "github:SPANDigital/homebrew-tap";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, darwin, home-manager, nix-homebrew, homebrew-core, homebrew-cask, homebrew-emacs-plus, homebrew-span-tap, ... } @ inputs:
    let
      username = "nicholasdunham";
      
      # System types to support
      supportedSystems = [ "aarch64-darwin" "x86_64-linux" ];
      
      # Function to generate a set based on supported systems
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      
      # Nixpkgs instantiated for supported system types with overlays
      nixpkgsFor = forAllSystems (system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      });
    in
    {
      darwinConfigurations = {
        # Personal MacBook configuration
        "ndunham-home-air" = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = { inherit username; };
          modules = [
            ./darwin/default.nix
            ./darwin/home.nix
            nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                enable = true;
                user = "nicholasdunham";
                mutableTaps = false;
                autoMigrate = true;
                taps = {
                  "homebrew/homebrew-core" = homebrew-core;
                  "homebrew/homebrew-cask" = homebrew-cask;
                  "d12frosted/homebrew-emacs-plus" = homebrew-emacs-plus;
                  "SPANDigital/homebrew-tap" = homebrew-span-tap;
                };
              };
            }
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit username; };
                users.${username} = { 
                  imports = [
                    ./home-manager/default.nix
                    ./home-manager/home.nix
                  ];
                };
              };
            }
          ];
        };
        
        # Work MacBook configuration
        "ndunham-span-air" = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = { inherit username; };
          modules = [
            ./darwin/default.nix
            ./darwin/work.nix
            nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                enable = true;
                user = "nicholasdunham";
                mutableTaps = false;
                autoMigrate = true;
                taps = {
                  "homebrew/homebrew-core" = homebrew-core;
                  "homebrew/homebrew-cask" = homebrew-cask;
                  "d12frosted/homebrew-emacs-plus" = homebrew-emacs-plus;
                  "SPANDigital/homebrew-tap" = homebrew-span-tap;
                };
              };
            }
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit username; };
                users.${username} = { 
                  imports = [
                    ./home-manager/default.nix
                    ./home-manager/work.nix
                  ];
                };
              };
            }
          ];
        };
      };

      # Add NixOS configuration template for future use
      nixosConfigurations = {
        # Template configuration - can be expanded later
        "nixos-template" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit username; };
          modules = [
            # Basic modules will go here
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit username; };
                users.${username} = {
                  imports = [ ./home-manager/default.nix ];
                };
              };
            }
          ];
        };
      };
    };
}
