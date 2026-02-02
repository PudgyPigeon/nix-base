{ config, pkgs, inputs, username, ... }:
{
  home-manager.users.${username} = {
    home.stateVersion = "24.11";

    # 1. User-specific pacakges
    home.packages = with pkgs; [
      git 
      neovim 
      wget
      inputs.helix.packages.${pkgs.system}.helix
    ];

    # 2. SSH Agent and Github keys
    services.ssh-agent.enable = true;
    programs.ssh = {
      enable = true;
      extraConfig = ''
        Host github.com
          IdentityFile ~/.ssh/github_id_ssh_key
          AddKeysToAgent yes
      '';
    };

    # 3. Direnv with the Caching "Fix"
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    # 4. User-specific Shell Env
    home.sessionVariables = {
      EDITOR = "hx";
    };
  };
}