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

## アプリ状態管理

### 再起動が必要な場合

- 前テストの Verdict が Fail
- 前テストの Runner Status が crashed
- 前テストと次テストの preconditions が大きく異なる

### 再起動不要な場合

- 前テストが Pass かつ次テストの preconditions が互換

### 再起動の実行

```
stop_app_sim() → 2秒待機 → launch_app_sim()
→ screenshot() で起動確認
```

## 依存テストの扱い

depends_on で指定されたテストが:
- Pass → 実行
- Fail → Skipped（理由: 依存先 [TC-XXX] が失敗）
- Inconclusive → Skipped（理由: 依存先 [TC-XXX] が判定不能）
- Skipped → Skipped（理由: 依存先 [TC-XXX] がスキップ）

## リトライの扱い

retry > 0 かつ Fail/Inconclusive の場合:
- アプリを再起動
- 同じテストケースを再実行（最大 retry 回）
- 最後の結果を採用
