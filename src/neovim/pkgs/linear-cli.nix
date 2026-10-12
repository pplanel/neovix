# Linear's CLI (`linear`); not packaged in nixpkgs. The GroundControl dashboard
# queries Linear through `linear api`, so the API key stays in the macOS Keychain
# (`linear auth login`) instead of an environment variable or a file.
{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "linear-cli";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "schpet";
    repo = "linear-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jTQeOx78GuclgLiXccOy6smdrGTEfydm4HD+/luOlFM=";
  };

  cargoHash = "sha256-ItoCHuZ1maJ8n2MagqR8x3ch6mbPplDYipRJ/jtgEGQ=";

  # The workspace also has linear-schema and an xtask; build only the CLI.
  cargoBuildFlags = ["--package" "linear"];
  cargoTestFlags = ["--package" "linear"];

  meta = {
    description = "Linear from the command line";
    homepage = "https://github.com/schpet/linear-cli";
    license = lib.licenses.isc;
    mainProgram = "linear";
  };
})
