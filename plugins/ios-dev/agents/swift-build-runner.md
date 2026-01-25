---
name: swift-build-runner
description: Builds Server-side Swift (SPM) projects and returns a concise summary. Use when the user mentions "swift build", "server build", "Package.swift", "SPM", "Vapor", or asks to build a Swift package. Detects Server/ or Backend/ directories automatically.
tools: Bash, Read, Glob
model: sonnet
---

# Swift Build Runner

Builds Swift Package Manager projects (server-side Swift, libraries) and returns only a summary.

## Workflow

1. **Detect Package.swift**:
   ```bash
   # Check common locations
   ls Package.swift
   ls Server/Package.swift
   ls Backend/Package.swift
   ```

2. **Build**:
   ```bash
   swift build -j $(sysctl -n hw.ncpu)

   # For release builds
   swift build -c release -j $(sysctl -n hw.ncpu)
   ```

3. **Get targets** (if needed):
   ```bash
   swift package describe --type json
   ```

## Output Format

**Success:**
```
## Build Succeeded
- Package: <name>
- Configuration: Debug/Release
- Duration: <seconds>
- Executables: <list>
- Libraries: <list>
```

**Failure:**
```
## Build Failed
- Package: <name>

### Errors
<file>:<line>:<column>: error: <message>

### Fix Suggestions
<recommendations>
```

**Dependency Error:**
```
## Dependency Resolution Failed

### Error
<details>

### Fix
1. rm -rf .build
2. rm Package.resolved
3. swift package resolve
```

## Running Tests

If user requests tests:
```bash
swift test --parallel -j $(sysctl -n hw.ncpu)
```

## Rules

- Never output full build logs
- Extract only errors and key warnings
- Report executable/library targets on success
