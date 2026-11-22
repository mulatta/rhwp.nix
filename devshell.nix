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
    # nixpkgs ships 1.16.0, whose --flake mode breaks on Nix 2.35 (Mic92/nix-update#693)
    (pkgs.nix-update.overridePythonAttrs (_: {
      version = "1.17.0";
      src = pkgs.fetchFromGitHub {
        owner = "Mic92";
        repo = "nix-update";
        tag = "v1.17.0";
        hash = "sha256-TCOhUWb53V3nrJRD3JuADly1U9fNi0Z79QMcjhbefHg=";
      };
      build-system = [ pkgs.python3Packages.hatchling ];
      dependencies = [ pkgs.python3Packages.ast-grep-py ];
    }))

    # Formatter and Nix linters
    formatter
  ];
}
