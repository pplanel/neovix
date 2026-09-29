# Top-level flake output aggregator.
#
# Per-system outputs are assembled from the sibling directories; system-agnostic
# outputs (overlays) are merged in at the end.
{
  nixpkgs,
  flake-utils,
  ...
}: let
  # nixpkgs-unstable dropped x86_64-darwin (26.11), so it is not offered here.
  systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];

  perSystem = system: let
    pkgs = import nixpkgs {
      inherit system;
      # packer (HashiCorp, BSL) is the only unfree tool; allow it by name
      # rather than opening the door to everything.
      config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) ["packer"];
    };
    packages = import ./packages {inherit pkgs;};
  in {
    inherit packages;
    apps = import ./apps {inherit packages;};
    devShells = import ./devShells {inherit pkgs packages;};
    formatter = pkgs.alejandra;
  };
in
  flake-utils.lib.eachSystem systems perSystem
  // {
    overlays = import ./overlays;
  }
