{
  description = "A simple NixOS flake with Golang and WSL support";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs:
    let
      # Set system and other packages
      system = "x86_64-linux";
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      wslModule = inputs.nixos-wsl.nixosModules.default;

      # Import host configuration as named variable
      hostConfigs = import ./hosts/system-map.nix { inherit inputs system; };
      formatterPkg = pkgs.nixpkgs-fmt;

    in {
      formatter.${system} = formatterPkg;
      nixosConfigurations.wsl = hostConfigs.wsl;
    };
}