{
  lib,
  binaryen,
  cargoHash,
  rhwpSrc,
  rust-bin,
  rustPlatform,
  version,
  wasm-bindgen-cli,
}:
let
  rustToolchain = rust-bin.stable.latest.default.override {
    targets = [ "wasm32-unknown-unknown" ];
  };
in
rustPlatform.buildRustPackage {
  pname = "rhwp-wasm";
  inherit version;
  src = rhwpSrc;

  inherit cargoHash;

  nativeBuildInputs = [
    rustToolchain
    wasm-bindgen-cli
    binaryen
  ];

  doCheck = false;

  # Avoid wasm-pack's bundled wasm-bindgen.
  buildPhase = ''
    runHook preBuild
    cargo build \
      --release \
      --lib \
      --target wasm32-unknown-unknown \
      --offline \
      --locked
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    wasm-bindgen \
      target/wasm32-unknown-unknown/release/rhwp.wasm \
      --out-dir $out \
      --target web \
      --typescript
    wasm-opt -Oz -o $out/rhwp_bg.wasm $out/rhwp_bg.wasm
    runHook postInstall
  '';

  # Internal updater target.
  passthru.wasm-bindgen-cli = wasm-bindgen-cli;

  meta = {
    description = "rhwp WASM bundle (rhwp.js + rhwp_bg.wasm)";
    license = lib.licenses.mit;
  };
}
