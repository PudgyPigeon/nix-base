{
  config,
  pkgs,
  inputs,
  username,
  stateVersion,
  ...
}: {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {inherit inputs username stateVersion;};

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
        config.global.log_filter = "^$";
      };

      # --- NVIM Config ---
      programs.neovim = {
        enable = true;
        plugins = with pkgs.vimPlugins; [
          # Themes
          catppuccin-nvim
          tokyonight-nvim
          gruvbox-material
          gruvbox-nvim
          kanagawa-nvim
          rose-pine
          nord-nvim
          nightfox-nvim
          onedark-nvim
          # Syntax & Navigation
          nvim-treesitter.withAllGrammars
          telescope-nvim
          plenary-nvim
        ];
        extraLuaConfig = ''
          local config = vim.fn.stdpath("config") .. "/init.lua"
          if vim.loop.fs_stat(config) then
            dofile(config)
          end
        '';
      };
      xdg.configFile."nvim".source = ../dotfiles/nvim;

      # --- Packages ---
      home.packages = with pkgs; [
        git
        wget
        inputs.helix.packages.${stdenv.hostPlatform.system}.helix
      ];
    };
  };
}
