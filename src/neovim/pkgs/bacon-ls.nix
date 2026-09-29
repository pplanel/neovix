# Language server that surfaces `bacon` diagnostics; not packaged in nixpkgs.
{
  lib,
  rustPlatform,
  fetchCrate,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "bacon-ls";
  version = "0.31.0";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-gITBqCZTEag3KY6qiw1rSaRR0Kk7toEnBs012Hpj8dY=";
  };

  cargoHash = "sha256-R/VA0PEQyO67LxmqZC05yOyATraD51clOddqnChtS8E=";

  # The test suite shells out to cargo/bacon on a real project.
  doCheck = false;

  meta = {
    description = "Rust diagnostics language server powered by bacon";
    homepage = "https://github.com/crisidev/bacon-ls";
    license = lib.licenses.mit;
    mainProgram = "bacon-ls";
  };
})
