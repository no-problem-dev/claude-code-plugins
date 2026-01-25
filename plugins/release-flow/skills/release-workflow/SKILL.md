---
name: release-workflow
description: Release workflow guidance. Provides CHANGELOG format, semantic versioning, and Git flow best practices. Use when user mentions "release", "version", "CHANGELOG", "tag", or "GitHub Release".
disable-model-invocation: true
context: fork
---

# Release Workflow Guide

## Important: Explicit Invocation Only

This skill requires explicit user invocation via `/release-prepare`. Never execute release operations proactively.

## Reference Documents

See detailed implementation examples in the plugin root:
- `../../references/RELEASE_PROCESS.md` - Complete release process guide
- `../../references/auto-release-on-merge.yml` - GitHub Actions workflow

## Semantic Versioning

Format: `MAJOR.MINOR.PATCH` ([Semantic Versioning 2.0.0](https://semver.org/))

| Change Type | Version | Example | Description |
|-------------|---------|---------|-------------|
| Bug fixes only | PATCH | 1.0.0 → 1.0.1 | Backward compatible fixes |
| New features | MINOR | 1.0.1 → 1.1.0 | Backward compatible additions |
| Breaking changes | MAJOR | 1.1.0 → 2.0.0 | Incompatible changes |

Pre-release: `1.0.0-alpha.1`, `1.0.0-beta.1`, `1.0.0-rc.1`

## CHANGELOG Format

[Keep a Changelog](https://keepachangelog.com/) format:

```markdown
# Changelog

## [未リリース]

### 追加
- New feature description

## [1.0.0] - 2025-01-15

### 追加
- Initial release

[未リリース]: https://github.com/owner/repo/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/owner/repo/releases/tag/v1.0.0
```

### Categories

| Category | English | Description |
|----------|---------|-------------|
| 追加 | Added | New features |
| 変更 | Changed | Changes to existing features |
| 非推奨 | Deprecated | Features to be removed |
| 削除 | Removed | Removed features |
| 修正 | Fixed | Bug fixes |
| セキュリティ | Security | Security fixes |

### Good Entry Examples

```markdown
### 追加
- **API**: POST /api/v1/users endpoint for user registration
- **iOS**: Dark mode support (toggle in settings)

### 修正
- **Backend**: Return proper error message on token expiration
```

## Release Branch Strategy

```
main (production)
  ├── release/v1.0.0 (release preparation)
  ├── release/v1.1.0 (next release)
  └── feature/* (development)
```

## Release Flow

### Critical: Automatic PR Creation

**The release PR is created automatically by GitHub Actions.** Do NOT create it manually.

### Workflow

1. **Create release branch**: `release/vX.Y.Z` from main
2. **Develop**: Merge features to release branch
3. **Update CHANGELOG**: Add entries to "未リリース" section
4. **Prepare release**: Run `/release-prepare X.Y.Z`
   - Updates CHANGELOG (未リリース → [X.Y.Z])
   - Commits changes
   - **Pushes to remote automatically**
5. **PR is auto-created**: GitHub Actions creates the PR
6. **Merge PR**: Triggers automatic release

### After PR Merge (Automatic)

1. Tag creation (vX.Y.Z)
2. GitHub Release with changelog
3. Next release branch creation
4. Draft PR for next release

## Troubleshooting

### CHANGELOG validation error

**Error**: `CHANGELOG.md does not contain version [X.Y.Z] section`

**Fix**:
1. Verify format: `## [X.Y.Z] - YYYY-MM-DD`
2. Confirm version matches branch name
3. Commit and push again

### Tag already exists

```bash
# Delete remote tag
git push origin :refs/tags/vX.Y.Z
# Delete local tag
git tag -d vX.Y.Z
# Delete GitHub Release (via web)
```
