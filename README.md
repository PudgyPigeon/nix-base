# NixOS Setup

You can ensure your NixOS system has git with the following:
```
nix shell nixpkgs#git
```

Run the `rebuild_nix.sh` script

Purpose is to get rid of the reliance on `/etc/nix/nix.conf`. Track everything in this Git repo

Or you can manually run like this following example:
```
sudo nixos-rebuild switch --flake .#wsl
```