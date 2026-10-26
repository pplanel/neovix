{
  lib,
  vimUtils,
  fetchFromGitHub,
}:
(vimUtils.buildVimPlugin {
  pname = "codecompanion-nvim";
  version = "v20.0.1";

  src = fetchFromGitHub {
    owner = "olimarris";
    repo = "codecompanion.nvim";
    rev = "20.0.1";
    hash = "sha256-iljMf2rdCqNy1eSbJ9GS0TDQsi2V16Wureckb/MhTkw";
  };

  meta = {
    description = "✨ AI Coding, Vim Styl";
    homepage = "https://github.com/olimorris/codecompanion.nvim";
    license = lib.licenses.cc0;
  };
}).overrideAttrs (oldAttrs: {
  doCheck = false;
})
