# System mapping and transposing utilities {#sec-functions-library-system}


## `flake-lib.lib.system.allSystems` {#flake-lib.lib.system.allSystems}

The list of all platforms to support.
If running with --impure, the current host system is automatically added
if it's not already in the default 'systems' list.

### Type
```
allSystems :: [string]
```

### Example
```nix
allSystems
# => [ "x86_64-darwin" "aarch64-darwin" "x86_64-linux" "aarch64-linux" ]
```

## `flake-lib.lib.system.forAllSystems` {#flake-lib.lib.system.forAllSystems}

Generator function that maps a given function across the default platforms (`allSystems`).
The function `f` should accept a system string and return an attribute set.

### Type
```
forAllSystems :: (string -> attrset) -> attrset
```

### Example
```nix
forAllSystems (system: { hello = "world from ${system}"; })
# => {
#   x86_64-darwin = { hello = "world from x86_64-darwin"; };
#   aarch64-darwin = { hello = "world from aarch64-darwin"; };
#   ...
# }
```

## `flake-lib.lib.system.forEachSystem` {#flake-lib.lib.system.forEachSystem}

Transposer function that maps across default platforms and regroups the results.
It transforms `system -> { key = value }` into `key -> { system = value }`.

### Type
```
forEachSystem :: (string -> attrset) -> attrset
```

### Example
```nix
forEachSystem (system: { pkg = "some-pkg"; })
# => { pkg = { x86_64-linux = "some-pkg"; aarch64-linux = "some-pkg"; ... }; }
```

## `flake-lib.lib.system.forEachSupportedSystem` {#flake-lib.lib.system.forEachSupportedSystem}

Helper function to generate an attribute set across default platforms,
providing a pre-configured `pkgs` instance for each system.

### Type
```
forEachSupportedSystem :: { nixpkgs: path, config?: attrset, overlays?: [overlay] } -> ({ system, pkgs }: attrset) -> attrset
```

### Example
```nix
forEachSupportedSystem { inherit nixpkgs; } ({ system, pkgs }: {
  default = pkgs.hello;
})
# => { x86_64-linux = { default = <derivation hello>; }; ... }
```

## `flake-lib.lib.system.forAllSystems'` {#flake-lib.lib.system.forAllSystems-prime}

Like `forAllSystems`, but allows specifying a custom list of systems.

### Type
```
forAllSystems' :: { systems?: [string] } -> (string -> attrset) -> attrset
```

### Example
```nix
forAllSystems' { systems = [ "x86_64-linux" ]; } (system: { hello = system; })
# => { x86_64-linux = { hello = "x86_64-linux"; }; }
```

## `flake-lib.lib.system.forEachSystem'` {#flake-lib.lib.system.forEachSystem-prime}

Like `forEachSystem`, but allows specifying a custom list of systems.

### Type
```
forEachSystem' :: { systems?: [string] } -> (string -> attrset) -> attrset
```

### Example
```nix
forEachSystem' { systems = [ "x86_64-linux" ]; } (system: { pkg = "foo"; })
# => { pkg = { x86_64-linux = "foo"; }; }
```

## `flake-lib.lib.system.forEachSupportedSystem'` {#flake-lib.lib.system.forEachSupportedSystem-prime}

Like `forEachSupportedSystem`, but allows specifying a custom list of systems.

### Type
```
forEachSupportedSystem' :: { nixpkgs: path, config?: attrset, overlays?: [overlay], systems?: [string] } -> ({ system, pkgs }: attrset) -> attrset
```

### Example
```nix
forEachSupportedSystem' { inherit nixpkgs; systems = [ "x86_64-linux" ]; } ({ system, pkgs }: {
  default = pkgs.hello;
})
# => { x86_64-linux = { default = <derivation hello>; }; }
```


