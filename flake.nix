{
  description = "Flake Lib";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    systems.url = "path:./systems";
  };

  outputs = inputs: {
    lib = import ./lib {
      pkgs = inputs.nixpkgs;
      systems = import inputs.systems;
    };
  };
}
