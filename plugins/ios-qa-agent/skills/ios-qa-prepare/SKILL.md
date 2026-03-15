---
name: ios-qa-prepare
description: QA テストスイートの解析・前提条件解決・実行計画策定を行うフェーズスキル。ios-qa-workflow から参照される。「テスト計画」「QA 準備」「テストスイート解析」などのキーワードで自動適用。
---

# QA 準備 — テストスイート解析・実行計画

## テストスイートファイル仕様

### スイートファイル（qa-suite.md）

```
---
suite: [スイート名]
app_scheme: [scheme]
app_project_path: [path]
precondition_presets:
  [preset_name]:
    description: [説明]
    depends_on: [依存するプリセット]  # optional
    steps: |
      [達成手順のヒント（自然言語）]
---
```

### テストケースファイル

```
---
id: TC-XXX
title: [タイトル]
priority: critical | high | medium | low
tags: [tag1, tag2]
preconditions: [preset1, preset2]
depends_on: [TC-YYY]  # optional
timeout_seconds: 120  # optional
skip: false  # optional
retry: 0  # optional
---

# [タイトル]
## 前提状態
## 操作意図
## 期待結果
## 補足（optional）
```

## 実行計画の策定

### 1. テストケースの読み込み

- スイートファイルの「テストケース一覧」から各ファイルパスを取得
- 各ファイルを Read で読み込み
- フロントマターを解析
- app-map.md の存在確認（同一ディレクトリまたは親ディレクトリ）

### 2. 前提条件の解決

- 各テストケースの preconditions からプリセットを展開
- プリセット間の depends_on を再帰的に解決
- 最終的な前提条件チェーンを構築

### 3. 実行順序の決定

- depends_on で DAG（有向非巡回グラフ）を構築
- 循環依存を検出（エラー）
- トポロジカルソートで実行順序を決定
- 同一深度内は priority 順（critical > high > medium > low）

### 4. 出力: 実行計画

```
## Execution Plan

### App
- Scheme: [scheme]
- Project: [path]

### App Map
- Available: yes/no
- Path: [path] (if available)
- Last Updated: [date] (if available)

### Test Cases (in execution order)
| # | ID | Title | Priority | Preconditions | Depends On |
|---|-----|-------|----------|---------------|------------|
| 1 | TC-001 | ... | critical | [app_launched, logged_in] | - |
| 2 | TC-002 | ... | high | [app_launched, logged_in] | TC-001 |

### Precondition Presets
- app_launched: [steps]
- logged_in: [steps]

### Skipped
- TC-XXX: [理由]
```
