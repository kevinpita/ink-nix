# ink-nix

A small Nix flake for [ink](https://github.com/borghei/ink), a terminal Markdown reader.
Packages upstream Linux binaries for x86_64 and aarch64. No Cachix setup is needed.

## Run

```sh
nix run github:kevinpita/ink-nix -- README.md
```

## NixOS

Add the input:

```nix
inputs.ink-nix = {
  url = "github:kevinpita/ink-nix";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Then add the overlay and package to your NixOS configuration:

```nix
nixpkgs.overlays = [ inputs.ink-nix.overlays.default ];
environment.systemPackages = [ pkgs.ink ];
```

## Updates

GitHub Actions checks for a new stable release daily. It downloads both Linux
binaries, updates their hashes in `sources.json`, checks the x86_64 package,
and commits the update. Builds on push and pull requests test both architectures.
Bot commits do not trigger another workflow run.

To update locally, install `gh`, `jq`, and Nix, then run:

```sh
./scripts/update.sh          # latest release
./scripts/update.sh 0.7.0    # specific release
nix flake check
```

To use a new release in a consuming configuration, update its `ink-nix` lock entry
and rebuild. This flake does not update or rebuild your system automatically.

```sh
nix flake update ink-nix
```
