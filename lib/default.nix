{
  nixpkgs,
  systems,
  ...
}:
let
in
rec {
  system = import ./system { systems = systems; };
  file = import ./file { inherit nixpkgs; };
  utils = import ./utils { inherit nixpkgs; };
  ci = import ./ci { inherit nixpkgs file; };
  dev = import ./dev { inherit nixpkgs file; };
}
