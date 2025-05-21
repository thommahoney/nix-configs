# common/configuration.nix
{ pkgs, ... }: {
  environment.systemPackages = [
    pkgs.fzf
    pkgs.go
    pkgs.jq
    pkgs.mas
    (pkgs.nerdfonts.override { fonts = [ "Meslo" ]; })
    pkgs.rustup
    pkgs.starship
    pkgs.vim
    pkgs.wget
    pkgs.yq
    pkgs.zoxide
  ];

  services.nix-daemon.enable = true;

  nix.settings.experimental-features = "nix-command flakes";

  system.stateVersion = 4;

  nixpkgs.hostPlatform = "aarch64-darwin";

  system = {
    defaults = {
      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark";
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
        AppleKeyboardUIMode = 3;
        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.trackpad.scaling" = 2.5;
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        "com.apple.sound.beep.feedback" = 1;
      };
      CustomUserPreferences = {
          "com.microsoft.VSCode" = { "ApplePressAndHoldEnabled" = false; };
      };
      dock = {
        autohide = true;
        "show-recents" = false;
        "wvous-bl-corner" = 2; # Mission Control
        "wvous-br-corner" = 4; # Desktop
        "wvous-tl-corner" = 3; # Application Windows
        "wvous-tr-corner" = 10; # Display Sleep
      };
      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
      };
      menuExtraClock.ShowSeconds = true;
      trackpad = {
        Clicking = true;
      };
    };
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };
  };

  programs.zsh = {
    enable = true;
    interactiveShellInit = ''
      eval "$(zoxide init zsh)"
    '';
    promptInit = ''
      eval "$(starship init zsh)"
    '';
  };

  environment.shellAliases = {
    gco = "git checkout";
    grs = "git restore --staged";
    gs = "git status";
    gsl = "git log --oneline --graph --decorate";
    ll = "ls -lah";
  };

  homebrew = {
    enable = true;
    global.autoUpdate = false;
    onActivation.cleanup = "zap";
    brews = [
      "md5sha1sum"
    ];
    casks = [
      "1password",
      "1password-cli",
      "alfred",
      "dropbox",
      "firefox",
      "iterm2",
      "signal",
      "spotify",
      "tailscale",
      "telegram",
      "visual-studio-code",
      "whatsapp"
    ];
    masApps = {
      "Divvy" = 413857545;
    };
  };
}
