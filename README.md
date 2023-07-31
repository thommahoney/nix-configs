# nix-configs

## macOS setup

1. After initial macOS setup (user account, iCloud sign-in etc.) open Terminal.app and run `xcode-select --install` to install the macOS developer tools.
1. Generate a new SSH key using `ssh-keygen -t ed25519 -C "EMAIL_ADDRESS"`
1. Using Safari.app, login to GitHub and add the new key to the account.
1. Clone the nix-configs repo locally:

```shell
git clone git@github.com:thommahoney/nix-configs.git ~/.config/nix-configs
```

1. Add the new host to the configuration if necessary.

1. Install nix using the [Determinate Systems Nix Installer](https://github.com/DeterminateSystems/nix-installer)

```shell
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

1. Install `nix-darwin`:

```shell
git clone git@github.com:thommahoney/nix-configs.git ~/.config/nix-configs
```

1. Iterate on config and apply it with:

```shell
darwin-rebuild switch --flake ~/.config/nix-darwin
```