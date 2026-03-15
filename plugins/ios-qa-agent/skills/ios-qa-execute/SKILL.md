---
name: ios-qa-execute
description: テストケースの実行制御を行うフェーズスキル。各テストケースを qa-runner → qa-judge のパイプラインで実行し、アプリ状態管理と結果収集を担当する。ios-qa-workflow から参照される。
---

# QA 実行制御 — テストケース実行パイプライン

## テストケース実行パイプライン

各テストケースは以下のパイプラインで処理する:

### Step A: qa-runner（実行）

```
Agent(
  subagent_type: "ios-qa-agent:qa-runner",
  prompt: |
    以下のテストケースを実行してください。

    ## テストケース
    ### 前提状態
    {テストケースの前提状態}

    ### 操作意図
    {テストケースの操作意図}

    ## App Map (v4 フォーマット、信頼度情報付き)
    {app-map.md の全内容（あれば）}
    {
      例（v4 フォーマット）:
      ---
      format_version: 4
      qa_readiness_score: 72
      qa_readiness_level: Conditional
      last_verified: 2026-03-15
      ---
    }
    {なければ「App Map は利用不可。フル探索モードで進めてください」と記載}

    ## 信頼度情報の活用
    以下の信頼度に基づいて、操作方法を自動選択してください:
    - [HIGH]: label または id で即座にタップ
    - [MED]: label でタップを試み、失敗時は id にフォールバック
    - [LOW]: 最初から座標タップを使用

    ## 前提条件の達成手順（ヒント）
    {プリセットの steps を展開}

    ## 制限
    max_actions: 20
    timeout_seconds: {timeout}
    stuck_threshold: 3
)
```

**重要: 「期待結果」は qa-runner に渡さない（確認バイアス排除）**

**App Map v4 フォーマットの要点:**
- format_version: 4（信頼度情報をサポート）
- qa_readiness_score: 数値（0-100、[HIGH]/[MED]/[LOW] の割合を反映）
- qa_readiness_level: Low / Conditional / High（テスト実行推奨度）
- 各要素に信頼度 [HIGH]/[MED]/[LOW] が付与されている

### Step B: qa-judge（判定）

```
Agent(
  subagent_type: "ios-qa-agent:qa-judge",
  prompt: |
    以下のテスト結果を判定してください。

    ## 期待結果
    {テストケースの期待結果}

    ## 補足
    {テストケースの補足}

    ## 実行レポート
    {qa-runner の Execution Report 全文}
)
```

### Step C: 結果の記録

1. qa-judge の Judgment を results に追加
2. qa-runner の Execution Report から Discoveries セクションを抽出して保管（Phase 3.5 で集約用）

## アプリ状態管理（Phase 5：連続実行の安定化）

### テスト実行前の状態確認ステップ

各テストケース実行前に以下を実施:

1. **screenshot()** で現在画面を確認
2. 期待する開始画面と比較
3. 不一致の場合:
   - `stop_app_sim()` で停止
   - 2秒待機
   - `launch_app_sim()` で再起動
   - `screenshot()` で起動確認

### State Transition Hints（App Map 活用）

前テスト結果画面 → 次テスト開始画面への遷移ヒント:

1. App Map の Transitions セクションを参照
2. 「home に戻る」等の推奨操作を特定
3. 例:
   - session_active にいる → backButton タップで home に戻す
   - settings 画面 → navigationBar の戻るボタンで前画面に戻す
4. qa-runner の Execution Report に「状態遷移に必要な操作」を記載

### 再起動が必要な場合

- 前テストの Verdict が Fail
- 前テストの Runner Status が crashed
- 前テストと次テストの preconditions が大きく異なる
- screenshot() で確認したアプリ状態が期待状態と不一致

### 再起動不要な場合

- 前テストが Pass かつ次テストの preconditions が互換
- screenshot() で確認した状態が次テストの期待開始画面と一致

### 再起動の実行

```
screenshot() → 期待画面確認
if 不一致 or アプリクラッシュ:
  stop_app_sim()
  待機 2秒
  launch_app_sim()
  screenshot() で起動確認
```

## 依存テストの扱い（Phase 5：独立テストの Fail 後続行）

**depends_on がないテストの場合:**
- 前テストが Fail でも実行を続行
- 理由: 独立したテストケースとして扱う

**depends_on があるテストの場合:**
- 依存先テストが以下の場合 Skipped:
  - Fail → Skipped（理由: 依存先 [TC-XXX] が失敗）
  - Inconclusive → Skipped（理由: 依存先 [TC-XXX] が判定不能）
  - Skipped → Skipped（理由: 依存先 [TC-XXX] がスキップ）
- 依存先が Pass の場合：実行

## リトライの扱い

retry > 0 かつ Fail/Inconclusive の場合:
- アプリを再起動
- 同じテストケースを再実行（最大 retry 回）
- 最後の結果を採用

## 進捗報告（Phase 5：中途報告）

各テスト完了後に簡潔な進捗を親エージェント（ios-qa-workflow）に報告:

```
例: "TC-001: Pass (high) | TC-002: 実行中... | 残り 3 件"
```

**報告タイミング:**
- 各テスト完了時
- 5件以上のスイート実行時のみ（小規模スイートでは不要）

**報告内容:**
- TC ID
- Verdict（Pass / Fail / Inconclusive / Skipped）
- Priority（high / medium / low）
- 実行ステータス（完了 / 実行中 / Skipped）
- 残りテスト数
