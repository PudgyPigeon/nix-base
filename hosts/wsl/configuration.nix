{ config, lib, pkgs, nixpkgs, nixos-wsl, inputs, ... }:

let
  isWSL = builtins.pathExists "/proc/sys/fs/binfmt_misc/WSLInterop";
  helixPkg = inputs.helix.packages."${pkgs.system}".helix;
in {
  system.stateVersion = "24.11";

  # Conditional WSL config
  imports = lib.optional isWSL nixos-wsl;
  wsl = {
    enable = lib.mkIf isWSL true;
    defaultUser = lib.mkIf isWSL "nixos";
  };
  boot.isContainer = lib.mkIf isWSL true;

  # Flakes support
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Docker setup
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  users.users.nixos.extraGroups = [ "docker" ];

  # Default editor
  environment.variables.EDITOR = "neovim";

  # VS Code compatibility for WSL
  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld-rs;
  };
}