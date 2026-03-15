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

## Phase 0.5: App Map 差分分析（回帰テストモード）

**実行条件:** ユーザーが「回帰テスト」「regression」「差分テスト」と指示した場合、または ios-qa-workflow から指示された場合

### フロー

#### 1. App Map 変更履歴の取得

```bash
git log --oneline -10 -- tests/app-map.md
```

現在の App Map ファイルが Git 管理下にあるか確認。なければ差分分析をスキップ。

#### 2. 前回バージョンの App Map 取得

```bash
git show HEAD~1:tests/app-map.md
```

前回コミットの App Map を取得（存在する場合）。

**エラー処理:**
- `fatal: bad revision` → 初回実行（差分対象なし）、警告を出力
- ファイル移動検出 → git log で正確なパスを確認

#### 3. App Map 差分の分類

現在の App Map と前バージョンを比較し、以下を検出:

**差分カテゴリ:**
1. **新規画面** — 現在の App Map にのみ存在
   - Screens セクションで name が増加した画面
   - 推奨アクション: テストケース追加

2. **削除された画面** — 前回の App Map にのみ存在
   - Screens セクションで削除された画面
   - 推奨アクション: 関連テストケースの無効化（skip: true）

3. **変更された要素** — 画面は同じだが要素が変更
   - Screens 内の要素リスト（elements など）が変更
   - 信頼度情報 [HIGH]/[MED]/[LOW] の変化
   - 推奨アクション: 関連テストケースの期待結果更新

4. **変更された遷移** — Transitions セクションの変更
   - from/to/action の追加・削除
   - 推奨アクション: 関連テストケースの操作意図確認

5. **QA Readiness スコア変化**
   - `qa_readiness_score` の前後比較
   - スコア低下時は警告

#### 4. 影響を受けるテストケースの特定

テストケースの以下のフィールドと App Map 差分を照合:

- **preconditions** — 開始画面が削除/変更された場合、テストケースに影響
- **操作意図** — 途中経路が削除された場合に影響
- **期待結果** — 終了画面が削除/変更された場合に影響

**マッピング例:**

```
TC-001 の precondition: [home]
  → App Map で home が変更された → 影響度: HIGH

TC-002 の操作意図に「settings 画面へ遷移」
  → settings への遷移が App Map で削除 → 影響度: HIGH

TC-003 の期待結果に「session_active 画面に到達」
  → session_active 画面の要素が [HIGH] → [LOW] に低下 → 影響度: MEDIUM
```

### 5. 出力形式

```markdown
## App Map 差分分析

### 変更サマリー
- 新規画面: [N] 件
- 変更画面: [N] 件
- 削除画面: [N] 件
- 遷移変更: [N] 件

### 新規画面
| 画面名 | 推奨テストケース |
|-------|-----------------|
| [screen] | TC-AUTO-XXX または新規追加推奨 |

### 削除画面
| 画面名 | 影響テストケース |
|-------|-----------------|
| [screen] | TC-YYY (precondition), TC-ZZZ (期待結果) |

### 変更要素
| 画面名 | 変更内容 | 信頼度変化 | 影響テストケース |
|-------|--------|---------|-----------------|
| [screen] | [要素名] 削除 / 追加 / 名称変更 | [HIGH]→[MED] | TC-ABC |

### 遷移変更
| 変更 | From | To | Action | 影響テストケース |
|-----|------|-----|--------|-----------------|
| 追加 | [screen] | [screen] | [action] | - |
| 削除 | [screen] | [screen] | [action] | TC-DEF (操作意図) |

### 影響を受けるテストケース
| TC-ID | 影響種別 | 影響詳細 | QA Readiness への影響 | 推奨アクション |
|-------|---------|---------|-------|----------|
| TC-001 | precondition 変更 | home 画面の要素が [HIGH]→[MED] に低下 | -10% | テストの期待結果を見直し、[MED] 信頼度での操作方法を確認 |
| TC-002 | 操作意図 変更 | settings 画面への遷移が削除された | - | テストケース内容を見直し、遷移パスを修正 |
| TC-003 | 新規画面 | session_history 画面が追加 | +5% | 新規テストケース TC-AUTO-001 の実装を検討 |

### QA Readiness スコア変化
- **前回**: X% (バージョン: A.B.C)
- **今回**: Y% (バージョン: C.D.E)
- **変化**: +/-Z% ([理由：新規画面追加で +5%, 既存要素の信頼度低下で -3%])

### 推奨アクション（優先度順）
1. **影響度 HIGH のテストケースを再確認**
   - TC-001: home 画面要素が [HIGH] → [MED] に低下。タップ方法の自動選択が重要になります
   - TC-002: settings への遷移が削除。テストケースの操作意図を修正してください

2. **新規テストケースを追加**
   - session_history 画面が新規追加されました
   - 初回テスト実行前に新規テストケース TC-AUTO-001 を作成することを推奨します

3. **削除画面の関連テストケースをスキップ**
   - deprecated_feature 画面が削除されたため、TC-004 を `skip: true` に設定してください
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

### 0. 回帰テストモード判定

ユーザーの指示から回帰テストモードを判定:

```
if ユーザー指示に「回帰テスト」「regression」「差分テスト」:
  回帰テストモード = true
  Phase 0.5 (App Map 差分分析) を実行
  差分分析で影響テストケースを特定
else:
  回帰テストモード = false
  通常の実行計画策定へ
```

**回帰テストモード有効時の影響:**
- Phase 0.5 の差分分析結果を Phase 1-3 に反映
- 影響度 HIGH のテストケースを優先実行
- 影響度 LOW のテストケースはスキップオプション提示

### 1. テストケースの読み込みと App Map バージョン判定

- スイートファイルの「テストケース一覧」から各ファイルパスを取得
- 各ファイルを Read で読み込み
- フロントマターを解析
- app-map.md の存在確認（同一ディレクトリまたは親ディレクトリ）
- **App Map バージョン判定:**
  - app-map.md が存在する場合、フロントマターから `format_version` を確認
  - format_version < 4 の場合、Phase 0（QA Readiness 検査）の実行を推奨
  - version が存在しないまたは 2 世代以上古い場合も推奨
  - ユーザーが「QA Readiness を検査して」と明示的に要求した場合は必ず実行

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
