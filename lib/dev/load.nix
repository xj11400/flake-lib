{
  nixpkgs,
  file,
  msg,
}:
rec {
  /**
    Loads templates from subdirectories of a given path.

    # Type
    ```
    templates :: Path -> { info :: String } -> Attrs
    ```

    # Example
    ```nix
    lib.load.templates ./templates { info = "v1.0"; }
    ```
  */
  templates =
    path: args:
    let
      info = args.info or ":)";
      dirs = file.getDirs' path;
      genTemplate =
        name:
        let
          dirPath = path + "/${name}";
          flakeFile = dirPath + "/flake.nix";
          flake = if builtins.pathExists flakeFile then import flakeFile else { };
          description = flake.description or "Template for ${name}";
        in
        {
          inherit name;
          value = {
            path = dirPath;
            inherit description;
            welcomeText = msg.welcome {
              inherit name;
              inherit info;
            };
          };
        };
    in
    builtins.listToAttrs (map genTemplate dirs);

  /**
    Loads a development shell and creates corresponding package from a directory
    containing a `shell.nix` file.

    # Type
    ```
    shells :: Path -> { pkgs :: Attrs, name :: String, ... } -> { packages :: Attrs, devShells :: Attrs }
    ```

    # Example
    ```nix
    lib.load.shells ./my-shell { inherit pkgs; name = "my-shell"; }
    ```
  */
  shells =
    path: args:
    let
      inherit (args) pkgs;
      name = baseNameOf (toString path);
      shellFile = path + "/shell.nix";
      shell = import shellFile args;
      nativeBuildInputs = shell.nativeBuildInputs or [ ];

      package = pkgs.buildEnv {
        inherit name;
        paths = nativeBuildInputs;
      };

      devShell = shell.overrideAttrs (oldAttrs: {
        shellHook = ''
          ${msg.pkgs_loadded nativeBuildInputs { }}
        '';
      });

      packages = {
        ${name} = package;
      };
      devShells = {
        ${name} = devShell;
      };
    in
    {
      inherit packages devShells;
    };

  /**
    Loads development shells and creates corresponding packages from subdirectories.
    It expects each subdirectory to contain a `shell.nix` file.
    Invokes `shells` for each subdirectory.

    # Type
    ```
    shellDir :: Path -> { pkgs :: Attrs, ... } -> { packages :: Attrs, devShells :: Attrs }
    ```

    # Example
    ```nix
    lib.load.shellsDir ./shells { inherit pkgs; }
    ```
  */
  shellsDir =
    path: args:
    let
      inherit (args) pkgs;
      dirs = file.getDirs' path;

      genShell =
        name:
        let
          dirPath = path + "/${name}";
          shellResult = shells dirPath args;
        in
        shellResult;

      results = map genShell dirs;

      packages = builtins.foldl' (acc: res: acc // res.packages) { } results;
      devShells = builtins.foldl' (acc: res: acc // res.devShells) { } results;
    in
    {
      inherit packages devShells;
    };

  /**
    Loads development shells from a `flake.nix` file in a single directory.
    The directory is expected to be a flake.
    If the devShell has multiple shells, the default shell is named after the directory,
    and other shells are named as `$directory-$shellName`.

    # Type
    ```
    fromFlake :: Path -> { pkgs :: Attrs, name :: String, ... } -> { packages :: Attrs, devShells :: Attrs }
    ```

    # Example
    ```nix
    lib.load.fromFlake ./my-flake { inherit pkgs; name = "my-flake"; }
    # system, inputs are optional
    # lib.load.fromFlake ./my-flake { inherit pkgs system; };
    # lib.load.fromFlake ./my-flake { inherit pkgs inputs; };
    ```
  */
  fromFlake =
    path: args:
    let
      inherit (args) pkgs;
      system = args.system or pkgs.stdenv.hostPlatform.system;
      dirName = args.name or (baseNameOf (toString path));
      flakeFile = path + "/flake.nix";
      flake = if builtins.pathExists flakeFile then import flakeFile else { };

      # Basic evaluation of outputs if it's a function
      outputs =
        if builtins.isFunction (flake.outputs or null) then
          flake.outputs (
            (flake.inputs or { })
            // {
              self = flake;
              inherit nixpkgs;
            }
            // (args.inputs or { }) # inject inputs
          )
        else
          flake.outputs or { };

      flakeDevShells = outputs.devShells.${system} or { };

      genShell =
        shellName: shell:
        let
          finalName = if shellName == "default" then dirName else "${dirName}-${shellName}";
          nativeBuildInputs = shell.nativeBuildInputs or [ ];

          package = pkgs.buildEnv {
            name = finalName;
            paths = nativeBuildInputs;
          };

          devShell = shell.overrideAttrs (oldAttrs: {
            shellHook = ''
              ${msg.pkgs_loadded nativeBuildInputs { }}
            '';
          });
        in
        {
          inherit finalName package devShell;
        };

      allResults = nixpkgs.lib.mapAttrsToList genShell flakeDevShells;

      packages = builtins.listToAttrs (
        map (res: {
          name = res.finalName;
          value = res.package;
        }) allResults
      );
      devShells = builtins.listToAttrs (
        map (res: {
          name = res.finalName;
          value = res.devShell;
        }) allResults
      );
    in
    {
      inherit packages devShells;
    };

  /**
    Loads development shells from `flake.nix` files in subdirectories.
    Each subdirectory is expected to be a flake.
    Invokes `fromFlake` for each subdirectory.

    # Type
    ```
    fromFlakeDir :: Path -> { pkgs :: Attrs, ... } -> { packages :: Attrs, devShells :: Attrs }
    ```

    # Example
    ```nix
    lib.load.fromFlakeDir ./templates/flake { inherit pkgs; }
    # system, inputs are optional
    # lib.load.fromFlakeDir ./templates/flake { inherit pkgs system; };
    # lib.load.fromFlakeDir ./templates/flake { inherit pkgs inputs; };
    ```
  */
  fromFlakeDir =
    path: args:
    let
      dirs = file.getDirs' path;

      genShellsFromFlake =
        dirName:
        let
          dirPath = path + "/${dirName}";
          flakeResult = fromFlake dirPath (args // { name = dirName; });
        in
        flakeResult;

      results = map genShellsFromFlake dirs;

      packages = builtins.foldl' (acc: res: acc // res.packages) { } results;
      devShells = builtins.foldl' (acc: res: acc // res.devShells) { } results;
    in
    {
      inherit packages devShells;
    };
}
