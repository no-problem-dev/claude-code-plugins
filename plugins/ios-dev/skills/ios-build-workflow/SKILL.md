---
name: ios-build-workflow
description: iOS/Swift/Xcode build workflow guidance. Auto-applies when user mentions "iOS build", "Xcode error", "compile", "simulator", "swift build", or "xcodebuild". Recommends using subagents for builds.
---

# iOS Build Workflow

Guide for iOS/Swift/Xcode project builds.

## Recommended: Use Subagents

Builds should use **subagents** to prevent build logs from consuming main context.

| Agent | Purpose |
|-------|---------|
| **ios-build-runner** | iOS app builds (xcworkspace/xcodeproj) |
| **ios-test-runner** | Unit tests |
| **swift-build-runner** | Server-side Swift (SPM) |

## Project Detection Priority

1. **xcworkspace** (preferred) - User's Xcode workspace
2. **xcodeproj** - Fallback when no workspace
3. **Package.swift** - Pure SPM projects

Note: Exclude `.xcodeproj/project.xcworkspace` (internal file)

## Quick Commands

For lightweight operations:

| Command | Purpose |
|---------|---------|
| `/ios-dev:ios-clean` | Clear build cache |
| `/ios-dev:ios-check` | Quick compile check |

## Common Errors

### Simulator not found
```
open -a Simulator
# or
xcrun simctl boot "iPhone 16 Pro"
```

### Scheme not found
```bash
xcodebuild -list -workspace <name>.xcworkspace
```

### SPM dependency error
```bash
rm -rf ~/Library/Caches/org.swift.swiftpm
swift package resolve
```

## Related Plugins

- **ios-architecture**: Clean Architecture design principles
- **swift-design-system**: UI implementation with Design System
