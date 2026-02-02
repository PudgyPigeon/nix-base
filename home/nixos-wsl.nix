{ config, pkgs, inputs, username, ... }:
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs username; };

    users.${username} = {
      home.stateVersion = "24.11";

      # SSH Agent and Github keys
      services.ssh-agent.enable = true;
      programs.ssh = {
        enable = true;
        extraConfig = ''
          Host github.com
            IdentityFile ~/.ssh/github_id_ssh_key
            AddKeysToAgent yes
        '';
      };

      # Direnv and Bash
      programs.bash.enable = true;
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };

      home.packages = with pkgs; [
        git 
        neovim 
        wget
        inputs.helix.packages.${pkgs.system}.helix
      ];

      # User-specific Shell Env
      home.sessionVariables = {
        EDITOR = "hx";
      };
    };
  };
}