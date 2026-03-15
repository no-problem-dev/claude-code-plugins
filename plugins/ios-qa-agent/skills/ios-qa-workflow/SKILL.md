---
name: ios-qa-workflow
description: AI QA Agent のメインオーケストレーター。テストスイートまたは個別テストケースの QA を段階的に実行する。フェーズスキルに委譲して段階的開示を行い、サブエージェントでコンテキスト隔離を実現する。「QA」「動作確認」「テストケース実行」「smoke test」「E2E」「手動テスト」「結合テスト」などのキーワードで自動適用。
---

# iOS QA ワークフロー — メインオーケストレーター

人間がスマホをポチポチして動作確認する作業を AI に委譲する。

## 設計原則

1. **段階的開示** — フェーズスキルを必要な時にのみロード
2. **コンテキスト隔離** — UI 操作ログはサブエージェント内で消費
3. **実行と判定の分離** — qa-runner が実行、qa-judge が独立判定
4. **保守的判定** — 偽 Pass 防止。迷ったら Inconclusive

## フェーズ構成

Phase 0: QA Readiness 検査（条件付き） → ios-qa-prepare スキルで判定し、必要に応じて実行
Phase 1: 準備 → ios-qa-prepare スキルの知識で実行
Phase 2: テスト実行 → ios-qa-execute スキルの知識で実行
Phase 3: レポート → ios-qa-report スキルの知識で実行

## 起動方法

### テストスイート実行

「QA を実行して tests/qa-suite.md」
「動作確認して tests/cases/」

### 単一テストケース実行

「このテストケースを実行して tests/cases/TC-001.md」

### インライン実行

「アプリを起動して、メッセージが送信できるか確認して」
→ テストケースを即興で構築して実行

## ワークフロー

### Phase 0 (ホーム): 回帰テストモード判定

**実行タイミング:** ワークフロー開始時

ユーザー指示を解析し、回帰テストモードを判定:

```
REGRESSION_MODE = false

if ユーザー指示に以下のキーワード:
  - "回帰テスト"
  - "regression test"
  - "regression"
  - "差分テスト"
  - "差分確認"
THEN
  REGRESSION_MODE = true
  通知: "回帰テストモードで実行します。App Map 差分分析を先に実施します。"
END IF
```

**回帰テストモード有効時の処理:**

1. Phase 0.5（ios-qa-prepare の App Map 差分分析）を実行
2. 差分分析レポートを出力
3. 影響テストケースを抽出
4. 以下のいずれかをユーザーに提示:
   - **オプション A**: 影響テストケースのみを実行（高速回帰テスト）
   - **オプション B**: 影響テストケース + 全テストスイート実行（完全回帰テスト）
   - **オプション C**: すべてをスキップし、差分分析レポートのみ出力

### Phase 0: QA Readiness 検査（条件付き実行）

以下のいずれかに該当する場合、Phase 0 を実行:
- app-map.md が存在しない
- App Map の format_version が 2 世代以上古い（format_version < 4）
- ユーザーが明示的に「QA Readiness を検査して」と要求

**Phase 0 の内容:**

1. 検査用テストケースを自動構築（「全主要画面を巡回し、主要要素を確認する」）
2. qa-runner を Full Exploration Mode で起動し、各画面の QA Readiness を観察
3. Execution Report から QA Readiness Observations を抽出
4. Extended Discoveries を分析し、QA Readiness Score を計算:
   - 要素識別性（[HIGH]/[MED]/[LOW] の割合）
   - 操作可能性（目に見える変化の有無）
   - 状態観測性（snapshot_ui で検出可能な割合）
5. スコア < 50% → 警告出力、テスト推奨しない旨を報告
6. スコア >= 50% → Phase 1 以降に進行
7. App Map v4 フォーマットで生成し、QA Readiness Summary をフロントマターに含める

**QA Readiness Score の計算式:**
```
スコア = (HIGH要素率 × 40% + MED要素率 × 30% + 操作可能性 × 20% + 状態観測性 × 10%) × 100
```

### Phase 1: 準備（ios-qa-prepare の知識を適用）

