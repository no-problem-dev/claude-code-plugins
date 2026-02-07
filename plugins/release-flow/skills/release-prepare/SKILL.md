---
name: release-prepare
description: リリース準備ワークフロー。CHANGELOG 更新・コミット・プッシュを実行。「リリース準備」「release prepare」「リリースする」などのキーワードで自動適用。
---

# リリース準備

指定バージョンのリリースを準備する。

## 重要: 明示的な呼び出しのみ

リリース操作は必ずユーザーの明示的な指示で実行すること。プロアクティブに実行しない。

## ワークフロー

### 1. プリフライトチェック（必須）

```bash
# 最新のリモート状態を取得
git fetch origin

# 現在のブランチを確認
git branch --show-current

# release/v<version> ブランチにいるか確認
# いなければ、ユーザーに作成/切り替えを確認

# ローカルがリモートと同期しているか確認
git status -uno
```

**ローカルが遅れている場合:**
```bash
git pull origin <branch>
```

**未コミットの変更がある場合:**
- ユーザーに警告し、対処方法を確認

### 2. バージョンバリデーション

- バージョン形式を検証（X.Y.Z）
- ブランチ名とバージョンの一致を確認: `release/v<version>`

### 3. CHANGELOG 更新

- CHANGELOG.md を読み込み
- `## [未リリース]` セクションを検出
- `## [<version>] - YYYY-MM-DD` に変換
- 新しい `## [未リリース]` セクションをトップに追加
- 比較リンクを更新

### 4. コミット

```bash
git add CHANGELOG.md
git commit -m "chore: prepare for v<version> release"
```

### 5. プッシュ（自動）

```bash
git push origin release/v<version>
```

### 6. 結果報告

## 重要な注意事項

- バージョンはセマンティックバージョニング（X.Y.Z）に従うこと
- 「未リリース」セクションが空の場合、ユーザーに警告
- バージョンセクションが既に存在する場合、エラーを表示
- **PR を手動で作成しないこと** — GitHub Actions が自動作成

## 出力例

```
リリース準備完了

- バージョン: v1.2.0
- ブランチ: release/v1.2.0
- CHANGELOG: 更新済み
- プッシュ: 完了

次のステップ:
- リリース PR は GitHub Actions で自動作成されます
- 確認・マージ: gh pr view

注意: PR は手動で作成しないでください。既存の PR を確認:
  gh pr list --head release/v1.2.0
```
