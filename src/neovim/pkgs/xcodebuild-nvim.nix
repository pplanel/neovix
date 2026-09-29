# Xcode project workflow (build, run, test, simulators, debugging) for Neovim;
# not packaged in nixpkgs.
{
  lib,
  vimUtils,
  fetchFromGitHub,
  vimPlugins,
}:
vimUtils.buildVimPlugin rec {
  pname = "xcodebuild.nvim";
  version = "7.3.0";

  src = fetchFromGitHub {
    owner = "wojciech-kulik";
    repo = "xcodebuild.nvim";
    rev = "v${version}";
    hash = "sha256-83TvWtLaHrYGvbdu4P7AwJ8/NeOiCrIW4Qa9bj/kMY4=";
  };

  dependencies = with vimPlugins; [nui-nvim nvim-dap];

  # Optional picker integrations. neovix uses snacks, which is installed
  # alongside at runtime but isn't part of this build's require check.
  nvimSkipModules = [
    "xcodebuild.integrations.fzf-lua"
    "xcodebuild.integrations.telescope-nvim"
    "xcodebuild.integrations.snacks-picker"
  ];

  meta = {
    description = "Neovim plugin to build, debug, and test applications created with Xcode";
    homepage = "https://github.com/wojciech-kulik/xcodebuild.nvim";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
  };
}
