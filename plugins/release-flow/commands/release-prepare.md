---
description: リリース準備を開始。CHANGELOGの「未リリース」セクションをバージョン番号に変換し、リリースブランチを作成
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
argument-hint: <version> (例: 1.2.0)
---

# リリース準備コマンド

指定されたバージョンでリリース準備を行います。

## 実行手順

1. **バージョン番号を確認**: $ARGUMENTS で指定されたバージョン（例: 1.2.0）
2. **現在のブランチを確認**: `git branch --show-current`
3. **CHANGELOG.mdを読み込み**: 「未リリース」セクションの内容を確認
4. **リリースブランチ作成**: `release/v<version>` ブランチを作成（まだ存在しない場合）
5. **CHANGELOG更新**:
   - 「## [未リリース]」を「## [<version>] - <今日の日付>」に変更
   - 新しい「## [未リリース]」セクションを追加
   - 比較リンクを更新
6. **変更をコミット**: `chore: prepare for v<version> release`
7. **結果を報告**

## 注意事項

- バージョン番号はセマンティックバージョニング形式（X.Y.Z）で指定
- CHANGELOG.mdが存在しない場合は作成
- 「未リリース」セクションが空の場合は警告
- 既にそのバージョンのセクションがある場合はエラー

## 出力例

```
✅ リリース準備完了

- バージョン: v1.2.0
- ブランチ: release/v1.2.0
- CHANGELOG: 更新済み

次のステップ:
1. 変更内容を確認: git diff HEAD~1
2. プッシュ: git push origin release/v1.2.0
3. PR作成: gh pr create --title "Release v1.2.0" --base main
```
