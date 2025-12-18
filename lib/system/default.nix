{
  systems ? [
    "x86_64-darwin"
    "aarch64-darwin"
    "x86_64-linux"
    "aarch64-linux"
  ],
}:
rec {

  /**
    The list of all platforms to support.
    If running with --impure, the current host system is automatically added
    if it's not already in the default 'systems' list.

    # Type
    ```
    allSystems :: [string]
    ```

    # Example
    ```nix
    allSystems
    # => [ "x86_64-darwin" "aarch64-darwin" "x86_64-linux" "aarch64-linux" ]
    ```
  */
  allSystems =
    if (builtins ? currentSystem && !(builtins.elem builtins.currentSystem systems)) then
      systems ++ [ builtins.currentSystem ]
    else
      systems;

  /**
    Generator function that maps a given function across the default platforms (`allSystems`).
    The function `f` should accept a system string and return an attribute set.

    # Type
    ```
    forAllSystems :: (string -> attrset) -> attrset
    ```

    # Example
    ```nix
    forAllSystems (system: { hello = "world from ${system}"; })
    # => {
    #   x86_64-darwin = { hello = "world from x86_64-darwin"; };
    #   aarch64-darwin = { hello = "world from aarch64-darwin"; };
    #   ...
    # }
    ```
  */
  forAllSystems = forAllSystems' { systems = allSystems; };

  /**
    Transposer function that maps across default platforms and regroups the results.
    It transforms `system -> { key = value }` into `key -> { system = value }`.

    # Type
    ```
    forEachSystem :: (string -> attrset) -> attrset
    ```

    # Example
    ```nix
    forEachSystem (system: { pkg = "some-pkg"; })
    # => { pkg = { x86_64-linux = "some-pkg"; aarch64-linux = "some-pkg"; ... }; }
    ```
  */
  forEachSystem =
    f:
    let
      results = forAllSystems f;

      allKeys = builtins.attrNames (builtins.foldl' (acc: sys: acc // results.${sys}) { } allSystems);
    in
    builtins.listToAttrs (
      map (key: {
        name = key;
        value = builtins.listToAttrs (
          map (system: {
            name = system;
            value = results.${system}.${key};
          }) (builtins.filter (s: builtins.hasAttr key results.${s}) allSystems)
        );
      }) allKeys
    );

  /**
    Helper function to generate an attribute set across default platforms,
    providing a pre-configured `pkgs` instance for each system.

    # Type
    ```
    forEachSupportedSystem :: { nixpkgs: path, config?: attrset, overlays?: [overlay] } -> ({ system, pkgs }: attrset) -> attrset
    ```

    # Example
    ```nix
    forEachSupportedSystem { inherit nixpkgs; } ({ system, pkgs }: {
      default = pkgs.hello;
    })
    # => { x86_64-linux = { default = <derivation hello>; }; ... }
    ```
  */
  forEachSupportedSystem =
    {
      nixpkgs,
      config ? { },
      overlays ? [ ],
    }:
    f:
    forAllSystems (
      system:
      f {
        inherit system;
        pkgs = import nixpkgs {
          inherit system config overlays;
        };
      }
    );

  /**
    Like `forAllSystems`, but allows specifying a custom list of systems.

    # Type
    ```
    forAllSystems' :: { systems?: [string] } -> (string -> attrset) -> attrset
    ```

    # Example
    ```nix
    forAllSystems' { systems = [ "x86_64-linux" ]; } (system: { hello = system; })
    # => { x86_64-linux = { hello = "x86_64-linux"; }; }
    ```
  */
  forAllSystems' =
    {
      systems ? allSystems,
    }:
    f:
    builtins.listToAttrs (
      map (s: {
        name = s;
        value = f s;
      }) systems
    );

  /**
    Like `forEachSystem`, but allows specifying a custom list of systems.

    # Type
    ```
    forEachSystem' :: { systems?: [string] } -> (string -> attrset) -> attrset
    ```

    # Example
    ```nix
    forEachSystem' { systems = [ "x86_64-linux" ]; } (system: { pkg = "foo"; })
    # => { pkg = { x86_64-linux = "foo"; }; }
    ```
  */
  forEachSystem' =
    {
      systems ? allSystems,
    }:
    f:
    let
      results = forAllSystems' { inherit systems; } f;

      allKeys = builtins.attrNames (builtins.foldl' (acc: sys: acc // results.${sys}) { } systems);
    in
    builtins.listToAttrs (
      map (key: {
        name = key;
        value = builtins.listToAttrs (
          map (system: {
            name = system;
            value = results.${system}.${key};
          }) (builtins.filter (s: builtins.hasAttr key results.${s}) systems)
        );
      }) allKeys
    );

  /**
    Like `forEachSupportedSystem`, but allows specifying a custom list of systems.

    # Type
    ```
    forEachSupportedSystem' :: { nixpkgs: path, config?: attrset, overlays?: [overlay], systems?: [string] } -> ({ system, pkgs }: attrset) -> attrset
    ```

    # Example
    ```nix
    forEachSupportedSystem' { inherit nixpkgs; systems = [ "x86_64-linux" ]; } ({ system, pkgs }: {
      default = pkgs.hello;
    })
    # => { x86_64-linux = { default = <derivation hello>; }; }
    ```
  */
  forEachSupportedSystem' =
    {
      nixpkgs,
      config ? { },
      overlays ? [ ],
      systems ? allSystems,
    }:
    f:
    forAllSystems' { inherit systems; } (
      system:
      f {
        inherit system;
        pkgs = import nixpkgs {
          inherit system config overlays;
        };
      }
    );
}
