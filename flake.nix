{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: (
    flake-utils.lib.eachSystem 
    (with flake-utils.lib.system; [
      x86_64-linux
      aarch64-linux
    ]) 
    (system: {
      packages.camera-streamer = nixpkgs.legacyPackages."${system}".callPackage ./default.nix {};
      packages.default = self.packages."${system}".camera-streamer;
    })
  );
}
