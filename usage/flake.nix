{
  description = "flake-lib forSystem Usage";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";

    flake-lib = {
      url = "github:xj11400/flake-lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  /**
    * Generate the system-based outputs with three different methods
    * - forAllSystems
    * - forEachSupportedSystem
    * - forEachSystem
    *
    * If want specific system, use the prime functions.
    * systems = [ ... ];
    * - forAllSystems' { inherit systems; }
    * - forEachSupportedSystem' { inherit nixpkgs systems; }
    * - forEachSystem' { inherit systems; }
  */
  outputs =
    {
      self,
      flake-lib,
      nixpkgs,
      ...
    }:
    {
      # Create formatter with forAllSystems
      formatter = flake-lib.lib.system.forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);

      # Create packages with forEachSupportedSystem
      #  forEachSupportedSystem' { inherit nixpkgs; systems = [ "x86_64-linux" ]; }
      packages = flake-lib.lib.system.forEachSupportedSystem { inherit nixpkgs; } (
        { pkgs, system }:
        let
        in
        {
          hello = pkgs.hello;
        }
      );
    }
    # Create devShells with forEachSystem
    // flake-lib.lib.system.forEachSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells = {
          hello = pkgs.mkShell {
            buildInputs = with pkgs; [
              hello
            ];
            shellHook = ''
              hello
              echo "Welcome to ${system}"
            '';
          };
        };
      }
    );
}
