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
    # Docs, PDFs and verifier corpora are ~90% of the tree; the sparse checkout never fetches them.
    nonConeMode = true;
    sparseCheckout = [
      "/*"
      "!/mydocs/"
      "!/pdf/"
      "!/tools/llm_verifier/*/corpus/"
      "!/tools/llm_verifier/*/fixtures/"
    ]
    ++ map (doc: "/mydocs/${doc}") data.mydocs;
  };
in
{
  inherit src;
  inherit (data) version cargoHash wasmBindgenVersion;
}
