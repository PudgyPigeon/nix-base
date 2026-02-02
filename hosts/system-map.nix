{ inputs, system, username, stateVersion }:
{
  wsl = import ./wsl/nixos-wsl.nix { inherit inputs system username stateVersion; };
}