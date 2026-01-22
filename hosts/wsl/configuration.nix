{ config, lib, pkgs, nixpkgs, nixos-wsl, inputs, ... }:

let
  isWSL = builtins.pathExists "/proc/sys/fs/binfmt_misc/WSLInterop";
in {
  system.stateVersion = "24.11";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  
  imports = lib.optional isWSL nixos-wsl;

  wsl = {
    enable = lib.mkIf isWSL true;
    defaultUser = lib.mkIf isWSL "nixos";
    useWindowsDriver = true;
  };
  users.users.nixos.extraGroups = [ "docker" ];
  boot.isContainer = lib.mkIf isWSL true;

  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
    daemon.settings = {
      runtimes.nvidia = {
        path = "${pkgs.nvidia-docker}/bin/nvidia-container-runtime";
      };
    };
  };
  # hardware.nvidia-container-toolkit.enable = true;

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      mesa
      vulkan-loader
      vulkan-tools
    ];
  };

  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld-rs;
    # Add the WSL-specific library path to nix-ld's search path
    libraries = with pkgs; [
      stdenv.cc.cc
      mesa
      libglvnd
    ];
  };

  environment = {
    # 1. Shell and System Variables
    variables = {
      EDITOR = "neovim";
      GALLIUM_DRIVER = "d3d12";
    };
    # 2. Session-wide Variables (Best for WSL/GPU paths)
    sessionVariables = {
      LD_LIBRARY_PATH = "/usr/lib/wsl/lib";
      XDG_RUNTIME_DIR = "/mnt/wslg/runtime-dir";
      WAYLAND_DISPLAY = "wayland-0";
      MESA_D3D12_DEFAULT_ADAPTER_NAME = "NVIDIA";
    };
    # 3. System-wide Packages
    systemPackages = with pkgs; [
      git 
      vim 
      neovim 
      wget
      go 
      gotools 
      golangci-lint
      vulkan-tools
      pulseaudio 
      pipewire 
      xorg.xhost
      glxinfo
    ];
  };
}