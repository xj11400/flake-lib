# General utility functions {#sec-functions-library-utils}


## `flake-lib.lib.utils.filterAttrsByPrefixes` {#flake-lib.lib.utils.filterAttrsByPrefixes}

Filter an attribute set, keeping only attributes whose names start with any of the given prefixes.

### Type
```
filterAttrsByPrefixes :: attrset -> [string] -> attrset
```

## `flake-lib.lib.utils.platformIs` {#flake-lib.lib.utils.platformIs}

Detect the platform type ("darwin" or "linux") from a system string.
Throws an error if the system is unsupported.

### Type
```
platformIs :: string -> string
```

## `flake-lib.lib.utils.parseSystemString` {#flake-lib.lib.utils.parseSystemString}

Parse a Nix system string (e.g., "x86_64-linux") into its architecture and platform components.

### Type
```
parseSystemString :: string -> { arch: string, platform: string }
```

## `flake-lib.lib.utils.filterLinux` {#flake-lib.lib.utils.filterLinux}

Filter an attribute set to include only Linux systems.

### Type
```
filterLinux :: attrset -> attrset
```

## `flake-lib.lib.utils.filterDarwin` {#flake-lib.lib.utils.filterDarwin}

Filter an attribute set to include only Darwin (macOS) systems.

### Type
```
filterDarwin :: attrset -> attrset
```


