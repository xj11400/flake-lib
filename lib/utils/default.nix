{
  nixpkgs,
  ...
}:
let
  inherit (nixpkgs) lib;
in
rec {
  archs = [
    "x86_64"
    "aarch64"
  ];

  defaultLinux = [
    # "i686-linux"
    "x86_64-linux"
    "aarch64-linux"
  ];

  defaultDarwin = [
    "x86_64-darwin"
    "aarch64-darwin"
  ];

  /**
    Filter an attribute set, keeping only attributes whose names start with any of the given prefixes.

    # Type
    ```
    filterAttrsByPrefixes :: attrset -> [string] -> attrset
    ```
  */
  filterAttrsByPrefixes =
    attrset: prefixes:
    lib.filterAttrs (name: value: builtins.any (prefix: lib.hasPrefix prefix name) prefixes) attrset;

  /**
    Detect the platform type ("darwin" or "linux") from a system string.
    Throws an error if the system is unsupported.

    # Type
    ```
    platformIs :: string -> string
    ```
  */
  platformIs =
    system:
    if builtins.match ".*darwin.*" system != null then
      "darwin"
    else if builtins.match ".*linux.*" system != null then
      "linux"
    else
      throw "Unsupported system: ${system}";

  /**
    Parse a Nix system string (e.g., "x86_64-linux") into its architecture and platform components.

    # Type
    ```
    parseSystemString :: string -> { arch: string, platform: string }
    ```
  */
  parseSystemString =
    systemString:
    let
      parts = builtins.split "-" systemString;
      arch = builtins.elemAt parts 0;
      platform = builtins.elemAt parts 2;
    in
    {
      inherit arch platform;
    };

  /**
    Filter an attribute set to include only Linux systems.

    # Type
    ```
    filterLinux :: attrset -> attrset
    ```
  */
  filterLinux = attrset: filterAttrsByPrefixes attrset defaultLinux;

  /**
    Filter an attribute set to include only Darwin (macOS) systems.

    # Type
    ```
    filterDarwin :: attrset -> attrset
    ```
  */
  filterDarwin = attrset: filterAttrsByPrefixes attrset defaultDarwin;
}
