# はじめに

## セットアップ

### 1. XcodeBuildMCP のインストール

```bash
brew tap getsentry/xcodebuildmcp && brew install xcodebuildmcp
claude mcp add XcodeBuildMCP -- xcodebuildmcp mcp
```

### 2. ui-automation の有効化

プロジェクトのルートまたは Claude Code の作業ディレクトリに `.xcodebuildmcp/config.yaml` を作成:

```yaml
enabledWorkflows:
  - simulator
  - ui-automation
```

**重要**: config.yaml は Claude Code のセッション開始時の作業ディレクトリに配置する必要がある。MCP サーバーは起動時の cwd から config を読む。

### 3. プラグインのインストール

```bash
claude plugin add ios-qa-agent
```

### 4. 動作確認

Claude Code で以下を実行:

```
アプリを起動して、画面の状態を確認して
```

XcodeBuildMCP の `snapshot_ui` と `screenshot` が動作すれば準備完了。

## 最初のテスト実行

### テストケースを書く

`tests/cases/TC-001-example.md` を作成:

```markdown
---
id: TC-001
title: アプリが起動してホーム画面が表示される
priority: critical
preconditions: [app_launched]
timeout_seconds: 60
---

# アプリが起動してホーム画面が表示される

## 前提状態
- アプリがインストール済み

## 操作意図
アプリを起動する。

## 期待結果
- アプリがクラッシュせずに起動する
- ホーム画面が表示される
- 何らかの UI 要素（ボタン、テキスト等）が表示される
```

### テストスイートを作る

`tests/qa-suite.md` を作成:

```markdown
---
suite: My App QA
app_scheme: MyApp
app_project_path: .
precondition_presets:
  app_launched:
    description: アプリが起動している
    steps: build_run_sim でアプリを起動する
---

# My App QA

## テストケース
- cases/TC-001-example.md
```

### 実行

```
QA を実行して tests/qa-suite.md
```

初回実行では App Map が存在しないため、qa-runner がフル探索モードで動作し、画面構造を Discoveries として報告する。完了後に `tests/app-map.md` が自動生成される。

2回目以降は App Map を活用して高速に実行される。

## テストケースの書き方ガイド

### 基本原則: 「What」を書く、「How」は書かない

```
❌ 画面右上の + ボタンをタップして、テキストフィールドに "hello" と入力して...
✅ 新規メッセージを作成し、テキストを入力して送信する。
```

### 前提状態

テスト開始時に満たされているべき状態:

```markdown
## 前提状態
- ユーザーがログイン済み
- ホーム画面が表示されている
```

### 操作意図

何をするか。具体的な UI 操作ではなく、ユーザーの意図:

```markdown
## 操作意図
設定画面からプロフィールを編集し、名前を変更する。
```

### 期待結果

操作後にどうなっているべきか。検証可能な形で:

```markdown
## 期待結果
- プロフィール画面に新しい名前が表示されている
- 変更が保存された旨のフィードバック（トーストやアラート）が表示される
```

### 補足

テスト固有の注意事項:

```markdown
## 補足
- AI アプリの場合、応答内容は確率的なため「存在のみ検証」
- ネットワーク不要のオフラインテストではない
```

### LLM アプリのテストケース

LLM アプリでは応答が毎回異なる。テストでは:

- **内容ではなく存在を検証**: 「AI の応答テキストが表示される（内容は不問）」
- **構造を検証**: 「応答がストリーミング完了している（ローディングが消えている）」
- **エラーの不在を検証**: 「エラーメッセージが表示されていない」

## テストスイートの構成

```
tests/
├── qa-suite.md            # スイート定義（プリセット、テストケース一覧）
├── app-map.md             # App Map（自動生成・更新）
└── cases/
    ├── TC-001-*.md
    ├── TC-002-*.md
    └── ...
```

### precondition_presets

繰り返し使う前提条件をプリセットとして定義:

```yaml
precondition_presets:
  app_launched:
    description: アプリが起動している
    steps: build_run_sim でアプリを起動する
  logged_in:
    description: ログイン済み
    depends_on: [app_launched]
    steps: |
      ログイン画面が表示されたら:
      - サインインボタンをタップ
      - 認証フローを完了
```

### depends_on

テストケース間の依存関係:

```yaml
---
id: TC-002
depends_on: [TC-001]
---
```

TC-001 が Pass でなければ TC-002 は Skipped になる。

## 実行モード

### 通常実行

```
QA を実行して tests/qa-suite.md
```

### 単一テスト

```
tests/cases/TC-001.md を実行して
```

### インライン（ファイルなし）

```
アプリを起動して、設定画面が開けるか確認して
```

### 回帰テスト

```
回帰テストを実行して tests/qa-suite.md
```

App Map の変更差分を分析し、影響を受けるテストケースを優先実行する。

### テストケース自動生成

```
App Map からテストケースを提案して
```

App Map のカバレッジ分析を実行し、未テスト画面のテストケースを draft で生成。