1. テストスイート or テストケースを Read で読み込む
2. app-map.md の存在確認（あれば Read で読み込み、qa-runner に提供）
3. 前提条件プリセットを解決
4. 依存関係を解決し、実行順序を決定（トポロジカルソート）
5. skip: true のケースを除外

### Phase 2: アプリのビルド & 起動

ios-dev プラグインがある場合:
  Agent(subagent_type: "ios-dev:xbm-run", prompt: "ビルドして実行。scheme: <scheme>")

ない場合:
  ToolSearch("select:mcp__XcodeBuildMCP__build_run_sim")
  build_run_sim(scheme: "<scheme>")

scheme / simulator 情報を記憶。

### Phase 2.5: App Map 一括注入の効率化（Phase 5）

App Map 注入をワンタイムで実施:

1. Phase 1 で app-map.md を Read したら、メモリ（コンテキスト）に保存
2. Phase 3 ループ内で全テストケースの qa-runner prompt に同じ App Map を注入
3. テストごとに Read し直さない（トークン効率向上）

メリット:
- トークン削減: Read × テスト数 を削減
- 一貫性: 全テストが同じ App Map バージョンで実行

### Phase 3: テストケース実行ループ（ios-qa-execute の知識を適用）

実行順序に従い、各テストケースを処理。回帰テストモード有効時は影響テストケースを優先:

```
# 回帰テストモード: 影響テストケース優先
if REGRESSION_MODE:
  affected_tests = Phase 0.5 の差分分析から抽出
  test_execution_order = [
    *affected_tests (優先度順),
    *remaining_tests (元の優先度順)
  ]
else:
  test_execution_order = 元の優先度順

for each test_case in test_execution_order:

  # 回帰テストモード: 変更なしテストをスキップ提案
  if REGRESSION_MODE and test_case not in affected_tests:
    if ユーザー指示が「影響テストケースのみ」:
      Skip（理由: App Map 差分なし）
      continue

  # 依存チェック
  if depends_on が Fail/Inconclusive → Skipped

  # アプリ状態リセット判断
  if 前テストが Fail or preconditions が非互換 → アプリ再起動

  # Step A: qa-runner で実行
  Agent(
    subagent_type: "ios-qa-agent:qa-runner",
    prompt: |
      以下のテストケースを実行してください。

      ## テストケース
      {前提状態 + 操作意図のみ。期待結果は渡さない}

      ## 前提条件の達成手順（ヒント）
      {プリセットの steps}

      ## 制限
      max_actions: 20, timeout_seconds: {timeout}, stuck_threshold: 3
  )
  → Execution Report を受け取る

  # Step B: qa-judge で判定
  Agent(
    subagent_type: "ios-qa-agent:qa-judge",
    prompt: |
      以下のテスト結果を判定してください。

      ## 期待結果
      {テストケースの期待結果セクション}

      ## 補足
      {テストケースの補足セクション}

      ## 実行レポート
      {qa-runner の Execution Report 全文}
  )
  → Judgment を受け取る

  results.append(judgment)
```

### Phase 3.5: App Map 更新（オプション）

全 runner の Discoveries を集約し、App Map v4 フォーマットで更新:

1. 全テストケースの Execution Report から Discoveries セクションを抽出
2. 既存 app-map.md がある場合:
   - 新規画面・遷移・要素とマージ
   - 重複排除（既知項目は追加しない）
   - 信頼度情報を更新（QA Readiness Observations を反映）
3. app-map.md がない場合:
   - 新規作成（初期化モード、Phase 0 で生成したものを更新）
4. **App Map v4 フォーマットで出力:**
   - フロントマター: `format_version: 4`
   - QA Readiness Summary を含める（スコア、レベル、日時）
   - 各要素に信頼度 [HIGH]/[MED]/[LOW] を付与
   - 各画面に `verified: YYYY-MM-DD` タイムスタンプを記録
5. サイズ制御:
   - 画面数: 20以内
   - 要素数: 1画面あたり10以内
6. メタデータ更新:
   - format_version を 4 に統一
   - version をインクリメント
   - last_updated を現在時刻に更新
   - qa_readiness_score と qa_readiness_level を更新
7. Write で app-map.md を保存

