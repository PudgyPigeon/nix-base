{
  description = "Flake for NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    home-manager.url = "github:nix-community/home-manager";
    helix.url = "github:helix-editor/helix/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    stateVersion = "25.11";
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};

    systemMap = import ./hosts/system-map.nix;

    mkHost = username: kind:
      (systemMap {
        inherit inputs system username stateVersion;
      }).${
        kind
      };
  in {
    formatter.${system} = pkgs.alejandra;

    nixosConfigurations = {
      wsl = mkHost "nixos" "wsl";
    };
  };
}
