# iOS QA Agent プラグイン

人間がスマホをポチポチして動作確認する作業を AI に委譲する。自律的な QA テスト実行エージェント。

## 概要

iOS アプリの QA を自動化するエージェントプラグイン。自然言語で書かれたテストケースを解釈し、XcodeBuildMCP で UI を操作し、期待結果を独立判定する。

### 設計の3大特徴

1. **段階的開示**: フェーズごとにスキルを分割。必要な知識を必要な時にのみロード
2. **実行と判定の分離**: qa-runner が操作・報告、qa-judge が独立判定。確認バイアスを排除
3. **コンテキスト隔離**: UI 操作ログはサブエージェント内で完全消費。親のコンテキストに流出しない

## 使い方

### テストスイート実行

```
QA を実行して tests/qa-suite.md
```

### 単一テストケース実行

```
このテストケースを実行して tests/cases/TC-001.md
```

### インライン実行

```
アプリを起動して、メッセージが送信できるか確認して
```

## 構成

### エージェント（2つ）

| エージェント | 責務 |
|----------|------|
| **qa-runner** | テストケース実行。UI 操作と状態観察。判定しない |
| **qa-judge** | 独立判定。runner の報告と期待結果を照合。Pass/Fail/Inconclusive を判定 |

### スキル（5つ）

| スキル | 責務 |
|--------|------|
| **ios-qa-workflow** | メインオーケストレーター。3フェーズを統合制御 |
| **ios-qa-prepare** | Phase 1: テストスイート解析・実行計画 |
| **ios-qa-execute** | Phase 2: テストケース実行制御・アプリ状態管理 |
| **ios-qa-report** | Phase 3: レポート生成 |
| **ios-qa-create** | ユーティリティ: テストケース作成支援 |

## 実行フロー

```
ユーザー → ios-qa-workflow（オーケストレーター）
  ├─ Phase 1: 準備（ios-qa-prepare）
  │  └─ テストスイート解析 → 実行計画
  ├─ Phase 2: 実行（ios-qa-execute）
  │  └─ 各テストケース:
  │      ├─ qa-runner（実行） → Execution Report
  │      └─ qa-judge（判定） → Judgment
  └─ Phase 3: レポート（ios-qa-report）
     └─ 全結果を集約 → QA Report
```

## テストケースの書き方

テストケースは Markdown + YAML フロントマター形式。

```markdown
---
id: TC-001
title: ログイン画面でメールアドレスを入力できる
priority: critical
tags: [auth, ui]
preconditions: [app_launched]
timeout_seconds: 120
---

# ログイン画面でメールアドレスを入力できる

## 前提状態
- アプリが起動している
- ログイン画面が表示されている

## 操作意図
1. メールアドレス入力フィールドをタップする
2. テストメールアドレスを入力する

## 期待結果
- メールアドレス入力フィールドにテキストが表示される
- フィールドはアクティブ（カーソルが表示）

## 補足
- 複雑なバリデーションのテストではない。入力可能性のみを確認
```

## App Map 機構

### 概要

**App Map** は、テストで発見した画面・要素・遷移を自動集約するナレッジベース。

- テスト実行時に `Discoveries` として新規発見を報告
- Phase 3.5 で自動マージして app-map.md を更新
- 次回以降のテストで qa-runner が App Map を参考情報として活用
- フル探索 → 段階的な効率化を実現

### ファイル形式

```markdown
---
version: 1.0.0
last_updated: YYYY-MM-DD HH:MM
screens_count: N
elements_per_screen_avg: M
---

# App Map

## スクリーン一覧

### [スクリーン名]
- **識別条件**: [識別パターン・判定ロジック]
- **主要素**:
  - [要素名] ([タイプ]): [説明]

## 遷移グラフ

[スクリーン A] —tap "Button B"→ [スクリーン C]

## Operation Patterns

### [パターン名]
[操作の効率的な手順]
```

### 使用方法

1. **qa-runner が参照**: App Map セクションの識別条件・主要素・遷移グラフ・Operation Patterns を参考に効率化
2. **Discoveries 報告**: App Map に未記録の発見のみを報告（重複排除）
3. **自動更新**: Phase 3.5 で全 Discoveries をマージ

## セットアップ

### 前提条件

- XcodeBuildMCP がインストール済み
- claude mcp add で登録済み
- ui-automation ワークフロー設定が有効

### インストール

```bash
claude plugin add ios-qa-agent
```

## トラブルシューティング

### qa-runner が MCP ツールを見つからない

```
Error: ToolSearch で mcp__XcodeBuildMCP__* が見つからない
```

**対処**: 
- XcodeBuildMCP が claude mcp add で登録されているか確認
- config.yaml で ui-automation が enabled: true か確認

### qa-judge が Inconclusive で返す

```
Verdict: Inconclusive (Key UI Elements 不足 or 品質チェック Fail)
```

**対処**:
- qa-runner の Final State を確認
- Key UI Elements が期待結果の検証に必要な要素を含んでいるか確認
- 以下の品質チェックポイントを確認:
  - 操作結果の要素が含まれているか（例：userMessage バブル）
  - 状態変化の要素が含まれているか（例：ボタン有効/無効）
  - ストリーミング操作時に ActivityIndicator の有無が明記されているか

### テスト間でアプリの状態が異なる

```
TC-002 が TC-001 の状態に依存しているが、思わぬ状態になっている
```

**対処**:
- TC-002 の preconditions が TC-001 の結果状態と非互換
- ios-qa-execute でアプリ再起動を強制する（preconditions を大きく変える）
- または TC-002 が TC-001 に depends_on を指定する

## コンテキスト効率

10件のテストケース実行時のトークン消費:

| 要素 | 消費量 |
|------|--------|
| テストケース読み込み | 200-500/件 |
| qa-runner 結果 | 500-1,000/件 |
| qa-judge 結果 | 300-500/件 |
| レポート生成 | 1,000-3,000 |
| **合計** | **13,000-23,000** |

UI 操作ログ（snapshot_ui × 多数）はサブエージェント内で完全消費。

## 設計の哲学

### なぜ実行と判定を分離するか

実行者（runner）が判定も行うと確認バイアスが生じる。「期待通りに動いたはず」と判断しがち。
独立した判定者（judge）が新鮮なコンテキストで客観的に判定することで、偽 Pass を防ぐ。

### なぜスキルを5つに分割するか

1つの大きなスキルにまとめると、コンテキストが肥大化し、フェーズ間の知識が混在する。
フェーズごとにスキルを分けることで、段階的開示を実現。必要な知識を必要な時にロード。

### なぜ期待結果を runner に渡さないか

runner が期待結果を知ると、それに合わせた報告をするバイアスがかかる。
runner は「やったこと・見えたもの」を客観的に報告し、judge が独立判定する。

## ライセンス

See LICENSE

## サポート

問題発見時は GitHub Issues で報告してください。
