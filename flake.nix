{
  description = "zig flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    # included for `default.nix`/`shell.nix`/`nix-build`/`nix-shell` support
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    zig = {
      url = "github:ziglang/zig";
      flake = false;
    };
  };

  outputs = { self, zig, nixpkgs, flake-utils, flake-compat }:
    flake-utils.lib.eachDefaultSystem (system:
    let 
      pkgs = nixpkgs.legacyPackages.${system};
      llvmPackages = pkgs.llvmPackages_13;
      apple_sdk = pkgs.callPackage (nixpkgs + "/pkgs/os-specific/darwin/apple-sdk-11.0") { };
    in rec {
        defaultPackage = 
          pkgs.stdenv.mkDerivation {
            name = "zig";
            nativeBuildInputs = [ pkgs.cmake ];
            buildInputs = [
              llvmPackages.libllvm llvmPackages.lld llvmPackages.libclang
            ] ++ nixpkgs.lib.optionals pkgs.stdenv.isDarwin [
              apple_sdk.Libsystem
            ];
            src = zig;
          };
        }
    );
}
