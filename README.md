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


# Nvidia
```
# For CDI issues
sudo nvidia-ctk runtime configure --runtime=docker --set-as-default
sudo systemctl restart docker
sudo sed -i '/accept-nvidia-visible-devices-as-volume-mounts/c\accept-nvidia-visible-devices-as-volume-mounts = true' /etc/nvidia-container-runtime/config.toml


sudo nvidia-ctk cdi generate --mode=wsl --output=/etc/cdi/nvidia.yaml

sudo systemctl restart docker

export XDG_RUNTIME_DIR=/run/user/$(id -u)
systemctl --user restart docker
```



# DNS
In case DNS dies while changing settings:
```
sudo sh -c "echo 'nameserver 8.8.8.8' > /etc/resolv.conf"
```