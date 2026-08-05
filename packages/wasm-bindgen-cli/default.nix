{
  buildWasmBindgenCli,
  fetchCrate,
  rustPlatform,
  wasmBindgenVersion,
}:
let
  # Must match rhwp's wasm-bindgen crate version.
  version = wasmBindgenVersion;

  src = fetchCrate {
    pname = "wasm-bindgen-cli";
    inherit version;
    hash = "sha256-zRawtjxMOdTMX+mZaiNR3YYfTiZJhf9qj7kXSSeMxrc=";
  };
in
buildWasmBindgenCli {
  inherit src;
  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    inherit (src) pname version;
    hash = "sha256-aZCfgR23Qb0Pn4Mm4ToMtuuRQqSJjXCR9li/VvP5CTM=";
  };
}
