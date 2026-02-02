{ config, lib, pkgs, inputs, username, ... }:

let
  isWSL = builtins.pathExists "/proc/sys/fs/binfmt_misc/WSLInterop";
  
  nixLdLibs = with pkgs; [
    stdenv.cc.cc
    mesa
    libglvnd
    vulkan-loader 
    xorg.libX11
  ];

in {
  system.stateVersion = "24.11";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  ########################################
  # --- WSL integration ---
  ########################################
  wsl = lib.mkIf isWSL {
    enable = true;
    defaultUser = username;
    useWindowsDriver = true;
    interop.register = true;
  };

  # Group permissions at system level
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "docker" "wheel" "video"];
  };

  ########################################
  # --- Docker (System Daemon) ---
  ########################################
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
    # Critical for NVIDIA/Mesa setup
    daemon.settings.runtimes.nvidia.path =
      "${pkgs.nvidia-docker}/bin/nvidia-container-runtime";
  };

  ########################################
  # --- Graphics / Pipewire ---
  ########################################
  hardware.graphics = {
    enable = true;
    # Drivers/Loaders at system level
    extraPackages = [ pkgs.vulkan-loader ];
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  ########################################
  # --- nix-ld (System Linker) ---
  ########################################
  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld-rs;
    libraries = nixLdLibs;
  };

  ########################################
  # --- Environment (System-wide) ---
  ########################################
  environment = {
    variables = {};
    sessionVariables = {
      LD_LIBRARY_PATH = "/usr/lib/wsl/lib\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}";
      GALLIUM_DRIVER = "d3d12";
      WAYLAND_DISPLAY = "wayland-0";
      XDG_RUNTIME_DIR = "/mnt/wslg/runtime-dir";
      MESA_D3D12_DEFAULT_ADAPTER_NAME = "NVIDIA";
    };
    
    systemPackages = with pkgs; [
      wget
      vim
      vulkan-tools
      glxinfo
      xorg.xhost
    ];
  };
}