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
        pkgs.vim
      ];

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

      system.defaults = {
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

        trackpad = {
          Clicking = true;
        };

        menuExtraClock.ShowSeconds = true;
      };

      system.keyboard = {
        enableKeyMapping = true;
        remapCapsLockToEscape = true;
      };

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh = {
        enable = true;

        # https://daiderd.com/nix-darwin/manual/index.html#opt-programs.zsh.loginShellInit
        loginShellInit = ''
          eval "$(/opt/homebrew/bin/brew shellenv)"
        '';
      };

      homebrew = {
        enable = true;

        casks = [
          "zoom"
          "spotify"
        ];
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
