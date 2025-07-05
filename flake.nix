{
  description = "A simple NixOS flake with Golang and WSL support";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    helix.url = "github:helix-editor/helix/master";
  };

  outputs = inputs:
    let
      # Set system and other packages
      system = "x86_64-linux";
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      wslModule = inputs.nixos-wsl.nixosModules.default;
      helixPkg = inputs.helix.packages.${system}.default;

      # Import host configuration as named variable
      hostConfigs = import ./hosts/system-map.nix { inherit inputs system; };
      formatterPkg = pkgs.nixpkgs-fmt;

    in {
      formatter.${system} = formatterPkg;
      nixosConfigurations.wsl = hostConfigs.wsl;
    };
}