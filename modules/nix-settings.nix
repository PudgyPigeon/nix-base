{ pkgs, lib, config, ... }:

{
  nix = {
    settings = {
      # Flakes stuff
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      
      allowed-users = [ "*" ];
      cores = 0;
      max-jobs = "auto";
      require-sigs = true;
      sandbox-fallback = false;
      substituters = [ "https://cache.nixos.org/" ];
      system-features = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
      trusted-users = [ "root" ];
    };

    # Garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };
}