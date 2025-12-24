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

### [Dev](doc/dev.md)

Provides generated `devShells` and `packages` from templates.

## Usage

- [forSystem Usage](./usage/flake.nix)

- [dev Usage](https://github.com/xj11400/dev-flake)
  - See [flake.nix](https://github.com/xj11400/dev-flake/blob/main/flake.nix) and [template/default.nix](https://github.com/xj11400/dev-flake/blob/main/templates/default.nix).
  - [dev-flake Usage](https://github.com/xj11400/dev-flake/blob/main/templates/usage/flake.nix)

  ```nix
  templates = flake-lib.lib.load.templates ./flake {
    info = ''
      This is a pure flake template.
    '';
  };
  ```
