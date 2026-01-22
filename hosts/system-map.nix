{ inputs, system }:
{
  wsl = import ./wsl/nixos-wsl.nix { inherit inputs system; };
}