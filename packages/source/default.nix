{
  fetchFromGitHub,
  lib,
}:

let
  data = lib.importJSON ./pin.json;
  src = fetchFromGitHub {
    owner = "edwardkim";
    repo = "rhwp";
    inherit (data) rev hash;
  };
in
{
  inherit src;
  inherit (data) version cargoHash wasmBindgenVersion;
}
