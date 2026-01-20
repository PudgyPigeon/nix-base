{ inputs, system }:

let
  pkgs = inputs.nixpkgs.legacyPackages.${system};
  helixPkg = inputs.helix.packages.${system}.default;

  # Custom packages to install
  commonPackages = with pkgs; [
    git
    vim
    neovim
    wget
    go
    gotools
    golangci-lint
    helixPkg
  ];

  # GPU + audio packages for WSL2 graphics/audio support
  gpuAndAudioPackages = with pkgs; [
    mesa
    vulkan-loader
    vulkan-tools
    libGL
    pulseaudio
    pipewire
  ];


  # Import modules as named variables
  configurationModule = ./configuration.nix;
  nixSettingsModule = ../../modules/nix-settings.nix;
  wslModule = inputs.nixos-wsl.nixosModules.default;
  homeManagerModule = inputs.home-manager.nixosModules.home-manager;
  wslHomeManagerConfigModule = import ../../home/nixos-wsl.nix { username = "nixos"; };

  # Inline WSL-specific settings
  wslSettingsModule = { pkgs, config, ... }: {
    system.stateVersion = "24.11";
    wsl.enable = true;
    environment.systemPackages = commonPackages ++ gpuAndAudioPackages;
  };

  
  nixosSystemInstance = inputs.nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs; };

    modules = [
      configurationModule
      nixSettingsModule
      wslModule
      wslSettingsModule
      homeManagerModule
      wslHomeManagerConfigModule
    ];
  };

in
  nixosSystemInstance
