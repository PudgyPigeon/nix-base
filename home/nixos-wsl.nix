{ config, pkgs, inputs, username, stateVersion, ... }:
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs username stateVersion; };

    users.${username} = {
      home.username = username;
      home.homeDirectory = "/home/${username}";
      home.stateVersion = stateVersion; 
      home.sessionVariables = {
        EDITOR = "hx";
      };

      # --- SSH Agent and Github keys ---
      services.ssh-agent.enable = true;
      programs.ssh = {
        enable = true;
        extraConfig = ''
          Host github.com
            IdentityFile ~/.ssh/github_id_ssh_key
            AddKeysToAgent yes
        '';
      };

      # --- Shell & Environment ---
      programs.bash.enable = true;
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };

      # --- Packages ---
      home.packages = with pkgs; [
        git 
        neovim 
        wget
        inputs.helix.packages.${pkgs.system}.helix
      ];
    };
  };
}