{ pkgs, formatter }:

pkgs.mkShellNoCC {
  packages = [
    # Repository maintenance
    pkgs.bash
    pkgs.coreutils
    pkgs.gh
    pkgs.git
    pkgs.python3

    # Nix update tooling
    pkgs.nix
    pkgs.nix-update

    # Formatter and Nix linters
    formatter
  ];
}
