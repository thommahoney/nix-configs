{
  description = "gigi macOS system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    commonConfiguration = import ../common/configuration.nix;
    # gigi specific configuration (empty for now, as it should be similar to flow/petite)
    configuration = { pkgs, ... }: {
      # Add any gigi-specific settings here in the future.
      # For example, if gigi needs a specific cask:
      # homebrew.casks = [ "some-gigi-specific-cask" ];
    };
  in
  {
    darwinConfigurations."gigi" = nix-darwin.lib.darwinSystem {
      modules = [ commonConfiguration configuration ];
    };
    darwinPackages = self.darwinConfigurations."gigi".pkgs;
  };
}
