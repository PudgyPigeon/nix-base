{ inputs, system, username }:
{
  wsl = import ./wsl/nixos-wsl.nix { inherit inputs system username; };
}