{
  nixpkgs,
  ...
}:
let
  inherit (nixpkgs) lib;
in
rec {
  /**
    List all entries under a directory.

    # Type
    ```
    lsDir :: path -> [string]
    ```

    # Example
    ```nix
    lsDir ./src
    # => [ "default.nix" "utils.nix" ]
    ```
  */
  lsDir = dir: builtins.attrNames (builtins.readDir dir);

  /**
    Get all directory names in a directory.

    # Type
    ```
    getDirs' :: path -> [string]
    ```

    # Example
    ```nix
    getDirs' ./modules
    # => [ "core" "services" ]
    ```
  */
  getDirs' =
    dir:
    let
      entries = builtins.readDir dir;
    in
    lib.attrNames (lib.filterAttrs (n: v: v == "directory") entries);

  /**
    Get all directories in a directory as full paths.

    # Type
    ```
    getDirs :: path -> [path]
    ```

    # Example
    ```nix
    getDirs ./modules
    # => [ /path/to/modules/core /path/to/modules/services ]
    ```
  */
  getDirs =
    dir:
    let
      dirs = getDirs' dir;
    in
    map (name: dir + "/${name}") dirs;

  /**
    Get all .nix file names in a directory.

    # Type
    ```
    getNixFiles' :: path -> [string]
    ```

    # Example
    ```nix
    getNixFiles' ./src
    # => [ "default.nix" "utils.nix" ]
    ```
  */
  getNixFiles' =
    dir:
    let
      entries = builtins.readDir dir;
    in
    builtins.filter (name: lib.hasSuffix ".nix" name) (builtins.attrNames entries);

  /**
    Get all .nix files in a directory as full paths.

    # Type
    ```
    getNixFiles :: path -> [path]
    ```

    # Example
    ```nix
    getNixFiles ./src
    # => [ /path/to/src/default.nix /path/to/src/utils.nix ]
    ```
  */
  getNixFiles =
    dir:
    let
      nixFiles = getNixFiles' dir;
    in
    map (name: dir + "/${name}") nixFiles;

  /**
    Import a path if it exists, otherwise return an empty attribute set.

    # Type
    ```
    importSafe :: path -> any
    ```

    # Example
    ```nix
    importSafe ./optional-config.nix
    # => { ... } # if file exists
    # => { }     # if file does not exist
    ```
  */
  importSafe = path: if builtins.pathExists path then import path else { };

  /**
    Check if a given path is a directory.

    # Type
    ```
    isDirectory :: path -> bool
    ```

    # Example
    ```nix
    isDirectory ./modules
    # => true
    ```
  */
  isDirectory = path: (builtins.readFileType (toString path)) == "directory";

  /**
    Recursively find all .nix files from a list of paths.
     If a path is a directory, it finds .nix files directly inside it.

    # Type
    ```
    flattenPaths :: [path] -> [path]
    ```

    # Example
    ```nix
    flattenPaths [ ./file.nix ./dir ]
    # => [ ./file.nix ./dir/a.nix ./dir/b.nix ]
    ```
  */
  flattenPaths =
    paths:
    builtins.concatLists (map (path: if isDirectory path then getNixFiles path else [ path ]) paths);

  /**
    Determine what to import from a path.
    - If it's a file, it's treated as a single import.
    - If it's a directory with 'default.nix', it's treated as a single import (Nix standard).
    - If it's a directory without 'default.nix', it returns a list of .nix files inside.

    # Type
    ```
    resolvePath :: path -> { type: string, value: any }
    ```

    # Example
    ```nix
    resolvePath ./dir-with-default
    # => { type = "single"; value = ./dir-with-default; }

    resolvePath ./dir-without-default
    # => { type = "directory"; value = [ ./dir-without-default/a.nix ... ]; }
    ```
  */
  resolvePath =
    path:
    let
      pathStr = toString path;
      isDir = (builtins.readFileType pathStr) == "directory";
      hasDefault = isDir && (builtins.pathExists (path + "/default.nix"));
    in
    if !isDir || hasDefault then
      {
        type = "single";
        value = path;
      }
    else
      {
        type = "directory";
        value = getNixFiles path;
      };

  /**
    Import files/directories and merge their contents as lists.
    Does not pass any arguments to the imported files.

    # Type
    ```
    importLists' :: [path] -> [any]
    ```

    # Example
    ```nix
    importLists' ["./list1.nix" "./dir"]
    # => [ "item1" "item2" "item3" ]
    ```
  */
  importLists' =
    paths:
    let
      processed = map resolvePath paths;

      allFiles = builtins.concatLists (
        map (p: if p.type == "directory" then p.value else [ p.value ]) processed
      );

      importedLists = map (
        file:
        let
          content = import file;
        in

        # If it returns a single item (attrset/string/etc), wrap it in a list.
        if builtins.isList content then content else [ content ]
      ) allFiles;
    in
    builtins.concatLists importedLists;

  /**
    Import files/directories and merge their contents as lists, passing 'args' to each.

    # Type
    ```
    importLists :: [path] -> attrset -> [any]
    ```

    # Example
    ```nix
    importLists ["./list1.nix" "./dir"] { inherit pkgs; }
    # => [ { name = "item1"; ... } ... ]
    ```
  */
  importLists =
    paths: args:
    let
      processed = map resolvePath paths;

      allFiles = builtins.concatLists (
        map (p: if p.type == "directory" then p.value else [ p.value ]) processed
      );

      importedLists = map (
        file:
        let
          content = import file args;
        in

        # If it returns a single item (attrset/string/etc), wrap it in a list.
        if builtins.isList content then content else [ content ]
      ) allFiles;
    in
    builtins.concatLists importedLists;

  /**
    Import files/directories and merge everything into one flat attribute set.
    Passing 'args' to each import. Non-attrset contents are wrapped in an attrset
    with the filename (minus .nix) as the key.

    # Type
    ```
    importAll :: [path] -> attrset -> attrset
    ```

    # Example
    ```nix
    importAll ["./set1.nix" "./file.nix"] { inherit pkgs; }
    # => { key1 = "val1"; file = "content"; }
    ```
  */
  importAll =
    paths: args:
    let
      processed = map resolvePath paths;
      allFiles = builtins.concatLists (
        map (p: if p.type == "directory" then p.value else [ p.value ]) processed
      );

      safeMerge =
        acc: file:
        let
          content = import file args;
          # If content is a set, merge it directly.
          # If not (string, list, derivation), wrap it in its filename.
          valueToMerge =
            if builtins.isAttrs content && !(lib.isDerivation content) then
              content
            else
              { "${lib.removeSuffix ".nix" (builtins.baseNameOf (toString file))}" = content; };
        in
        lib.recursiveUpdate acc valueToMerge;
    in
    lib.foldl' safeMerge { } allFiles;

  /**
    Import files and directories, preserving structure by wrapping directory
    contents in an attribute set named after the directory.

    # Type
    ```
    importFiles :: [path] -> attrset -> attrset
    ```

    # Example
    ```nix
    importFiles ["./file1.nix" "./dir"] { inherit pkgs; }
    # => { file1 = { ... }; dir = { a = { ... }; b = { ... }; }; }
    ```
  */
  importFiles =
    paths: args:
    let
      toKey = p: lib.removeSuffix ".nix" (builtins.baseNameOf (toString p));

      processEntry =
        path:
        let
          res = resolvePath path;
        in
        if res.type == "single" then
          {
            name = toKey res.value;
            value = import res.value args;
          }
        else
          {
            name = toKey path;
            value = builtins.listToAttrs (
              map (f: {
                name = toKey f;
                value = import f args;
              }) res.value
            );
          };
    in
    builtins.listToAttrs (map processEntry paths);

  /**
    Similar to importAll, but does not perform 'default.nix' resolution for directories.
    Instead, it flattens all .nix files found in the provided paths.

    # Type
    ```
    importAll' :: [path] -> attrset -> attrset
    ```

    # Example
    ```nix
    importAll' ["./file1.nix" "./dir"] { inherit pkgs; }
    # => { ... } # Flattens all .nix files in ./dir
    ```
  */
  importAll' =
    paths: args:
    let
      allFiles = flattenPaths paths;

      toKey = file: lib.removeSuffix ".nix" (builtins.baseNameOf (toString file));

      safeMerge =
        acc: file:
        let
          content = import file args;
          isMergeable = builtins.isAttrs content && !(lib.isDerivation content);
          valueToMerge = if isMergeable then content else { "${toKey file}" = content; };
        in
        lib.recursiveUpdate acc valueToMerge;
    in
    lib.foldl' safeMerge { } allFiles;

  /**
    Similar to importFiles, but does not perform 'default.nix' resolution.
    Directly imports files or directory contents (names from getNixFiles).

    # Type
    ```
    importFiles' :: [path] -> attrset -> attrset
    ```

    # Example
    ```nix
    importFiles' ["./file1.nix" "./dir"] { inherit pkgs; }
    # => { file1 = { ... }; dir = { a = { ... }; b = { ... }; }; }
    ```
  */
  importFiles' =
    paths: args:
    let
      toKey = p: lib.removeSuffix ".nix" (builtins.baseNameOf (toString p));

      processPath =
        path:
        let
          isDir = (builtins.readFileType (toString path)) == "directory";
        in
        if isDir then
          {
            name = toKey path;
            value = builtins.listToAttrs (
              map (file: {
                name = toKey file;
                value = import file args;
              }) (getNixFiles path)
            );
          }
        else
          {
            name = toKey path;
            value = import path args;
          };

      listToMerge = map processPath paths;
    in
    builtins.listToAttrs listToMerge;
}
