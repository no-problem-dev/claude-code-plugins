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

### Phase 3: テストケース実行ループ（ios-qa-execute の知識を適用）

実行順序に従い、各テストケースを処理:

```
for each test_case:

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

全 runner の Discoveries を集約:

1. 全テストケースの Execution Report から Discoveries セクションを抽出
2. 既存 app-map.md がある場合:
   - 新規画面・遷移・要素とマージ
   - 重複排除（既知項目は追加しない）
3. app-map.md がない場合:
   - 新規作成（初期化モード）
4. サイズ制御:
   - 画面数: 20以内
   - 要素数: 1画面あたり10以内
5. メタデータ更新:
   - version をインクリメント
   - last_updated を現在時刻に更新
6. Write で app-map.md を保存

**実装注:** このフェーズはオプション。テストスイート実行時のみ適用。単一ケース実行時はスキップ。

### Phase 4: レポート生成（ios-qa-report の知識を適用）

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

## コンテキスト効率

| 要素 | トークン消費 |
|------|------------|
| テストケース読み込み | 200-500 / 件 |
| qa-runner 結果 | 500-1,000 / 件 |
| qa-judge 結果 | 300-500 / 件 |
| レポート生成 | 1,000-3,000 |
| **10件実行時の合計** | **約 13,000-23,000** |

UI 操作ログ（snapshot_ui × N）は qa-runner 内で完全消費。

## 重要: qa-runner への期待結果の非開示

qa-runner には「期待結果」を渡さない。
理由: runner が期待結果を知ると、それに合わせた報告をする確認バイアスが生じる。
runner は「やったこと」と「見えたもの」を客観的に報告する。
judge が独立して「期待通りだったか」を判定する。
