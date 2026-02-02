{ inputs, system, username }:

let
  # Import modules from inputs
  wslModule = inputs.nixos-wsl.nixosModules.default;
  homeManagerModule = inputs.home-manager.nixosModules.home-manager;

  # Local module paths
  nixSettingsModule = ../../modules/nix-settings.nix;
  wslHomeManagerConfigModule = ../../home/nixos-wsl.nix;
  wslSystemConfigurationModule = ./system-configuration.nix;

  # Inline WSL-specific settings
  wslSettingsModule = { pkgs, config, ... }: {
    system.stateVersion = "24.11";
    wsl.enable = true;
  };

in
  inputs.nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs username; };
    modules = [
      wslModule 
      wslSettingsModule
      nixSettingsModule
      homeManagerModule
      wslHomeManagerConfigModule
      wslSystemConfigurationModule
    ];
  }