**実装注:** このフェーズはオプション。テストスイート実行時のみ適用。単一ケース実行時はスキップ。

### Phase 3.5: 全体タイムアウト管理（Phase 5：連続実行の安定化）

全テストスイート実行に対する全体タイムアウトを設定:

**設定値:**
- デフォルト: 900秒（15分）
- ユーザーが指定した場合はそれを使用

**タイムアウト判定ロジック:**
```
for each test_case in remaining_tests:
  elapsed_time = 現在時刻 - 実行開始時刻
  remaining_time = total_timeout - elapsed_time

  # 残りテストの平均実行時間を推定
  avg_time_per_test = 3分（デフォルト推定値）
  estimated_remaining_time = avg_time_per_test × len(remaining_tests)

  if estimated_remaining_time > remaining_time:
    # 時間不足の場合、残りテストを Skipped にする
    for test in remaining_tests:
      result.append(Skipped, reason: "全体タイムアウトによるスキップ")
    break
  else:
    # テスト実行を続行
    run_test(test_case)
```

**警告メッセージ:**
```
実行時間が圧迫しています。残り 10分で 5 件のテストが残っています。
以下のテストをスキップします: TC-004, TC-005
```

### Phase 4: 中間レポート（Phase 5：5件超の場合）

テストスイート内に 5 件を超えるテストがある場合、5 件ごとに中間サマリーを出力:

**中間サマリーの内容:**
```
## 中間レポート（TC-001 ~ TC-005）

| TC-ID | 結果 | Priority | 実行時間 |
|-------|------|----------|---------|
| TC-001 | Pass | critical | 45s |
| TC-002 | Pass | high | 52s |
| TC-003 | Fail | medium | 38s |
| TC-004 | Skipped | high | - |
| TC-005 | Inconclusive | medium | 55s |

**累計:** 3 Pass, 1 Fail, 1 Inconclusive, 1 Skipped / 実行時間: 190s

---
```

**出力タイミング:**
- TC-005 完了時：「中間レポート（TC-001 ~ TC-005）」
- TC-010 完了時：「中間レポート（TC-006 ~ TC-010）」
- 最後は Phase 5（最終レポート）で全体サマリー

### Phase 5: レポート生成（ios-qa-report の知識を適用）

全テスト結果を集約してレポートを出力。

## テスト間のアプリ状態管理

再起動する場合:
- 前テストが Fail（アプリが不正状態の可能性）
- preconditions が前テストの結果と非互換

再起動しない場合:
- 前テストが Pass かつ次テストの preconditions が互換

再起動方法:
```
ToolSearch("select:mcp__XcodeBuildMCP__stop_app_sim,mcp__XcodeBuildMCP__launch_app_sim")
stop_app_sim() → launch_app_sim()
```

## コンテキスト効率（Phase 5：App Map 一括注入）

| 要素 | トークン消費 | 最適化前 | 最適化後 | 削減量 |
|------|------------|---------|---------|-------|
| App Map 読み込み | 300-600 × 1回 | 300-600 × N件 | 300-600 × 1回 | N-1 回分削減 |
| テストケース読み込み | 200-500 / 件 | 変わらず | 変わらず | - |
| qa-runner 結果 | 500-1,000 / 件 | 変わらず | 変わらず | - |
| qa-judge 結果 | 300-500 / 件 | 変わらず | 変わらず | - |
| レポート生成 | 1,000-3,000 | 変わらず | 変わらず | - |
| **10件実行時の合計** | **約 13,000-23,000** | - | **約 12,800-22,400** | **約 200-600（1回分）** |

UI 操作ログ（snapshot_ui × N）は qa-runner 内で完全消費。

**Phase 5 での効率化:**
- App Map の一括注入で 1回分の Read トークンを削減
- 中間レポートは 5件超の大規模スイートでのみ実施（小規模スイートではレポート生成量は変わらず）

## 重要: qa-runner への期待結果の非開示

qa-runner には「期待結果」を渡さない。
理由: runner が期待結果を知ると、それに合わせた報告をする確認バイアスが生じる。
runner は「やったこと」と「見えたもの」を客観的に報告する。
judge が独立して「期待通りだったか」を判定する。
