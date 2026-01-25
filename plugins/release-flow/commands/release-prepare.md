---
description: Prepare release by updating CHANGELOG and pushing to remote. PR is auto-created by GitHub Actions.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
argument-hint: <version> (e.g., 1.2.0)
---

# Release Preparation Command

Prepares a release for the specified version.

## Workflow

### 1. Preflight Checks (CRITICAL)

**Always perform these checks first:**

```bash
# Fetch latest remote state
git fetch origin

# Check current branch
git branch --show-current

# Check if on correct release branch (release/v<version>)
# If not on release branch, ask user if they want to create/switch

# Check if local is in sync with remote
git status -uno
```

**If local is behind remote:**
```bash
git pull origin <branch>
```

**If local has uncommitted changes:**
- Warn user and ask how to proceed

### 2. Version Validation

- Validate version from $ARGUMENTS (e.g., 1.2.0)
- Confirm branch name matches version: `release/v<version>`

### 3. CHANGELOG Update

- Read CHANGELOG.md
- Find "## [未リリース]" section
- Convert to "## [<version>] - YYYY-MM-DD"
- Add new "## [未リリース]" section at top
- Update comparison links

### 4. Commit

```bash
git add CHANGELOG.md
git commit -m "chore: prepare for v<version> release"
```

### 5. Push to Remote (AUTOMATIC)

**Critical: Always push after commit:**
```bash
git push origin release/v<version>
```

### 6. Report Result

## Important Notes

- Version must follow semantic versioning (X.Y.Z)
- If "未リリース" section is empty, warn user
- If version section already exists, show error
- **DO NOT create PR manually** - GitHub Actions auto-creates it

## Output Example

```
✅ Release Preparation Complete

- Version: v1.2.0
- Branch: release/v1.2.0
- CHANGELOG: Updated
- Pushed: Yes

📌 Next Step:
- The release PR was auto-created by GitHub Actions
- Review and merge: gh pr view

⚠️ Note: Do NOT create PR manually. Check existing PRs:
  gh pr list --head release/v1.2.0
```
