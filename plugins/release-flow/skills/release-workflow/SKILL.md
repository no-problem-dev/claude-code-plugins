---
name: release-workflow
description: リリースワークフロー管理スキル。CHANGELOG更新、セマンティックバージョニング、GitHub Release作成、リリースブランチ運用のベストプラクティスを提供。「リリース」「バージョン」「CHANGELOG」「タグ」「GitHub Release」などのキーワードで自動適用。
---

# リリースワークフロー管理スキル

## 概要

このスキルは、ソフトウェアリリースの標準的なワークフローを支援します。

## 参照ドキュメント

詳細な実装例は以下のファイルを参照してください:

- `references/RELEASE_PROCESS.md` - 完全なリリースプロセスガイド（Stockleプロジェクト実例）
- `references/auto-release-on-merge.yml` - GitHub Actions ワークフロー実装

## セマンティックバージョニング

[Semantic Versioning 2.0.0](https://semver.org/lang/ja/) に準拠します。

### バージョン形式: `MAJOR.MINOR.PATCH`

| 変更タイプ | バージョン | 例 | 説明 |
|-----------|-----------|-----|------|
| バグ修正のみ | PATCH | 1.0.0 → 1.0.1 | 後方互換性のあるバグ修正 |
| 新機能追加 | MINOR | 1.0.1 → 1.1.0 | 後方互換性のある機能追加 |
| 破壊的変更 | MAJOR | 1.1.0 → 2.0.0 | 後方互換性のない変更 |

### プレリリースバージョン

- `1.0.0-alpha.1` - アルファ版
- `1.0.0-beta.1` - ベータ版
- `1.0.0-rc.1` - リリース候補

## CHANGELOG フォーマット

[Keep a Changelog](https://keepachangelog.com/ja/1.0.0/) 形式に準拠します。

### 基本構造

```markdown
# Changelog

このプロジェクトのすべての注目すべき変更はこのファイルに記載されます。

フォーマットは [Keep a Changelog](https://keepachangelog.com/ja/1.0.0/) に基づいており、
このプロジェクトは [Semantic Versioning](https://semver.org/lang/ja/) に準拠しています。

## [未リリース]

### 追加
- 新機能の説明

### 変更
- 既存機能の変更

### 修正
- バグ修正の説明

## [1.0.0] - 2025-01-15

### 追加
- 初期リリース

[未リリース]: https://github.com/owner/repo/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/owner/repo/releases/tag/v1.0.0
```

### 変更の分類

| カテゴリ | 英語 | 説明 |
|---------|------|------|
| 追加 | Added | 新機能 |
| 変更 | Changed | 既存機能の変更 |
| 非推奨 | Deprecated | 将来削除予定の機能 |
| 削除 | Removed | 削除された機能 |
| 修正 | Fixed | バグ修正 |
| セキュリティ | Security | セキュリティ関連の修正 |

### 良いCHANGELOGエントリの書き方

**良い例:**
```markdown
### 追加
- **API**: POST /api/v1/users エンドポイントを追加し、ユーザー登録に対応
- **iOS**: ダークモードに対応（設定画面から切り替え可能）

### 修正
- **Backend**: 認証トークンの有効期限切れ時に適切なエラーメッセージを返すよう修正
```

**悪い例:**
```markdown
### 変更
- いろいろ修正
- バグ直した
```

### ポイント
- プラットフォーム/コンポーネントを明記（**Backend**:, **iOS**:, **API**:）
- 具体的で詳細な説明
- ユーザーにとっての価値を明確に
- 太字で重要なポイントを強調

## リリースブランチ戦略

### Git Flow ベースの運用

```
main (本番)
  ├── release/v1.0.0 (リリース準備)
  ├── release/v1.1.0 (次期リリース)
  └── feature/* (機能開発)
```

### リリースフロー

1. **リリースブランチ作成**: `release/vX.Y.Z` を main から作成
2. **開発**: 機能追加・修正をリリースブランチにマージ
3. **CHANGELOG更新**: 「未リリース」セクションに変更を記録
4. **リリース準備**: 「未リリース」を `[X.Y.Z] - YYYY-MM-DD` に変換
5. **PRマージ**: リリースブランチを main にマージ
6. **自動処理**: タグ作成 → GitHub Release → 次リリースブランチ作成

## GitHub Actions 自動化

### リリース自動化ワークフロー例

```yaml
name: Auto Release on Merge

on:
  pull_request:
    types: [closed]
    branches: [main]

jobs:
  auto-release:
    if: github.event.pull_request.merged == true && startsWith(github.event.pull_request.head.ref, 'release/v')
    runs-on: ubuntu-latest
    steps:
      - name: Extract version
        run: |
          BRANCH="${{ github.event.pull_request.head.ref }}"
          VERSION="${BRANCH#release/}"
          echo "version=$VERSION" >> $GITHUB_OUTPUT

      - name: Create tag and release
        uses: softprops/action-gh-release@v2
        with:
          tag_name: ${{ steps.version.outputs.version }}
```

## コマンド例

### リリース準備
```bash
# リリースブランチを作成
git checkout -b release/v1.2.0 main

# CHANGELOG更新後
git add CHANGELOG.md
git commit -m "chore: prepare for v1.2.0 release"
git push origin release/v1.2.0

# PRを作成
gh pr create --title "Release v1.2.0" --base main
```

### リリース実行
```bash
# PRをマージ（自動リリースのトリガー）
gh pr merge <PR番号> --squash

# リリース確認
gh release view v1.2.0
```

## トラブルシューティング

### CHANGELOG検証エラー

**エラー**: `CHANGELOG.mdにバージョン [X.Y.Z] のセクションが見つかりません`

**対処法**:
1. CHANGELOGのバージョンフォーマット確認: `## [X.Y.Z] - YYYY-MM-DD`
2. ブランチ名とバージョン番号の一致確認
3. 修正後、再度コミット・プッシュ

### タグが既に存在する

**対処法**:
```bash
# リモートタグを削除
git push origin :refs/tags/vX.Y.Z

# ローカルタグを削除
git tag -d vX.Y.Z

# GitHub Releaseを手動で削除（Webから）
```

### バージョン番号を間違えた

**マージ前**: PRを閉じて修正後、再度PR作成

**マージ後**:
1. タグとGitHub Releaseを削除
2. CHANGELOGを修正
3. 正しいバージョンで再リリース
