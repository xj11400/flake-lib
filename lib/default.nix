{
  pkgs,
  systems,
  ...
}:
let
in
rec {
  system = import ./system { systems = systems; };
  file = import ./file { inherit pkgs; };
  utils = import ./utils { inherit pkgs; };
  ci = import ./ci { inherit pkgs file; };
}
