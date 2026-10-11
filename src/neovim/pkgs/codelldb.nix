# CodeLLDB's debug adapter from the upstream release, with the LLDB it bundles.
# nixpkgs' vscode-lldb links the Nix lldb (19.x), which, like lldb 21, crashes
# parsing macOS 27's dyld shared cache; upstream ships a newer LLDB (22.x).
# Binaries are prebuilt, so Linux needs its ELF interpreter/RPATHs patched.
{
  lib,
  stdenv,
  fetchurl,
  unzip,
  autoPatchelfHook,
  zlib,
  libxml2,
  ncurses,
}: let
  version = "1.12.3";
  assets = {
    aarch64-darwin = {
      name = "darwin-arm64";
      hash = "sha256-LxFKmQ4bNo3R29M8gMDnGXZ68tIoOR7A3wVxyVf5rJE=";
    };
    x86_64-linux = {
      name = "linux-x64";
      hash = "sha256-HNfzhlmAIrUaW5O5/6I+gSsj9RnP4YMzhOxL70v9G+E=";
    };
    aarch64-linux = {
      name = "linux-arm64";
      hash = "sha256-CIf2fUQFVGF4lCZvgHBrcAkHw2uV5uSdI7laDgUxgQE=";
    };
  };
  asset = assets.${stdenv.hostPlatform.system} or (throw "codelldb: unsupported system ${stdenv.hostPlatform.system}");
in
  stdenv.mkDerivation {
    pname = "codelldb";
    inherit version;

    src = fetchurl {
      url = "https://github.com/vadimcn/codelldb/releases/download/v${version}/codelldb-${asset.name}.vsix";
      inherit (asset) hash;
    };

    nativeBuildInputs = [unzip] ++ lib.optionals stdenv.hostPlatform.isLinux [autoPatchelfHook];
    buildInputs = lib.optionals stdenv.hostPlatform.isLinux [stdenv.cc.cc.lib zlib libxml2 ncurses];
    # liblldb dlopens libpython for its scripting bridge; CodeLLDB's Rust
    # formatters work without it.
    autoPatchelfIgnoreMissingDeps = ["libpython*"];

    unpackPhase = "unzip -q $src 'extension/*'";
    dontConfigure = true;
    dontBuild = true;
    # Upstream signs the macOS binaries; stripping would invalidate them.
    dontStrip = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/codelldb $out/bin
      # Keep the extension layout: the adapter finds bin/codelldb-launch (the
      # integrated-terminal helper) and lldb/lib (liblldb, libpython, Python
      # modules) relative to itself.
      cp -r extension/adapter extension/bin extension/lldb extension/package.json $out/share/codelldb/
      chmod +x $out/share/codelldb/adapter/codelldb $out/share/codelldb/bin/* $out/share/codelldb/lldb/bin/*
      # A wrapper, not a symlink: the adapter resolves its siblings from the
      # path it was started by, which on macOS doesn't follow symlinks.
      printf '#!/bin/sh\nexec %s "$@"\n' "$out/share/codelldb/adapter/codelldb" > $out/bin/codelldb
      chmod +x $out/bin/codelldb
      runHook postInstall
    '';

    passthru = {
      adapter = "share/codelldb/adapter/codelldb";
      liblldb = "share/codelldb/lldb/lib/liblldb${stdenv.hostPlatform.extensions.sharedLibrary}";
    };

    meta = {
      description = "Native debugger adapter based on LLDB (CodeLLDB)";
      homepage = "https://github.com/vadimcn/codelldb";
      license = lib.licenses.mit;
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
      platforms = builtins.attrNames assets;
      mainProgram = "codelldb";
    };
  }
