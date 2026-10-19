{ config, lib, pkgs, ... }:

{
  hardware.nvidia-container-toolkit = {
    enable = true;
    mount-nvidia-executables = false;
    suppressNvidiaDriverAssertion = true;
  };
  
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [ vulkan-loader libglvnd ];
  };

  # Automatically generate the correct CDI spec for WSL2 using --mode wsl
  systemd.services.nvidia-cdi-gen = {
    description = "Generate NVIDIA CDI specification for WSL2";
    wantedBy = [ "multi-user.target" ];
    before = [ "docker.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Environment = "LD_LIBRARY_PATH=/usr/lib/wsl/lib";
      ExecStart = "${pkgs.nvidia-container-toolkit}/bin/nvidia-ctk cdi generate --mode=wsl --nvidia-ctk-path=${pkgs.nvidia-container-toolkit}/bin/nvidia-ctk --output=/etc/cdi/nvidia.yaml";
    };
  };

  environment.systemPackages = with pkgs; [
    vulkan-tools
    mesa-demos
    nvidia-container-toolkit
  ];
}