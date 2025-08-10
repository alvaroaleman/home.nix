{
  config,
  lib,
  pkgs,
  nvim-plugin-gruvbox,
  nix-search-cli,
  ...
}: {
  nixpkgs.config.allowUnfree = true;
  home = {
    packages = with pkgs;
      [
        hello
        home-manager
        nodejs # needed for vim-copilot
        go
        ripgrep
        kubectl
        krew
        starship
        gh
        goperf # contains benchstat
        claude-code
        kubevirt
        virt-viewer
        nix-search-cli.packages.${system}.default
      ]
      ++ lib.optionals pkgs.stdenv.isDarwin [
        # GNU tools for macOS only
        coreutils
        findutils
        gawk
        gnused
        gnugrep
        gnumake
        wakeonlan
        nerd-fonts.hack
      ];

    homeDirectory =
      if config.home.username == "root"
      then "/root"
      else if pkgs.stdenv.isDarwin
      then "/Users/${config.home.username}"
      else "/home/${config.home.username}";

    # You do not need to change this if you're reading this in the future.
    # Don't ever change this after the first build.  Don't ask questions.
    stateVersion = "23.11";
  };

  programs.bash = {
    enable = true;
    bashrcExtra = builtins.readFile ./bashrc;
  };
  programs.fish = {
    enable = true;
    shellInit = builtins.readFile ./fish_init.fish;
  };

  programs.neovim = {
    enable = true;

    plugins = let
      buildPlugin = name: src:
        pkgs.vimUtils.buildVimPlugin {
          inherit name src;
        };
    in
      with pkgs.vimPlugins;
        [
          nvim-cmp
          cmp-nvim-lsp
          cmp-buffer
          cmp-path
          cmp_luasnip
          luasnip
          nvim-lspconfig
          nvim-treesitter
          gitsigns-nvim
          nvim-autopairs
          indent-blankline-nvim
          vim-illuminate
          lspkind-nvim
          nvim-web-devicons
          copilot-lua
          copilot-cmp
          nvim-ufo
          rainbow-delimiters-nvim
          vimade
          lsp_signature-nvim
          nvim-treesitter-context
          vim-airline
          vim-airline-themes
          vim-gh-line
          promise-async
          statuscol-nvim
          fidget-nvim
          bigfile-nvim
          trouble-nvim
          nvim-web-devicons
        ]
        ++ [
          (buildPlugin "gruvbox.nvim" nvim-plugin-gruvbox)
        ];

    extraPackages = with pkgs; [
      # Language servers
      clang-tools # clangd
      gopls
      python311Packages.python-lsp-server # pylsp
      terraform-ls # terraformls
      lua-language-server # lua_ls
      nixd # nixlsp
      alejandra

      # Additional tools
      tree-sitter
    ];

    extraLuaConfig = builtins.readFile ./nvim_init.lua;
  };

  programs.ghostty = {
    enable = true;
    package = null;
    enableBashIntegration = true;
    settings = import ./ghostty_config.nix;
  };

  programs.git = {
    enable = true;
    userName = "Alvaro Aleman";
    userEmail = "alvaroaleman@users.noreply.github.com";
    aliases = {
      s = "status";
      co = "checkout";
    };
    extraConfig = {
      push = {
        autoSetupRemote = true;
      };
    };
  };

  programs.starship = {
    enable = true;
    settings = builtins.fromTOML (builtins.readFile ./starship.toml);
  };

  programs.ssh = {
    enable = true;
    includes = ["~/.ssh/config_local"];
    matchBlocks = {
      "*" = {
        user = "root";
        setEnv = {
          TERM = "xterm-256color";
        };
      };
    };
  };

  services.skhd = lib.mkIf pkgs.stdenv.isDarwin {
    enable = true;
    package = pkgs.skhd;
    config = ./skhdrc;
  };

  programs.aerospace = lib.mkIf pkgs.stdenv.isDarwin {
    enable = true;
    package = null;
    userSettings = builtins.fromTOML (builtins.readFile ./aerospace.toml);
  };

  home.file = lib.mkIf pkgs.stdenv.isDarwin {
    ".config/sketchybar" = {
      source = ./sketchybar;
      recursive = true;
    };
  };
}
