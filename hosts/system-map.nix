{ inputs, system }:
{
  wsl = import ./wsl/nixos-wsl.nix { inherit inputs system; };
  # laptop = import ./laptop/laptop.nix { inherit inputs system; };
  # server = import ./server/server.nix { inherit inputs system; };
}