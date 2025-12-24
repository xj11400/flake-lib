# CI environment utilities {#sec-functions-library-ci}


## `flake-lib.lib.ci.allCI` {#flake-lib.lib.ci.allCI}

List of all supported CI environment configurations.

### Type
```
allCI :: [{ name: string, env: [string] }]
```

### Example
```nix
allCI
# => [ { name = "GitHub Actions"; env = [ "GITHUB_ACTIONS" ]; } ... ]
```

## `flake-lib.lib.ci.inCI` {#flake-lib.lib.ci.inCI}

Boolean indicating if the current environment is a detected CI.

### Type
```
inCI :: bool
```

### Example
```nix
inCI
# => true # if GITHUB_ACTIONS is set
```

## `flake-lib.lib.ci.infoCI` {#flake-lib.lib.ci.infoCI}

Information about the detected CI environment.
 Returns an empty attribute set if no CI is detected.

### Type
```
infoCI :: { name: string, env: [string] } | {}
```

### Example
```nix
infoCI
# => { name = "GitHub Actions"; env = [ "GITHUB_ACTIONS" ]; }
```

## `flake-lib.lib.ci.notInCI` {#flake-lib.lib.ci.notInCI}

Indicates that the current environment is NOT a CI.

### Type
```
notInCI :: bool
```

### Example
```nix
notInCI
# => false # if in a CI environment
```

## `flake-lib.lib.ci.isDetected` {#flake-lib.lib.ci.isDetected}

Check if a given CI configuration is detected in the current environment.

### Type
```
isDetected :: { env: [string] } -> bool
```

### Example
```nix
isDetected { env = ["GITHUB_ACTIONS"]; }
# => true # if GITHUB_ACTIONS env var is set
```


