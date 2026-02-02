{
  description = "Flake for NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    home-manager.url = "github:nix-community/home-manager";
    helix.url = "github:helix-editor/helix/master";

    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      # Static values used across the flake
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      systemMap = import ./hosts/system-map.nix;

      helixPkg = inputs.helix.packages.${system}.default;

      wslModule = inputs.nixos-wsl.nixosModules.default;

      # Takes the username and the 'kind' of system (e.g., wsl)
      mkHost = username: kind: (systemMap { inherit inputs system username; }).${kind};
    in {  
      formatter.${system} = pkgs.nixpkgs-fmt;

      nixosConfigurations = {
        wsl = mkHost "nixos" "wsl";
      };
    };
}