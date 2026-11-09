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
    # Docs, PDFs and verifier corpora are ~90% of the archive; keep the docs src embeds.
    postFetch = ''
      keep=$(mktemp -d)
      { grep -rhoE '"[^"]*mydocs/[^"]+"' $out/src || true; } | sed -E 's|.*mydocs/||; s|"$||' | sort -u |
        while read -r doc; do
          if [ -f "$out/mydocs/$doc" ]; then
            mkdir -p "$keep/$(dirname "$doc")"
            cp "$out/mydocs/$doc" "$keep/$doc"
          fi
        done
      rm -rf $out/mydocs $out/pdf
      mv "$keep" $out/mydocs
      find $out/tools/llm_verifier -mindepth 2 -maxdepth 2 -type d \
        \( -name corpus -o -name fixtures \) -exec rm -rf {} +
    '';
  };
in
{
  inherit src;
  inherit (data) version cargoHash wasmBindgenVersion;
}
