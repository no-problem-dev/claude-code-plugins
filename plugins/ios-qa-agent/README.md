# iOS QA Agent プラグイン

人間がスマホをポチポチして動作確認する作業を AI に委譲する。自律的な QA テスト実行エージェント。

## 概要

iOS アプリの QA を自動化するエージェントプラグイン。自然言語で書かれたテストケースを解釈し、XcodeBuildMCP で UI を操作し、期待結果を独立判定する。使うほどアプリの UI 構造を学習し、より効率的に動作するようになる。

### 設計の3大特徴

1. **意図ベーステスト**: テストコード不要。「何を確認するか」を自然言語で書くだけ
2. **実行と判定の分離**: qa-runner が操作・報告、qa-judge が独立判定。確認バイアスを排除
3. **自己進化**: テスト実行のたびに App Map（UI ナレッジ）が成長し、操作精度が向上

## ドキュメント

| ドキュメント | 内容 |
|------------|------|
| [はじめに](docs/getting-started.md) | セットアップ、最初のテスト、テストケースの書き方 |
| [設計思想](docs/philosophy.md) | 意図ベーステスト、確認バイアス排除、保守的判定 |
| [アーキテクチャ](docs/architecture.md) | システム構成、コンポーネント詳細、データフロー |
| [自己進化メカニズム](docs/self-evolution.md) | App Map、信頼度、Discoveries、Known Issues |
| [App Map 仕様](docs/app-map-spec.md) | ファイルフォーマット、サイズ制約、更新ルール |

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

## クイックスタート

```bash
# 1. XcodeBuildMCP セットアップ
brew tap getsentry/xcodebuildmcp && brew install xcodebuildmcp
claude mcp add XcodeBuildMCP -- xcodebuildmcp mcp

# 2. ui-automation 有効化（.xcodebuildmcp/config.yaml）
echo "enabledWorkflows:\n  - simulator\n  - ui-automation" > .xcodebuildmcp/config.yaml
```

詳しくは [はじめに](docs/getting-started.md) を参照。

## ライセンス

See LICENSE
