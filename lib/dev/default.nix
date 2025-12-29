{
  nixpkgs,
  file,
  ...
}:
rec {
  msg = import ./msg.nix { inherit nixpkgs; };
  load = import ./load.nix { inherit nixpkgs file msg; };

  /**
    Retrieves packages and devShells for a specific system and target.

    # Type
    ```
    use :: attrset -> String -> String -> { packages :: Derivation, devShells :: Derivation }
    ```

    # Example
    ```nix
    lib.use self "x86_64-linux" "rust"
    # => {
    #      packages = << Derivation >>;
    #      devShell = << Derivation >>;
    #    };
    ```
  */
  use = outputs: system: target: {
    packages = outputs.packages.${system}.${target};
    devShells = outputs.devShells.${system}.${target};
  };
}
