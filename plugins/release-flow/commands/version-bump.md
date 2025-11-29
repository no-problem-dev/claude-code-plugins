---
description: セマンティックバージョニングに基づいてバージョンを計算
allowed-tools: Read, Bash, Grep
argument-hint: <bump-type> (major|minor|patch)
---

# バージョンバンプコマンド

現在のバージョンから次のバージョンを計算します。

## 引数

$ARGUMENTS: バンプタイプ
- `major` - メジャーバージョンアップ (1.2.3 → 2.0.0)
- `minor` - マイナーバージョンアップ (1.2.3 → 1.3.0)
- `patch` - パッチバージョンアップ (1.2.3 → 1.2.4)

## 実行手順

1. **現在のバージョンを取得**:
   - `git tag --sort=-v:refname | head -1` でタグから取得
   - または CHANGELOG.md から最新バージョンを抽出
2. **バージョンを解析**: MAJOR.MINOR.PATCH に分解
3. **指定タイプに応じてインクリメント**:
   - major: MAJOR+1, MINOR=0, PATCH=0
   - minor: MINOR+1, PATCH=0
   - patch: PATCH+1
4. **結果を表示**

## 出力例

```
📊 バージョン計算結果

現在のバージョン: v1.2.3
バンプタイプ: minor
次のバージョン: v1.3.0

次のステップ:
/release-prepare 1.3.0
```

## セマンティックバージョニングガイド

| 変更内容 | タイプ | 例 |
|---------|--------|-----|
| バグ修正のみ | patch | 1.2.3 → 1.2.4 |
| 新機能追加（後方互換） | minor | 1.2.3 → 1.3.0 |
| 破壊的変更 | major | 1.2.3 → 2.0.0 |
