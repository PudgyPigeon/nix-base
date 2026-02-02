{ config, lib, pkgs, nixpkgs, nixos-wsl, inputs, ... }:

let
  isWSL = builtins.pathExists "/proc/sys/fs/binfmt_misc/WSLInterop";
  helixPkg = inputs.helix.packages.${pkgs.system}.helix;

  commonPackages = with pkgs; [
    git vim neovim wget
    go gotools golangci-lint
    vulkan-tools pulseaudio pipewire
    xorg.xhost glxinfo
    helixPkg direnv nix-direnv
  ];

  graphicsPackages = with pkgs; [
    vulkan-loader vulkan-tools
  ];

  nixLdLibs = with pkgs; [
    stdenv.cc.cc
    mesa
    libglvnd
    vulkan-loader # Added for Vulkan support in binaries
    xorg.libX11
  ];

in {
  system.stateVersion = "24.11";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  imports = lib.optional isWSL nixos-wsl;

  # This "hooks" direnv into your shell and enables the Nix caching
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
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
      # EDITOR = "neovim";
      # This tells Mesa to use the D3D12 translation layer
      GALLIUM_DRIVER = "d3d12";
    };
    sessionVariables = {
      # Tells Nix where the Windows-side .so files are
      LD_LIBRARY_PATH = "/usr/lib/wsl/lib";
      # These link to the WSLg graphics server
      XDG_RUNTIME_DIR = "/mnt/wslg/runtime-dir";
      WAYLAND_DISPLAY = "wayland-0";
      MESA_D3D12_DEFAULT_ADAPTER_NAME = "NVIDIA";
    };
    systemPackages = commonPackages;
  };
}