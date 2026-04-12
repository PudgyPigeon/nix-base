{
  config,
  lib,
  pkgs,
  inputs,
  username,
  stateVersion,
  ...
}: let
  nixLdLibs = with pkgs; [
    stdenv.cc.cc.lib
    mesa
    libglvnd
    vulkan-loader
    libX11
  ];
in {
  nixpkgs.config.allowUnfree = true;

  ########################################
  # --- Security & Networking ---
  ########################################
  security.apparmor.enable = true; # Dis?abled to ensure no profile conflicts with GPU mounts
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
    extraGroups = ["docker" "wheel" "video" "render"];
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
      cdi-spec-dirs = ["/etc/cdi"];
      runtimes = {
        nvidia = {
          path = "${pkgs.nvidia-container-toolkit}/bin/nvidia-container-runtime";
        };
      };
    };
  };

  ########################################
  # --- CDI Automation Service ---
  ########################################
  systemd.user.services.nvidia-cdi-generator = {
    description = "Generate NVIDIA CDI specification";
    enable = true;
    serviceConfig = {
      Type = "oneshot";
    };
    # Using the absolute path to the tool ensures it works regardless of PATH
    script = ''
      # 1. Replicate: sudo mkdir -p /etc/cdi
      # Note: You may need to 'sudo chown' this dir once if the user service lacks permissions
      mkdir -p /etc/cdi

      # 2. Replicate: sudo rm -rf /var/run/cdi/*
      rm -rf /var/run/cdi/*

      # 3. Replicate your manual command
      ${pkgs.nvidia-container-toolkit.tools}/bin/nvidia-ctk cdi generate \
        --output /etc/cdi/nvidia.yaml \
        --nvidia-cdi-hook-path ${pkgs.nvidia-container-toolkit.tools}/bin/nvidia-cdi-hook
    '';
    # Match the 'wantedBy' to the session target to ensure it runs when you log in
    wantedBy = ["default.target"];
  };
  ########################################
  # --- Hardware & Graphics ---
  ########################################
  hardware = {
    nvidia = {
      open = true; # Proprietary is safer for the WSL2/Windows bridge
      modesetting.enable = true;
    };

    nvidia-container-toolkit = {
      enable = true;
      disable-hooks = [];
      mount-nvidia-executables = true; # Prevents 'device or resource busy' in WSL2
    };

    graphics = {
      enable = true;
      extraPackages = with pkgs; [vulkan-loader libglvnd];
    };
  };

  ########################################
  # --- Services & Environment ---
  ########################################
  services = {
    xserver = {
      enable = true;
      videoDrivers = ["nvidia"];
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
  };

  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld;
    libraries = nixLdLibs;
  };

  environment = {
    variables = {
      LD_LIBRARY_PATH = "/usr/lib/wsl/lib\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}";
      NIX_LD_LIBRARY_PATH = "/run/current-system/sw/share/nix-ld/lib";
    };
    sessionVariables = {
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
      mesa-demos
      xhost
      nvidia-container-toolkit
      dos2unix # Essential for fixing CRLF issues in the future
    ];
  };
}
