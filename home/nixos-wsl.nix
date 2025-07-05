# Set up Home Manager + SSH key loading/agent if present - remove if erroring out
{ username ? "nixos", ... }:
  let
    wslHomeManagerConfigModule = { config, pkgs, ... }: {
      home-manager.users.${username} = {
        home.stateVersion = "24.11";
        services.ssh-agent.enable = true;

        programs.ssh = {
          enable = true;
          extraConfig = ''
            AddKeysToAgent yes
            IdentityFile ~/.ssh/github_id_ssh_key
          '';
        };
      };
    };
  in
    wslHomeManagerConfigModule