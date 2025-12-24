# Message functions {#sec-functions-library-dev.msg}


## `flake-lib.lib.dev.msg.pkgs_loadded` {#flake-lib.lib.dev.msg.pkgs_loadded}

Generates a shell script snippet to echo a title and list of loaded packages.

### Type
```
pkgs_loadded :: [Derivation] -> { title :: String } -> String
```

### Example
```nix
lib.msg.pkgs_loadded [ pkgs.hello ] { title = "My packages:"; }
```

## `flake-lib.lib.dev.msg.pkgs_list` {#flake-lib.lib.dev.msg.pkgs_list}

Generates a shell script snippet to echo each package in the list.

### Type
```
pkgs_list :: [Derivation] -> String
```

### Example
```nix
lib.msg.pkgs_list [ pkgs.hello ]
```

## `flake-lib.lib.dev.msg.welcome` {#flake-lib.lib.dev.msg.welcome}

Generates a welcome message for a template.

### Type
```
welcome :: { name :: String, info :: String } -> String
```

### Example
```nix
lib.msg.welcome { name = "rust"; info = "Happy coding!"; }
```


# Load functions {#sec-functions-library-dev.load}


## `flake-lib.lib.dev.load.templates` {#flake-lib.lib.dev.load.templates}

Loads templates from subdirectories of a given path.

### Type
```
templates :: Path -> { info :: String } -> Attrs
```

### Example
```nix
lib.load.templates ./templates { info = "v1.0"; }
```

## `flake-lib.lib.dev.load.shells` {#flake-lib.lib.dev.load.shells}

Loads a development shell and creates corresponding package from a directory
containing a `shell.nix` file.

### Type
```
shells :: Path -> { pkgs :: Attrs, name :: String, ... } -> { packages :: Attrs, devShells :: Attrs }
```

### Example
```nix
lib.load.shells ./my-shell { inherit pkgs; name = "my-shell"; }
```

## `flake-lib.lib.dev.load.shellsDir` {#flake-lib.lib.dev.load.shellsDir}

Loads development shells and creates corresponding packages from subdirectories.
It expects each subdirectory to contain a `shell.nix` file.
Invokes `shells` for each subdirectory.

### Type
```
shellDir :: Path -> { pkgs :: Attrs, ... } -> { packages :: Attrs, devShells :: Attrs }
```

### Example
```nix
lib.load.shellsDir ./shells { inherit pkgs; }
```

## `flake-lib.lib.dev.load.fromFlake` {#flake-lib.lib.dev.load.fromFlake}

Loads development shells from a `flake.nix` file in a single directory.
The directory is expected to be a flake.
If the devShell has multiple shells, the default shell is named after the directory,
and other shells are named as `$directory-$shellName`.

### Type
```
fromFlake :: Path -> { pkgs :: Attrs, name :: String, ... } -> { packages :: Attrs, devShells :: Attrs }
```

### Example
```nix
lib.load.fromFlake ./my-flake { inherit pkgs; name = "my-flake"; }
# system, inputs are optional
# lib.load.fromFlake ./my-flake { inherit pkgs system; };
# lib.load.fromFlake ./my-flake { inherit pkgs inputs; };
```

## `flake-lib.lib.dev.load.fromFlakeDir` {#flake-lib.lib.dev.load.fromFlakeDir}

Loads development shells from `flake.nix` files in subdirectories.
Each subdirectory is expected to be a flake.
Invokes `fromFlake` for each subdirectory.

### Type
```
fromFlakeDir :: Path -> { pkgs :: Attrs, ... } -> { packages :: Attrs, devShells :: Attrs }
```

### Example
```nix
lib.load.fromFlakeDir ./templates/flake { inherit pkgs; }
# system, inputs are optional
# lib.load.fromFlakeDir ./templates/flake { inherit pkgs system; };
# lib.load.fromFlakeDir ./templates/flake { inherit pkgs inputs; };
```


# Use functions {#sec-functions-library-dev}


## `flake-lib.lib.dev.use` {#flake-lib.lib.dev.use}

Retrieves packages and devShells for a specific system and target.

### Type
```
use :: attrset -> String -> String -> { packages :: Derivation, devShells :: Derivation }
```

### Example
```nix
lib.use self "x86_64-linux" "rust"
# => {
#      packages = << Derivation >>;
#      devShell = << Derivation >>;
#    };
```


