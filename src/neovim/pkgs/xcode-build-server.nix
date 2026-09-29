# Build Server Protocol bridge that lets sourcekit-lsp understand .xcodeproj /
# .xcworkspace projects; not packaged in nixpkgs. Pure-stdlib Python.
{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  makeWrapper,
  python3,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "xcode-build-server";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "SolaWing";
    repo = "xcode-build-server";
    rev = "v${finalAttrs.version}";
    hash = "sha256-AUGDoMeW/FSMJLG7uR580cMpytYQBFV2PXE3LBNaiFQ=";
  };

  nativeBuildInputs = [makeWrapper];

  # `config` records its own path in each project's buildServer.json. A Nix
  # store path would dangle after an upgrade + GC, so let the caller supply a
  # stable path instead (neovix maintains a symlink, see plugins/swift.lua).
  postPatch = ''
    substituteInPlace config/config.py \
      --replace-fail '"argv": [sys.argv[0]]' \
                     '"argv": [os.environ.get("XCODE_BUILD_SERVER_ARGV0") or sys.argv[0]]'
  '';

  # The entrypoint imports its sibling modules, so keep the tree together
  # and expose it through a wrapper rather than a bare symlink.
  installPhase = ''
    runHook preInstall
    mkdir -p $out/libexec/xcode-build-server $out/bin
    cp -r ./* $out/libexec/xcode-build-server/
    makeWrapper ${python3.interpreter} $out/bin/xcode-build-server \
      --add-flags $out/libexec/xcode-build-server/xcode-build-server
    runHook postInstall
  '';

  meta = {
    description = "Build server protocol implementation for Xcode projects (for sourcekit-lsp)";
    homepage = "https://github.com/SolaWing/xcode-build-server";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
    mainProgram = "xcode-build-server";
  };
})
