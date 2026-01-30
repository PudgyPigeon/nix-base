{ config, lib, pkgs, nixpkgs, nixos-wsl, inputs, ... }:

let
  isWSL = builtins.pathExists "/proc/sys/fs/binfmt_misc/WSLInterop";
  helixPkg = inputs.helix.packages.${pkgs.system}.helix;

  # Common package sets
  commonPackages = with pkgs; [
    git vim neovim wget
    go gotools golangci-lint
    vulkan-tools pulseaudio pipewire
    xorg.xhost glxinfo
    helixPkg
  ];

  graphicsPackages = with pkgs; [
    mesa mesa.drivers
    vulkan-loader vulkan-tools
  ];

  nixLdLibs = with pkgs; [
    stdenv.cc.cc
    mesa
    libglvnd
  ];
in {
  system.stateVersion = "24.11";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  imports = lib.optional isWSL nixos-wsl;
  ########################################
  # --- WSL integration ---
  ########################################
  wsl = lib.mkIf isWSL {
    enable = true;
    defaultUser = "nixos";
    useWindowsDriver = true;
    interop.register = true;
  };

  boot.isContainer = lib.mkIf isWSL true;
  users.users.nixos.extraGroups = [ "docker" ];
  ########################################
  # --- Docker ---
  ########################################
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
    daemon.settings.runtimes.nvidia.path =
      "${pkgs.nvidia-docker}/bin/nvidia-container-runtime";
  };
  ########################################
  # --- Graphics / Pipewire ---
  ########################################
  hardware.graphics = {
    enable = true;
    extraPackages = graphicsPackages;
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  ########################################
  # --- nix-ld ---
  ########################################
  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld-rs;
    libraries = nixLdLibs;
  };
  ########################################
  # --- Environment ---
  ########################################
  environment = {
    variables = {
      EDITOR = "neovim";
      GALLIUM_DRIVER = "d3d12";
    };
    sessionVariables = {
      LD_LIBRARY_PATH = "/usr/lib/wsl/lib";
      XDG_RUNTIME_DIR = "/mnt/wslg/runtime-dir";
      WAYLAND_DISPLAY = "wayland-0";
      MESA_D3D12_DEFAULT_ADAPTER_NAME = "NVIDIA";
    };
    systemPackages = commonPackages;
  };
}