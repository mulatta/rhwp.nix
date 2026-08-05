# rhwp.nix

Nix packages for [rhwp](https://github.com/edwardkim/rhwp), an HWP/HWPX to SVG/PDF converter.

## Supported systems

- `x86_64-linux`
- `aarch64-linux`
- `aarch64-darwin`

## Usage

Run the `rhwp` CLI without installing it:

```console
$ nix run github:mulatta/rhwp.nix -- --help
```

To use this repository from another flake, add it as an input:

```nix
{
  inputs.rhwp.url = "github:mulatta/rhwp.nix";

  outputs = { nixpkgs, rhwp, ... }: {
    # Select the package for the system used by your output.
    packages.x86_64-linux.default = rhwp.packages.x86_64-linux.rhwp-cli;
  };
}
```

## Packages

| Package | Description |
| --- | --- |
| `rhwp-cli` | Native `rhwp` command-line application; also the default package |
| `rhwp-wasm` | Browser-targeted JavaScript, TypeScript, and WebAssembly bundle |
| `rhwp-studio` | Static Vite build of rhwp Studio |
| `formatter` | Repository formatter and lint suite |

Build a package explicitly:

```console
$ nix build github:mulatta/rhwp.nix#rhwp-cli
$ nix build github:mulatta/rhwp.nix#rhwp-wasm
$ nix build github:mulatta/rhwp.nix#rhwp-studio
```

The flake configures `https://cache.mulatta.io` as a binary substitute. Nix may ask you to confirm its substituter and public key when first using the flake.

## Development

Enter the development shell and format the repository:

```console
$ nix develop
$ nix fmt
```

Build an individual check instead of evaluating every package:

```console
$ nix build .#checks.x86_64-linux.package-rhwp-cli
```

Replace `x86_64-linux` with your current supported system when needed.

Upstream source metadata is pinned in [`packages/source/pin.json`](packages/source/pin.json). The scheduled [source update workflow](.github/workflows/update-rhwp-source.yml) checks upstream releases and opens pull requests containing updated source and dependency hashes.

## Contributing

Contributions are welcome. Before opening a pull request:

1. Enter the development shell with `nix develop`.
2. Make focused changes and update relevant package metadata when needed.
3. Format the repository with `nix fmt`.
4. Build the affected package or check on a supported system.

For example:

```console
$ nix fmt
$ nix build .#checks.x86_64-linux.package-rhwp-cli
```

When updating the packaged rhwp version, use the source updater instead of editing generated hashes manually:

```console
$ nix develop -c ./packages/source/update.py --ref <tag-or-full-commit>
```

Consider opening an issue before making broad packaging or repository-structure changes.

## License

Nix packaging code in this repository is available under the [MIT License](LICENSE), copyright Seungwon Lee.

Packaged rhwp sources are distributed under the [upstream MIT license](https://github.com/edwardkim/rhwp/blob/main/LICENSE).
