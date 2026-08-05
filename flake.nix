{
  description = "rhwp-nix";

  nixConfig = {
    allow-import-from-derivation = false;
    extra-substituters = [ "https://cache.mulatta.io" ];
    extra-trusted-public-keys = [ "cache.mulatta.io-1:DrV+Oy2azNyVKM7ihhD1QoOetRUnW+1G6RWToUpSO4U=" ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
    rust-overlay.url = "github:oxalica/rust-overlay";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      rust-overlay,
      ...
    }:
    let
      inherit (nixpkgs) lib;

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      eachSystem = lib.genAttrs systems;

      pkgsFor = eachSystem (
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ rust-overlay.overlays.default ];
        }
      );

      packageNames = builtins.attrNames (
        lib.filterAttrs (
          name: type: type == "directory" && builtins.pathExists (./packages + "/${name}/package.nix")
        ) (builtins.readDir ./packages)
      );

      mkPackagesFor =
        pkgs:
        let
          scope = lib.makeScope pkgs.newScope (
            self:
            {
              inherit inputs lib;
              flake = self;

              source = self.callPackage ./packages/source { };
              inherit (self.source) version cargoHash wasmBindgenVersion;
              rhwpSrc = self.source.src;
              wasm-bindgen-cli = self.callPackage ./packages/wasm-bindgen-cli { };
            }
            // lib.genAttrs packageNames (name: self.callPackage (./packages + "/${name}/package.nix") { })
          );
        in
        lib.filterAttrs (_name: lib.isDerivation) (lib.genAttrs packageNames (name: scope.${name}));

      packages = eachSystem (
        system:
        let
          packages = mkPackagesFor pkgsFor.${system};
        in
        packages // { default = packages.rhwp-cli; }
      );
    in
    {
      inherit packages;

      checks = eachSystem (
        system:
        lib.mapAttrs' (name: package: lib.nameValuePair "package-${name}" package) packages.${system}
      );

      devShells = eachSystem (system: {
        default = import ./devshell.nix {
          pkgs = pkgsFor.${system};
          formatter = packages.${system}.formatter;
        };
      });

      formatter = eachSystem (system: packages.${system}.formatter);
    };
}
