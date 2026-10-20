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

  system.stateVersion = stateVersion;
  nixpkgs.config.allowUnfree = true;

  ################################
  # --- Security & Networking ---
  ################################
  security.apparmor.enable = false;
  networking.resolvconf.enable = true;
  networking.nameservers = ["8.8.8.8" "1.1.1.1"];
  environment.etc."resolv.conf".source = lib.mkForce "/mnt/wsl/resolv.conf";

  ################################
  # --- WSL Integration ---
  ################################
  wsl = {
    enable = true;
    defaultUser = username;
    useWindowsDriver = true;
    interop.register = true;
  };

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = ["docker" "wheel" "video" "render" "audio"];
  };

  ################################
  # --- Docker (System Daemon) ---
  ################################
  virtualisation.docker = {
    package = pkgs.docker_25;
    enable = true;
    rootless.enable = false;
    daemon.settings = {
      features = {
        cdi = true;
      };
      cdi-spec-dirs = [
        "/etc/cdi"
      ];
      runtimes = {
        nvidia = {
          path = "${pkgs.nvidia-container-toolkit}/bin/nvidia-container-runtime";
        };
      };
    };
  };

  ################################
  # --- Programs & Environment ---
  ################################
  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld;
    libraries = nixLdLibs;
  };

  environment = {
    etc."ld.so.conf.d/wsl.conf".text = ''
      /usr/lib/wsl/lib
    '';

    sessionVariables = {
      LD_LIBRARY_PATH = "/usr/lib/wsl/lib";
      GALLIUM_DRIVER = "d3d12";
      WAYLAND_DISPLAY = "wayland-0";
      XDG_RUNTIME_DIR = "/mnt/wslg/runtime-dir";
      MESA_D3D12_DEFAULT_ADAPTER_NAME = "NVIDIA";
    };

    systemPackages = with pkgs; [
      tmux
      wget
      vim
      xhost
      dos2unix
      # Resource monitoring below
      htop
      glances
    ];
  };
}