{ config, lib, pkgs, nixpkgs, nixos-wsl, inputs, ... }:

let
  isWSL = builtins.pathExists "/proc/sys/fs/binfmt_misc/WSLInterop";
in {
  system.stateVersion = "24.11";

  # Conditional WSL config
  imports = lib.optional isWSL nixos-wsl;
  wsl = {
    enable = lib.mkIf isWSL true;
    defaultUser = lib.mkIf isWSL "nixos";
  };
  boot.isContainer = lib.mkIf isWSL true;

  # Flakes support
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Allow unfree packages (needed for nvidia-x11)
  nixpkgs.config.allowUnfree = true;

  # Docker setup
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
    # daemon.settings.features.cdi = true;
    # daemon.settings.cdi-spec-dirs = [ "/etc/cdi" ];
  };

  # NVIDIA GPU passthrough + CUDA
  hardware.graphics.enable = true;
  # hardware.enableRedistributableFirmware = lib.mkDefault true;
  hardware.graphics.extraPackages = with pkgs; [
    mesa
    vulkan-loader
    vulkan-tools
    # libGL
    # libdrm
  ];
  # hardware.nvidia.open = true;

  environment.sessionVariables = {
    # CUDA_PATH = "${pkgs.cudatoolkit}";
    # EXTRA_LDFLAGS = "-L/lib -L${pkgs.linuxPackages.nvidia_x11}/lib";
    # EXTRA_CCFLAGS = "-I/usr/include";
    # MESA_D3D12_DEFAULT_ADAPTER_NAME = "Nvidia";
    # LD_LIBRARY_PATH = [
    #   "/usr/lib/wsl/lib"
    #   "${pkgs.linuxPackages.nvidia_x11}/lib"
    #   "${pkgs.ncurses5}/lib"
    # ];
    # Force WSLg compositor runtime
    XDG_RUNTIME_DIR = "/mnt/wslg/runtime-dir";
    WAYLAND_DISPLAY = "wayland-0";
  };


  users.users.nixos.extraGroups = [ "docker" ];

  # Default editor
  environment.variables.EDITOR = "neovim";

  # VS Code compatibility for WSL
  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld-rs;
  };

  # Packages
  environment.systemPackages = with pkgs; [
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
  ];
}