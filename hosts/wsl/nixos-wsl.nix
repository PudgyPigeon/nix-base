{ inputs, system, username, stateVersion }:

let
  # Import modules from inputs
  wslModule = inputs.nixos-wsl.nixosModules.default;
  homeManagerModule = inputs.home-manager.nixosModules.home-manager;

  # Local module paths
  nixSettingsModule = ../../modules/nix-settings.nix;
  wslHomeManagerConfigModule = ../../home/nixos-wsl.nix;
  wslSystemConfigurationModule = ./system-configuration.nix;

  # Inline WSL-specific settings
  wslSettingsModule = {
    system.stateVersion = stateVersion;
    wsl.enable = true;
  };

in
  inputs.nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs username stateVersion; };
    modules = [
      wslModule 
      wslSettingsModule
      nixSettingsModule
      homeManagerModule
      wslHomeManagerConfigModule
      wslSystemConfigurationModule
    ];
  }
