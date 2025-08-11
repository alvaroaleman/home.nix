{
  pkgs,
  user,
  ...
}: {
  system.stateVersion = 6;
  system.primaryUser = user;

  system.defaults.finder = {
    AppleShowAllFiles = true; # Show hidden files
    ShowPathbar = true; # Show path bar
    ShowStatusBar = true; # Show status bar
  };

  system.defaults.NSGlobalDomain = {
    AppleShowAllExtensions = true; # Show file extensions
  };

  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.settings.trusted-users = [user];

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
    };
    taps = [
      "nikitabobko/tap"
      "FelixKratz/formulae"
    ];
    casks = [
      "nikitabobko/tap/aerospace"
      "ghostty"
      "caffeine"
    ];
    brews = [
      "FelixKratz/formulae/sketchybar"
    ];
  };

  programs.fish.enable = true;

  # This does not override the MacOS default shells,
  # just add to them.
  environment.shells = [pkgs.bash pkgs.fish];

  users.users.${user} = {
    name = user;
    home = "/Users/${user}";
  };
}
