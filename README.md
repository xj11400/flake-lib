# flake-lib

A Nix library providing utilities for flake-based development, system mapping, file management, and CI detection.

## Modules

### [System](doc/system.md)

Utilities for mapping functions across different architectures and transposing system-keyed attribute sets. Provides `forAllSystems`, `forEachSystem`, and `forEachSupportedSystem`.

### [File](doc/file.md)

Functions for listing files and directories, checking path types, and advanced import utilities that resolve `default.nix` and handle recursive imports.

### [CI](doc/ci.md)

Detection logic for various CI environments, providing information about the current CI provider if one is detected.

### [Utils](doc/utils.md)

General helper functions for system string parsing, attribute filtering by prefix, and platform detection.

## Usage

Include this library in your `flake.nix` or import it directly:

```nix
{
  inputs.flake-lib.url = "github:xj11400/flake-lib";

  outputs = { self, nixpkgs, flake-lib }: {
    # Use flake-lib functions
    # flake-lib.lib.system.forAllSystems ...
  };
}
```

## Documentation

Comprehensive documentation for each module is available in the [doc/](doc/) directory.

- [System Documentation](doc/system.md)
- [File Documentation](doc/file.md)
- [CI Documentation](doc/ci.md)
- [Utils Documentation](doc/utils.md)
