# nix-configs

## macOS setup

1. After initial macOS setup (user account, iCloud sign-in etc.) open Terminal.app and run `xcode-select --install` to install the macOS developer tools.
2. Generate a new SSH key using `ssh-keygen -t ed25519 -C "EMAIL_ADDRESS"`
3. Using Safari.app, login to GitHub and add the new key to the account.
4. Clone the nix-configs repo locally:

```shell
git clone git@github.com:thommahoney/nix-configs.git ~/.config/nix-configs
```

5. Add the new host to the configuration if necessary.

6. Install [homebrew](https://brew.sh/):

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

7. Install nix using the [Determinate Systems Nix Installer](https://github.com/DeterminateSystems/nix-installer)

```shell
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

8. Install `nix-darwin`:

```shell
git clone git@github.com:thommahoney/nix-configs.git ~/.config/nix-configs
```

9. Iterate on config and apply it with:

```shell
darwin-rebuild switch --flake ~/.config/nix-configs
```