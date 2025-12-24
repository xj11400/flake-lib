{
  description = "Flake Lib";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
  };

  outputs = inputs: {
    lib = import ./lib {
      inherit (inputs) nixpkgs;
      systems = import ./systems;
    };
  };
}
