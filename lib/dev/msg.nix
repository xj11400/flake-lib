{ nixpkgs }:
rec {
  /**
    Generates a shell script snippet to echo a title and list of loaded packages.

    # Type
    ```
    pkgs_loadded :: [Derivation] -> { title :: String } -> String
    ```

    # Example
    ```nix
    lib.msg.pkgs_loadded [ pkgs.hello ] { title = "My packages:"; }
    ```
  */
  pkgs_loadded =
    shellPkgs:
    {
      title ? "Loadded pkgs:",
    }:
    ''
      echo "${title}"
      ${pkgs_list shellPkgs}
    '';

  /**
    Generates a shell script snippet to echo each package in the list.

    # Type
    ```
    pkgs_list :: [Derivation] -> String
    ```

    # Example
    ```nix
    lib.msg.pkgs_list [ pkgs.hello ]
    ```
  */
  pkgs_list = shellPkgs: ''
    ${nixpkgs.lib.concatMapStringsSep "\n" (
      pkg: ''echo "  - ${pkg.pname or pkg.name or "unknown"} (${pkg.version or "unknown"})"''
    ) shellPkgs}
  '';

  /**
    Generates a welcome message for a template.

    # Type
    ```
    welcome :: { name :: String, info :: String } -> String
    ```

    # Example
    ```nix
    lib.msg.welcome { name = "rust"; info = "Happy coding!"; }
    ```
  */
  welcome =
    { name, info }:
    ''
      # This is a ${name} template from xj11400/dev-flake

      ${info}
    '';
}
