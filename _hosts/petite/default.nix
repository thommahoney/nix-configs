# "petite" MacBook Air

{ inputs, globals, overlays, ... }:

inputs.darwin.lib.darwinSystem {
  system = "x86_64-darwin";
  specialArgs = { };
  modules = [
    # ../../modules/common
    ../../_modules/darwin
    (globals // rec {
      user = "thom";
      gitName = "Thom Mahoney";
      gitEmail = "mahoneyt@gmail.com";
    })
  ];
}







{
  description = "petite macOS system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = [
        # pkgs.atuin
        # pkgs.bat
        # pkgs.starship
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

      # TODO: configure iterm with Meslo nerdfont
      #       Installed into macOS using `open /nix/store/qqg5b6vhh2hvl8km98l7d579c0si0djg-nerdfonts-3.0.2/share/fonts/truetype/NerdFonts/MesloLGSNerdFont-Regular.ttf`

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 4;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      system = {
        defaults = {
          CustomUserPreferences = {
            "com.microsoft.VSCode" = { "ApplePressAndHoldEnabled" = false; };
          };
          dock = {
            appswitcher-all-displays = true;
            autohide = true;
            show-recents = false;

            # hot corners
            # BL: Application Windows
            # BR: Desktop
            # TL: Mission Control
            # TR: Put Display to Sleep
            wvous-bl-corner = 3;
            wvous-br-corner = 4;
            wvous-tl-corner = 2;
            wvous-tr-corner = 10;
          };

          finder = {
            AppleShowAllExtensions = true;
            AppleShowAllFiles = true;
            ShowPathbar = true;
            FXPreferredViewStyle = "Nlsv";
          };

          menuExtraClock.ShowSeconds = true;
 
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

          trackpad = {
            Clicking = true;
          };
        };

        keyboard = {
          enableKeyMapping = true;
          remapCapsLockToEscape = true;
        };
      };


      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh = {
        enable = true;

        # set up /etc/zprofile
        # https://daiderd.com/nix-darwin/manual/index.html#opt-programs.zsh.loginShellInit
        loginShellInit = ''
          eval "$(/opt/homebrew/bin/brew shellenv)"
        '';

        # set up /etc/zshrc
        # https://daiderd.com/nix-darwin/manual/index.html#opt-programs.zsh.interactiveShellInit
        interactiveShellInit = ''
          eval "$(zoxide init zsh)"
        '';

        # configure the prompt to use starship
        # https://daiderd.com/nix-darwin/manual/index.html#opt-programs.zsh.promptInit
        promptInit = ''
          eval "$(starship init zsh)"
        '';
        };

      # set shell aliases
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
          "1password"          # 1Password wants to be installed /Applications (not /Applicatons/Nix Apps)
          "1password-cli"      # because 1Password is installed this way
          "alfred"             # not available in nixpkgs
          "android-commandlinetools"
          "android-studio"
          # "backblaze"          # not available in nixpkgs
          # "choosy"             # not available in nixpkgs # TODO: figure out how to set default browser (to Choosy)
          # "clocker"            # not available in nixpkgs
          "dropbox"            # not available in nixpkgs
          "firefox"            # not available in nixpkgs
          "google-chrome"      # not available in nixpkgs
          # "gimp"               # failed to install via nixpkgs
          "iterm2"             # TODO: install with nixpkgs
          # "rewind"             # not available in nixpkgs
          "signal"             # not available in nixpkgs
          "spotify"            # TODO: install with nixpkgs
          "tailscale"          # TODO: couldn't find app after install with nixpkgs
          "telegram"           # not available in nixpkgs
          "transmission"
          "temurin"            # required for android-commandlinetools
          "visual-studio-code" # TODO: install with nixpkgs
          "whatsapp"           # not available in nixpkgs
          "zoom"
        ];

        masApps = {
          "Divvy" = 413857545; # valid license through MAS
        };

        # TODO: configure divvy with:
        #    /Library/Preferences/com.mizage.Divvy.plist
      };

      # found in a blog post, unsure if it works.
      # system.activationScripts.postUserActivation.text = ''
      #   # Following line should allow us to avoid a logout/login cycle
      #   /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
      # '';
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#petite
    darwinConfigurations."petite" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."petite".pkgs;
  };
}
