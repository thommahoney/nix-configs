{
  description = "flow macOS system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    commonConfiguration = import ../common/configuration.nix;
    configuration = { pkgs, ... }: {
      # flow-specific homebrew casks
      homebrew.casks = [
        "authy"              # not in common
        "backblaze"          # not in common
        "boop"               # not in common (was in flow, not petite)
        "choosy"             # not in common
        "clocker"            # not in common
        "gimp"               # not in common (was in flow, not petite)
        "rewind"             # not in common
      ];

      # To install backblaze run:
      #   $ read -r VERSION INSTALLER <<<$(brew info --json=v2 --cask backblaze | jq -r '.casks[0] | [.version, (.artifacts[] | select(.installer) | .installer[0].manual)] | @tsv') && open "$(brew --caskroom)/backblaze/$VERSION/$INSTALLER"

      # TODO: configure iterm with Meslo nerdfont
      #       Installed into macOS using `open /nix/store/qqg5b6vhh2hvl8km98l7d579c0si0djg-nerdfonts-3.0.2/share/fonts/truetype/NerdFonts/MesloLGSNerdFont-Regular.ttf`
      #       (nerdfonts package is in commonConfiguration)

      # TODO: configure divvy with:
      #    /Library/Preferences/com.mizage.Divvy.plist
      #    (Divvy MAS app is in commonConfiguration)

      # TODO: configure Choosy & license?
      #       ~/Library/Application\ Support/Choosy/behaviours.plist
      #       ~/Library/Preferences/com.choosyosx.Choosy.plist

      # TODO: configure Alfred & license?

      # flow-specific CustomUserPreferences
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
      };

      # Optional: uncomment if flow specifically needs unfree packages, e.g. for backblaze installer
      # Required by many of the systemPackages
      # nixpkgs.config.allowUnfree = true;
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#flow
    darwinConfigurations."flow" = nix-darwin.lib.darwinSystem {
      modules = [ commonConfiguration configuration ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."flow".pkgs;
  };
}
