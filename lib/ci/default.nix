# nix eval .#lib.ci --impure

{
  nixpkgs,
  file,
  ...
}:
let
  inherit (nixpkgs) lib;
  CI = {
    name = "CI";
    env = [ "CI" ];
  };

  ciFiles = lib.filter (x: !(lib.hasSuffix "default.nix" x)) (file.getNixFiles ./.);
  allCI = (file.importLists' ciFiles) ++ [ CI ];

  # determine if a CI is detected
  isDetected = ci: lib.any (env: builtins.getEnv env != "") ci.env;

  # return the first detected
  infoCI = lib.findFirst isDetected { } allCI;
  inCI = infoCI != { };
in
{
  /**
    List of all supported CI environment configurations.

    # Type
    ```
    allCI :: [{ name: string, env: [string] }]
    ```

    # Example
    ```nix
    allCI
    # => [ { name = "GitHub Actions"; env = [ "GITHUB_ACTIONS" ]; } ... ]
    ```
  */
  inherit allCI;

  /**
    Boolean indicating if the current environment is a detected CI.

    # Type
    ```
    inCI :: bool
    ```

    # Example
    ```nix
    inCI
    # => true # if GITHUB_ACTIONS is set
    ```
  */
  inherit inCI;

  /**
    Information about the detected CI environment.
     Returns an empty attribute set if no CI is detected.

    # Type
    ```
    infoCI :: { name: string, env: [string] } | {}
    ```

    # Example
    ```nix
    infoCI
    # => { name = "GitHub Actions"; env = [ "GITHUB_ACTIONS" ]; }
    ```
  */
  inherit infoCI;

  /**
    Indicates that the current environment is NOT a CI.

    # Type
    ```
    notInCI :: bool
    ```

    # Example
    ```nix
    notInCI
    # => false # if in a CI environment
    ```
  */
  notInCI = !inCI;

  /**
    Check if a given CI configuration is detected in the current environment.

    # Type
    ```
    isDetected :: { env: [string] } -> bool
    ```

    # Example
    ```nix
    isDetected { env = ["GITHUB_ACTIONS"]; }
    # => true # if GITHUB_ACTIONS env var is set
    ```
  */
  isDetected = ci: isDetected ci;
}
