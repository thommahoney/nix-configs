{
  description = "petite macOS system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    commonConfiguration = import ../common/configuration.nix;
    configuration = { pkgs, ... }: {
      # petite-specific homebrew casks
      homebrew.casks = [
        "google-chrome"      # not in common
        "zoom"               # not in common
      ];

      # petite-specific zsh login shell init
      programs.zsh.loginShellInit = ''
        eval "$(/opt/homebrew/bin/brew shellenv)"
      '';

      # System configuration revision
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # petite-specific system defaults
      system.defaults = {
        dock = {
          appswitcher-all-displays = true; # petite specific
          # Override common hot corners to match petite's original settings
          wvous-bl-corner = 3; # Application Windows (common was 2 for Mission Control)
          wvous-tl-corner = 2; # Mission Control (common was 3 for Application Windows)
        };
        finder = {
          ShowPathbar = true;           # petite specific
          FXPreferredViewStyle = "Nlsv"; # petite specific
        };
      };

      # TODO: configure divvy with: /Library/Preferences/com.mizage.Divvy.plist (reminder)
      #       (Divvy MAS app is in commonConfiguration)
      # TODO: configure iterm with Meslo nerdfont
      #       (nerdfonts package is in commonConfiguration)
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#petite
    darwinConfigurations."petite" = nix-darwin.lib.darwinSystem {
      modules = [ commonConfiguration configuration ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."petite".pkgs;
  };
}
