# CI environment utilities {#sec-functions-library-ci}


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


