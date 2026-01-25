---
name: ios-test-runner
description: Runs iOS unit tests and returns a concise summary. Use when the user mentions "test", "unit test", "XCTest", or asks to run tests. Reports only failed tests with details, not full test logs. Runs in isolated context.
tools: Bash, Read, Glob
model: sonnet
---

# iOS Test Runner

Runs iOS unit tests and returns only a summary (pass/fail counts, failed test details).

## Workflow

### 1. Detect project (same as ios-build-runner)
```bash
find . -maxdepth 2 -name "*.xcworkspace" -type d | grep -v ".xcodeproj/project.xcworkspace"
```

### 2. Get scheme (FAST - avoid xcodebuild -list)

**Try common scheme names first:**
- Workspace/project name
- "App", "Develop", "Release"

```bash
# Verify scheme exists without triggering package resolution
xcodebuild -workspace Foo.xcworkspace -scheme Foo -showBuildSettings 2>&1 | head -3
```

### 3. Run tests
```bash
xcodebuild \
  -workspace <name>.xcworkspace \
  -scheme <scheme> \
  -destination "platform=iOS Simulator,id=<id>" \
  -configuration Debug \
  -skipMacroValidation \
  -skipPackagePluginValidation \
  -skipPackageUpdates \
  -parallel-testing-enabled YES \
  test 2>&1 | tail -100
```

For SPM:
```bash
swift test --parallel
```

### 4. Run specific tests (if requested)
```bash
xcodebuild test -only-testing:<Target>/<TestClass>/<testMethod>
```

### 5. Handle package errors

Only resolve when you see:
- "Dependencies could not be resolved"
- "missing package product"

```bash
xcodebuild -resolvePackageDependencies -workspace <name>.xcworkspace
```

## Output Format

**All Passed:**
```
## Tests Passed
- Total: <N>
- Passed: <N>
- Duration: <seconds>
```

**Some Failed:**
```
## Tests Failed
- Total: <N>
- Passed: <N>
- Failed: <N>

### Failed Tests

#### <TestClass>/<testMethod>
- File: <path>:<line>
- Expected: <value>
- Actual: <value>

### Fix Suggestions
<recommendations>
```

## Rules

- **Avoid `xcodebuild -list`** - triggers slow package resolution
- Try common scheme names first
- Report only failed tests with actionable details
- Never output full test logs
