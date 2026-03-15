---
name: ios-qa-create
description: テストケースの作成を対話的に支援するユーティリティスキル。アプリの画面を観察しながらテストケースを生成できる。「テストケース作成」「QA ケース作成」「テスト項目作成」などのキーワードで自動適用。
---

# QA テストケース作成支援

## 作成方法

### A. 対話的作成

ユーザーの口頭説明からテストケースを生成:

1. 「何を確認したいか」をヒアリング
2. テストケース Markdown を生成
3. ユーザーにレビューを依頼
4. 承認後にファイルとして保存

### B. 画面観察からの作成

実行中アプリの画面を見てテストケースを提案:

1. xbm-ui-verify で現在の画面を観察
2. 画面の機能からテストケース候補を提案
3. ユーザーが選択・編集
4. ファイルとして保存

### C. 既存テストスイートへの追加

1. 既存の qa-suite.md を読み込み
2. 新しいテストケースを追加
3. ID を自動採番
4. スイートファイルのテストケース一覧を更新

### D. App Map からの自動生成

App Map のカバレッジ分析から、未テスト画面の自動テストケース提案:

1. app-map.md を読み込み、全画面と遷移パスを抽出
2. qa-suite.md と既存 TC-*.md を読み込み、現在のカバレッジを分析
3. カバレッジギャップを検出:
   - **未到達**: App Map にあるがどのテストの preconditions/操作意図にも含まれない画面
   - **未検証**: テスト中に通過するが期待結果の検証対象になっていない画面
   - **未発見**: App Map にまだ記録されていない画面
4. 各ギャップに対してテストケース候補を draft ステータスで生成
5. Priority を自動決定:
   - **critical**: home, session_active 等の中核画面
   - **high**: 複数画面を跨ぐ遷移パス、QA Issues 報告あり
   - **medium**: 個別画面の補助機能
6. depends_on を App Map の遷移グラフから自動推論
7. Operation Patterns を参照し、LLM アプリ固有パターンを補足に自動注入:
   - ストリーミング応答を伴う → 完了判定パターンを追加
   - 日本語入力を伴う → 入力パターンを追加
8. draft テストケースをユーザーに提示してレビュー依頼
9. 承認後にファイルとして保存し、qa-suite.md を更新

## テストケーステンプレート

```markdown
---
id: TC-[自動採番]
title: [ユーザーの意図を簡潔に]
priority: [ヒアリングで決定]
tags: [関連タグ]
preconditions: [必要なプリセット]
timeout_seconds: 120
---

# [title]

## 前提状態
[preconditions から自動生成 + ユーザー追加]

## 操作意図
[ユーザーの説明を自然言語で記述]

## 期待結果
[ユーザーの期待を箇条書きで整理]
[「内容は不問」「存在のみ検証」等の LLM アプリ向け注釈を適宜追加]

## 補足
[制約事項や特記事項]
```

## Draft ステータスの管理

モード D で自動生成されたテストケースは `status: draft` で作成:

```yaml
---
id: TC-AUTO-001
title: [自動生成]
status: draft
generated_from: app-map-v4
---
```

**draft テストケースの処理**:
- qa-suite.md に追加する際は `skip: true` を設定
- ユーザーレビュー後、status を `review` → `active` に遷移
- draft テストケースは実行対象外（CI スキップ）

## 作成のガイドライン

1. **操作手順ではなく意図を書く**: 「ボタンAをタップ」ではなく「設定画面を開く」
2. **期待結果は検証可能に**: 「正しく動く」ではなく「エラーメッセージが表示されない」
3. **LLM アプリの特性を考慮**: 確率的な応答は「存在のみ検証」と明記
4. **1テストケース1検証目的**: 複数の目的を混ぜない

## モード D の実装フロー

### ステップ 1: App Map の読み込みと解析

```
app-map.md の構造を想定:
- Screens セクション: 画面定義の一覧（id, name, type）
- Transitions セクション: 画面遷移グラフ（from, to, action, condition）
- Operation Patterns セクション: ストリーミング、日本語入力等の注釈
```

### ステップ 2: 既存テストケースのカバレッジ分析

qa-suite.md と TC-*.md から以下を抽出:
- 各テストケースの preconditions（どの画面から開始するか）
- 操作意図に記載された画面（どの画面を訪問するか）
- 期待結果で検証された画面状態

### ステップ 3: ギャップ検出

各画面に対し:
```
if 画面がどのテストケースの preconditions にも含まれない:
  → 未到達画面
elif 画面がテストの操作意図に含まれるが期待結果で検証されない:
  → 未検証画面
else:
  → カバー済み画面
```

### ステップ 4: テストケース候補の生成

各ギャップに対して以下の情報を含む draft テストケースを生成:

**必須フィールド**:
- id: TC-AUTO-[採番]
- title: 画面名 + 主要操作の説明
- priority: critical/high/medium (下記を参照)
- tags: 画面カテゴリ、操作タイプ
- preconditions: App Map から推論（どの画面から到達するか）
- depends_on: 前提テストケース（App Map の遷移から推論）

**Priority 決定アルゴリズム**:
```
base_priority = "medium"

if 画面が {home, session_active, conversation}:
  base_priority = "critical"
elif 画面が複数の他画面から参照されている:
  base_priority = "high"

if App Map で複数画面を跨ぐ遷移:
  priority += 1 段階

if QA Issues で報告されている:
  priority += 1 段階

最終 priority = max("critical", base_priority)
```

**depends_on の推論**:
```
App Map の Transitions グラフから逆算:
- 対象画面に到達するには必ずどの画面経由か
- その画面を確認するテストケースを depends_on に追加
例: model_select → session_setup 経由 → depends_on: TC-session-setup
```

**Operation Patterns の自動注入**:
```
if 操作対象がストリーミング応答を伴う:
  補足に「完了判定: response_complete イベントの発火を確認」を追加

if 操作対象が日本語入力を伴う:
  補足に「入力パターン: 平仮名、漢字、記号を含む複合入力を検証」を追加
```

### ステップ 5: ユーザーレビューと承認

draft テストケース候補を列挙し、以下の情報とともに提示:

```
## App Map カバレッジ分析結果

### 未到達画面（テストで訪問したことがない）
- TC-AUTO-001: [画面名] [理由]
- TC-AUTO-002: [画面名] [理由]

### 未検証画面（訪問するがテストしていない）
- TC-AUTO-003: [画面名] [検証すべき内容]

### ギャップ統計
- App Map 総画面数: N
- カバー済み: M
- カバレッジ率: M/N %
- 提案テストケース数: K
```

各候補テストケースの内容をレビュー待ち状態で提示。
ユーザーの承認 / 却下 / 編集を受け付ける。

### ステップ 6: テストケースファイルの生成と登録

承認されたテストケースについて:
1. TC-AUTO-[採番].md ファイルを生成
2. qa-suite.md の test_cases セクションに以下の形式で追加:

```yaml
- id: TC-AUTO-001
  path: ./test-cases/TC-AUTO-001.md
  skip: true  # draft テストケースは実行対象外
  status: draft
  generated_from: app-map-v4
```

3. ユーザーに確認を提示
4. 最終承認後に qa-suite.md を更新
