{
  config,
  lib,
  pkgs,
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
        nix-search-cli.packages.${system}.default
        fd
        marksman
        skopeo
        kustomize
        ghostty
        gnumake
        google-chrome
        devilspie2
        (pkgs.slack.overrideAttrs (old: {
          installPhase =
            old.installPhase
            + ''
              substituteInPlace $out/share/applications/slack.desktop \
                --replace "Exec=slack" "Exec=env GDK_BACKEND=x11 slack"
            '';
        }))
        zoom-us
        wl-clipboard
        zig
        azure-cli
        awscli2
        google-cloud-sdk
        bazelisk
        wakeonlan
        python314
        signal-desktop
      ]
      ++ lib.optionals pkgs.stdenv.isDarwin [
        # GNU tools for macOS only
        coreutils
        findutils
        gawk
        gnused
        gnugrep
        gnumake
        nerd-fonts.hack
        tenv
        watch
        granted
        virt-viewer
        (pkgs.writeShellScriptBin "bazel" ''
          exec ${pkgs.bazelisk}/bin/bazelisk "$@"
        '')

        (stdenv.mkDerivation {
          pname = "kubectl-slice";
          version = "v1.4.2";
          src = fetchurl {
            url = "https://github.com/patrickdappollonio/kubectl-slice/releases/download/v1.4.2/kubectl-slice_darwin_arm64.tar.gz";
            # Retrieved through `nix-prefetch-url $url`
            sha256 = "0gh3f7isq26jzd7wfgck63yi1jhrzmjqi2ypaa9mn0ascfwgvns6";
          };
          dontUnpack = false;
          sourceRoot = ".";
          installPhase = ''
            install -Dm755 kubectl-slice $out/bin/kubectl-slice
          '';
        })
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
    plugins = [
      {
        name = "bass";
        src = pkgs.fishPlugins.bass.src;
      }
      {
        name = "bang-bang";
        src = pkgs.fishPlugins.bang-bang.src;
      }
      {
        name = "autopair";
        src = pkgs.fishPlugins.autopair.src;
      }
    ];
  };

  programs.neovim = {
    enable = true;

    plugins = with pkgs.vimPlugins; [
      blink-cmp
      blink-cmp-copilot
      nvim-lspconfig
      nvim-treesitter
      gitsigns-nvim
      nvim-autopairs
      indent-blankline-nvim
      vim-illuminate
      lspkind-nvim
      nvim-web-devicons
      copilot-lua
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
      gruvbox-nvim
      vim-wordmotion
    ];

    extraPackages = with pkgs; [
      # Language servers
      clang-tools # clangd
      gopls
      python313Packages.python-lsp-server # pylsp
      terraform-ls # terraformls
      lua-language-server # lua_ls
      nixd # nixlsp
      alejandra
      starpls

      # Additional tools
      tree-sitter
    ];

    extraLuaConfig = builtins.readFile ./nvim_init.lua;
  };

  programs.ghostty = {
    enable = true;
    package = null;
    enableBashIntegration = true;
    settings = import ./ghostty_config.nix {inherit pkgs;};
  };

  programs.git = {
    enable = true;
    userName = "Alvaro Aleman";
    userEmail = "alvaroaleman@users.noreply.github.com";
    aliases = {
      s = "status";
      co = "checkout";
    };
    ignores = [
      "temp"
      "**/.claude/settings.local.json"
    ];
    extraConfig = {
      diff = {
        colorMoved = "default";
        algorithm = "histogram";
      };
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

  home.file = {
    ".local/bin/ghostty-workspace" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        if pgrep -x ghostty > /dev/null; then
          ghostty --window
        else
          ghostty &
        fi
      '';
    };
  };

  dconf.settings = {
    "org/gnome/desktop/wm/keybindings" = {
      switch-to-workspace-1 = ["<Alt>1"];
      switch-to-workspace-2 = ["<Alt>2"];
      switch-to-workspace-3 = ["<Alt>3"];
      switch-to-workspace-4 = ["<Alt>4"];
      switch-to-workspace-5 = ["<Alt>5"];
      switch-to-workspace-6 = ["<Alt>6"];
      switch-to-workspace-7 = ["<Alt>7"];
      switch-to-workspace-8 = ["<Alt>8"];
      switch-to-workspace-9 = ["<Alt>9"];
      move-to-workspace-1 = ["<Alt><Shift>1"];
      move-to-workspace-2 = ["<Alt><Shift>2"];
      move-to-workspace-3 = ["<Alt><Shift>3"];
      move-to-workspace-4 = ["<Alt><Shift>4"];
      move-to-workspace-5 = ["<Alt><Shift>5"];
      move-to-workspace-6 = ["<Alt><Shift>6"];
      move-to-workspace-7 = ["<Alt><Shift>7"];
      move-to-workspace-8 = ["<Alt><Shift>8"];
      move-to-workspace-9 = ["<Alt><Shift>9"];
    };
    "org/gnome/mutter" = {
      dynamic-workspaces = false;
    };
    "org/gnome/desktop/notifications" = {
      show-banners = false;
    };
    "org/gnome/desktop/wm/preferences" = {
      num-workspaces = 9;
    };
    "org/gnome/desktop/interface" = {
      enable-animations = false;
    };
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = ["/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"];
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      name = "Ghostty Workspace";
      command = "${config.home.homeDirectory}/.local/bin/ghostty-workspace";
      binding = "<Alt>Return";
    };
    "org/gnome/shell" = {
      enabled-extensions = ["workspace-indicator@gnome-shell-extensions.gcampax.github.com"];
    };
  };

  systemd.user.services.devilspie2 = {
    Unit = {
      Description = "Devilspie2 window manager";
      After = ["graphical-session-pre.target"];
      PartOf = ["graphical-session.target"];
    };
    Service = {
      ExecStart = "${pkgs.devilspie2}/bin/devilspie2";
      Restart = "on-failure";
      Environment = "GDK_BACKEND=x11";
    };
    Install.WantedBy = ["graphical-session.target"];
  };
}
