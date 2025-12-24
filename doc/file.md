# File system and import utilities {#sec-functions-library-file}


## `flake-lib.lib.file.lsDir` {#flake-lib.lib.file.lsDir}

List all entries under a directory.

### Type
```
lsDir :: path -> [string]
```

### Example
```nix
lsDir ./src
# => [ "default.nix" "utils.nix" ]
```

## `flake-lib.lib.file.getDirs'` {#flake-lib.lib.file.getDirs-prime}

Get all directory names in a directory.

### Type
```
getDirs' :: path -> [string]
```

### Example
```nix
getDirs' ./modules
# => [ "core" "services" ]
```

## `flake-lib.lib.file.getDirs` {#flake-lib.lib.file.getDirs}

Get all directories in a directory as full paths.

### Type
```
getDirs :: path -> [path]
```

### Example
```nix
getDirs ./modules
# => [ /path/to/modules/core /path/to/modules/services ]
```

## `flake-lib.lib.file.getNixFiles'` {#flake-lib.lib.file.getNixFiles-prime}

Get all .nix file names in a directory.

### Type
```
getNixFiles' :: path -> [string]
```

### Example
```nix
getNixFiles' ./src
# => [ "default.nix" "utils.nix" ]
```

## `flake-lib.lib.file.getNixFiles` {#flake-lib.lib.file.getNixFiles}

Get all .nix files in a directory as full paths.

### Type
```
getNixFiles :: path -> [path]
```

### Example
```nix
getNixFiles ./src
# => [ /path/to/src/default.nix /path/to/src/utils.nix ]
```

## `flake-lib.lib.file.importSafe` {#flake-lib.lib.file.importSafe}

Import a path if it exists, otherwise return an empty attribute set.

### Type
```
importSafe :: path -> any
```

### Example
```nix
importSafe ./optional-config.nix
# => { ... } # if file exists
# => { }     # if file does not exist
```

## `flake-lib.lib.file.isDirectory` {#flake-lib.lib.file.isDirectory}

Check if a given path is a directory.

### Type
```
isDirectory :: path -> bool
```

### Example
```nix
isDirectory ./modules
# => true
```

## `flake-lib.lib.file.flattenPaths` {#flake-lib.lib.file.flattenPaths}

Recursively find all .nix files from a list of paths.
 If a path is a directory, it finds .nix files directly inside it.

### Type
```
flattenPaths :: [path] -> [path]
```

### Example
```nix
flattenPaths [ ./file.nix ./dir ]
# => [ ./file.nix ./dir/a.nix ./dir/b.nix ]
```

## `flake-lib.lib.file.resolvePath` {#flake-lib.lib.file.resolvePath}

Determine what to import from a path.
- If it's a file, it's treated as a single import.
- If it's a directory with 'default.nix', it's treated as a single import (Nix standard).
- If it's a directory without 'default.nix', it returns a list of .nix files inside.

### Type
```
resolvePath :: path -> { type: string, value: any }
```

### Example
```nix
resolvePath ./dir-with-default
# => { type = "single"; value = ./dir-with-default; }

resolvePath ./dir-without-default
# => { type = "directory"; value = [ ./dir-without-default/a.nix ... ]; }
```

## `flake-lib.lib.file.importLists'` {#flake-lib.lib.file.importLists-prime}

Import files/directories and merge their contents as lists.
Does not pass any arguments to the imported files.

### Type
```
importLists' :: [path] -> [any]
```

### Example
```nix
importLists' ["./list1.nix" "./dir"]
# => [ "item1" "item2" "item3" ]
```

## `flake-lib.lib.file.importLists` {#flake-lib.lib.file.importLists}

Import files/directories and merge their contents as lists, passing 'args' to each.

### Type
```
importLists :: [path] -> attrset -> [any]
```

### Example
```nix
importLists ["./list1.nix" "./dir"] { inherit pkgs; }
# => [ { name = "item1"; ... } ... ]
```

## `flake-lib.lib.file.importAll` {#flake-lib.lib.file.importAll}

Import files/directories and merge everything into one flat attribute set.
Passing 'args' to each import. Non-attrset contents are wrapped in an attrset
with the filename (minus .nix) as the key.

### Type
```
importAll :: [path] -> attrset -> attrset
```

### Example
```nix
importAll ["./set1.nix" "./file.nix"] { inherit pkgs; }
# => { key1 = "val1"; file = "content"; }
```

## `flake-lib.lib.file.importFiles` {#flake-lib.lib.file.importFiles}

Import files and directories, preserving structure by wrapping directory
contents in an attribute set named after the directory.

### Type
```
importFiles :: [path] -> attrset -> attrset
```

### Example
```nix
importFiles ["./file1.nix" "./dir"] { inherit pkgs; }
# => { file1 = { ... }; dir = { a = { ... }; b = { ... }; }; }
```

## `flake-lib.lib.file.importAll'` {#flake-lib.lib.file.importAll-prime}

Similar to importAll, but does not perform 'default.nix' resolution for directories.
Instead, it flattens all .nix files found in the provided paths.

### Type
```
importAll' :: [path] -> attrset -> attrset
```

### Example
```nix
importAll' ["./file1.nix" "./dir"] { inherit pkgs; }
# => { ... } # Flattens all .nix files in ./dir
```

## `flake-lib.lib.file.importFiles'` {#flake-lib.lib.file.importFiles-prime}

Similar to importFiles, but does not perform 'default.nix' resolution.
Directly imports files or directory contents (names from getNixFiles).

### Type
```
importFiles' :: [path] -> attrset -> attrset
```

### Example
```nix
importFiles' ["./file1.nix" "./dir"] { inherit pkgs; }
# => { file1 = { ... }; dir = { a = { ... }; b = { ... }; }; }
```


