{
  description = "Example Darwin system flake";

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

      # Required by many of the systemPackages
      # nixpkgs.config.allowUnfree = true;

      # Manage homebrew with nix-darwin
      homebrew.enable = true;

      # prevent homebrew auto-update when invoked via CLI
      # https://daiderd.com/nix-darwin/manual/index.html#opt-homebrew.global.autoUpdate
      homebrew.global.autoUpdate = false;

      # Uninstall brews and Zap casks that are not present in this config
      # https://daiderd.com/nix-darwin/manual/index.html#opt-homebrew.onActivation.cleanup
      homebrew.onActivation.cleanup = "zap";

      homebrew.brews = [
        "md5sha1sum" # would install coreutils via nix but it has a bunch of binaries I don't want eg. chmod
      ];

      # Homebrew install these casks
      homebrew.casks = [
         "1password"          # 1Password wants to be installed /Applications (not /Applicatons/Nix Apps)
         "1password-cli"      # because 1Password is installed this way
         "alfred"             # not available in nixpkgs
         "authy"              # not available in nixpkgs
         "backblaze"          # not available in nixpkgs
         "choosy"             # not available in nixpkgs # TODO: figure out how to set default browser (to Choosy)
         "clocker"            # not available in nixpkgs
         "dropbox"            # not available in nixpkgs
         "firefox"            # not available in nixpkgs
         "gimp"               # failed to install via nixpkgs
         "iterm2"             # TODO: install with nixpkgs
         "rewind"             # not available in nixpkgs
         "signal"             # not available in nixpkgs
         "spotify"            # TODO: install with nixpkgs
         "tailscale"          # TODO: couldn't find app after install with nixpkgs
         "telegram"           # not available in nixpkgs
         "visual-studio-code" # TODO: install with nixpkgs
         "whatsapp"           # not available in nixpkgs
      ];

      # To install backblaze run:
      #   $ read -r VERSION INSTALLER <<<$(brew info --json=v2 --cask backblaze | jq -r '.casks[0] | [.version, (.artifacts[] | select(.installer) | .installer[0].manual)] | @tsv') && open "$(brew --caskroom)/backblaze/$VERSION/$INSTALLER"

      homebrew.masApps = {
        "Divvy" = 413857545; # valid license through MAS
      };

      # TODO: configure divvy with:
      #    /Library/Preferences/com.mizage.Divvy.plist

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true;  # default shell on catalina
      # programs.fish.enable = true;

      # set shell aliases
      environment.shellAliases = {
        gco = "git checkout";
        grs = "git restore --staged";
        gs = "git status";
        gsl = "git log --oneline --graph --decorate";
        ll = "ls -lah";
      };

      # set up /etc/zshrc
      # https://daiderd.com/nix-darwin/manual/index.html#opt-programs.zsh.interactiveShellInit
      programs.zsh.interactiveShellInit = ''
        eval "$(zoxide init zsh)"
      '';

      # configure the prompt to use starship
      # https://daiderd.com/nix-darwin/manual/index.html#opt-programs.zsh.promptInit
      programs.zsh.promptInit = ''
        eval "$(starship init zsh)"
      '';

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 4;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      # Dark Mode
      # https://daiderd.com/nix-darwin/manual/index.html#opt-system.defaults.NSGlobalDomain.AppleInterfaceStyle
      system.defaults.NSGlobalDomain.AppleInterfaceStyle = "Dark";

      # Hot Corners
      # https://daiderd.com/nix-darwin/manual/index.html#opt-system.defaults.dock.wvous-bl-corner
      system.defaults.dock.wvous-bl-corner = 2;  # Mission Control
      system.defaults.dock.wvous-br-corner = 4;  # Desktop
      system.defaults.dock.wvous-tl-corner = 3;  # Application Windows
      system.defaults.dock.wvous-tr-corner = 10; # Display Sleep

      # Hide the Dock automatically
      # https://daiderd.com/nix-darwin/manual/index.html#opt-system.defaults.dock.autohide
      system.defaults.dock.autohide = true;

      # Hide recent applications in Dock
      # https://daiderd.com/nix-darwin/manual/index.html#opt-system.defaults.dock.show-recents
      system.defaults.dock.show-recents = false;

      # Allow keys to be remapped
      # https://daiderd.com/nix-darwin/manual/index.html#opt-system.keyboard.enableKeyMapping
      system.keyboard.enableKeyMapping = true;

      # Keyboard Remap Caps Lock to Escape
      # https://daiderd.com/nix-darwin/manual/index.html#opt-system.keyboard.remapCapsLockToEscape
      system.keyboard.remapCapsLockToEscape = true;

      # Faster key repeat rates
      # https://daiderd.com/nix-darwin/manual/index.html#opt-system.defaults.NSGlobalDomain.InitialKeyRepeat
      # https://daiderd.com/nix-darwin/manual/index.html#opt-system.defaults.NSGlobalDomain.KeyRepeat
      system.defaults.NSGlobalDomain.InitialKeyRepeat = 15;
      system.defaults.NSGlobalDomain.KeyRepeat = 2;

      # Use keyboard to navigate
      # https://daiderd.com/nix-darwin/manual/index.html#opt-system.defaults.NSGlobalDomain.AppleKeyboardUIMode
      system.defaults.NSGlobalDomain.AppleKeyboardUIMode = 3;

      # Tap to click
      # https://daiderd.com/nix-darwin/manual/index.html#opt-system.defaults.NSGlobalDomain._com.apple.mouse.tapBehavior_
      system.defaults.NSGlobalDomain."com.apple.mouse.tapBehavior" = 1;
      # https://daiderd.com/nix-darwin/manual/index.html#opt-system.defaults.trackpad.Clicking
      system.defaults.trackpad.Clicking = true;

      # Speed up the trackpad
      # https://daiderd.com/nix-darwin/manual/index.html#opt-system.defaults.NSGlobalDomain._com.apple.trackpad.scaling_
      system.defaults.NSGlobalDomain."com.apple.trackpad.scaling" = 2.5;

      # Finder: Always show file extensions
      # https://daiderd.com/nix-darwin/manual/index.html#opt-system.defaults.NSGlobalDomain.AppleShowAllExtensions
      system.defaults.NSGlobalDomain.AppleShowAllExtensions = true;

      # Finder: Show hidden files
      # https://daiderd.com/nix-darwin/manual/index.html#opt-system.defaults.NSGlobalDomain.AppleShowAllFiles
      system.defaults.NSGlobalDomain.AppleShowAllFiles = true;

      # Toolbar: Show seconds in clock
      # https://daiderd.com/nix-darwin/manual/index.html#opt-system.defaults.menuExtraClock.ShowSeconds
      system.defaults.menuExtraClock.ShowSeconds = true;

      # Sound: Play feedback when volume is changed
      # https://daiderd.com/nix-darwin/manual/index.html#opt-system.defaults.NSGlobalDomain._com.apple.sound.beep.feedback_
      system.defaults.NSGlobalDomain."com.apple.sound.beep.feedback" = 1;

      # https://daiderd.com/nix-darwin/manual/index.html#opt-system.defaults.CustomUserPreferences
      system.defaults.CustomUserPreferences = {
        # Show Bluetooth, Focus Mode, and Sound in Menu Bar
        # TODO: confirm these work
        "com.apple.controlcenter" = {
          "NSStatusItem Visible Bluetooth" = 1;
          "NSStatusItem Visible FocusModes" = 1;
          "NSStatusItem Visible Sound" = 1;
        };
        # disable Handoff features
        # this broke Universal Clipboard
        # "com.apple.coreservices.useractivityd" = {
        #   "ActivityAdvertisingAllowed" = false;
        #   "ActivityReceivingAllowed" = false;
        # };
        # fix key repeat in VSCode
        "com.microsoft.VSCode" = { "ApplePressAndHoldEnabled" = false; };
      };

      # TODO: figure out how to set default browser (to Choosy)

      # TODO: configure Choosy & license?
      #       ~/Library/Application\ Support/Choosy/behaviours.plist
      #       ~/Library/Preferences/com.choosyosx.Choosy.plist

      # TODO: configure Alfred & license?
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#flow
    darwinConfigurations."flow" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."flow".pkgs;
  };
}
