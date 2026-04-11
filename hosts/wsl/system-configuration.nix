{ config, lib, pkgs, inputs, username, stateVersion, ... }:

let
  nixLdLibs = with pkgs; [
    stdenv.cc.cc
    mesa
    libglvnd
    vulkan-loader
    xorg.libX11
  ];
in
{
  nixpkgs.config.allowUnfree = true;

  ########################################
  # --- Security & Networking ---
  ########################################
  security.apparmor.enable = false; # Disabled to ensure no profile conflicts with GPU mounts
  networking.resolvconf.enable = false;
  environment.etc."resolv.conf".source = lib.mkForce "/mnt/wsl/resolv.conf";

  ########################################
  # --- WSL Integration ---
  ########################################
  wsl = {
    defaultUser = username;
    useWindowsDriver = true;
    interop.register = true;
  };

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "docker" "wheel" "video" "render" ];
  };

  ########################################
  # --- Docker (System Daemon) ---
  ########################################
  virtualisation.docker = {
    package = pkgs.docker_25;
    enable = true;
    rootless.enable = false;
    daemon.settings = {
      features.cdi = true;
      cdi-spec-dirs = [ "/etc/cdi" "/var/run/cdi" ];
    };
  };

  systemd.tmpfiles.rules = [ "d /etc/cdi 0755 root root -" ];

  ########################################
  # --- CDI Automation Service ---
  ########################################
  systemd.services.nvidia-cdi-generator = {
    serviceConfig = {
      Type = "oneshot";
      # Systemd runs as root
      ExecStart = "${pkgs.writeShellScript "gen-cdi" ''
        rm -rf /etc/cdi/*
        ${pkgs.nvidia-container-toolkit}/bin/nvidia-ctk cdi generate --output /etc/cdi/nvidia.yaml
      ''}";
    };
  };
  ########################################
  # --- Hardware & Graphics ---
  ########################################
  hardware = {
    nvidia = {
      open = false; # Proprietary is safer for the WSL2/Windows bridge
      modesetting.enable = true;
    };

    nvidia-container-toolkit = {
      enable = true;
      mount-nvidia-executables = false; # Prevents 'device or resource busy' in WSL2
    };

    graphics = {
      enable = true;
      extraPackages = with pkgs; [ vulkan-loader libglvnd ];
    };
  };

  ########################################
  # --- Services & Environment ---
  ########################################
  services = {
    xserver = {
      enable = true;
      videoDrivers = [ "nvidia" ];
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
  };

  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld-rs;
    libraries = nixLdLibs;
  };

  environment = {
    sessionVariables = {
      LD_LIBRARY_PATH = "/usr/lib/wsl/lib\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}";
      GALLIUM_DRIVER = "d3d12";
      WAYLAND_DISPLAY = "wayland-0";
      XDG_RUNTIME_DIR = "/mnt/wslg/runtime-dir";
      MESA_D3D12_DEFAULT_ADAPTER_NAME = "NVIDIA";
    };

    systemPackages = with pkgs; [
      tmux
      wget
      vim
      vulkan-tools
      glxinfo
      xorg.xhost
      nvidia-container-toolkit
      dos2unix # Essential for fixing CRLF issues in the future
    ];
  };
}
