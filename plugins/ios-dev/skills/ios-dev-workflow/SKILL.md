---
name: ios-dev-workflow
description: iOS 開発ワークフローのオーケストレーター。XcodeBuildMCP ベースのフォアグラウンドサブエージェントを使い分け、ビルド・テスト・実行・UI 検証をコンテキスト隔離で実行する。「iOS」「Xcode」「Swift」「build」「test」「compile」「simulator」「xcodebuild」「preview」「SwiftUI」「ビルド」「テスト」「コンパイル」などのキーワードで自動適用。
---

# iOS 開発ワークフロー（v3.0 — XcodeBuildMCP + サブエージェント隔離）

XcodeBuildMCP の MCP ツールをフォアグラウンドサブエージェント経由で呼び出し、
ビルドログ等のコンテキスト消費をサブエージェント内に隔離する。

## 設計原則

1. **XcodeBuildMCP 必須** — CLI フォールバックなし。未設定時はエラー返却
2. **フォアグラウンドサブエージェント** — MCP ツールにアクセス可能。バックグラウンドは不可
3. **コンテキスト隔離** — ビルドログ・テストログはサブエージェント内で消費、親にはサマリーのみ
4. **結果駆動** — 途中の推論は不要。成功/失敗 + エラー詳細のみが価値
5. **セッションキャッシュ** — scheme/simulator は初回で確定し、以降は prompt 経由で渡す

## プロジェクトコンテキストのキャッシュ戦略

**毎回のスキーム・シミュレータ検出を避けるため、2層のキャッシュを活用する:**

### 層 1: XcodeBuildMCP セッションデフォルト（MCP サーバー内）

`session_set_defaults` で設定された scheme/simulator/workspace は、
同一 MCP セッション内の全ツール呼び出しで自動適用される。
サブエージェントも同じ MCP サーバーを共有するため、一度設定すれば全サブエージェントで有効。

### 層 2: オーケストレーターの prompt 引き渡し（確実な引き継ぎ）

初回のビルド/テストで判明した scheme/simulator をメインコンテキストで記憶し、
以降のサブエージェント起動時に prompt に含める。
サブエージェントは prompt に scheme が含まれていれば、
`session_show_defaults` すら呼ばずに即実行できる。

### 初回フロー（プロジェクトコンテキスト未確定時）

```
1. xbm-project-setup を起動
   → プロジェクト検出 + session_set_defaults + 結果返却
2. 返却された scheme/simulator をメインコンテキストで記憶
3. 以降のサブエージェント起動時に prompt に含める
```

### 2回目以降のフロー（高速パス）

```
1. メインコンテキストで記憶済みの scheme/simulator を prompt に含めて起動
   → サブエージェントは discover/list をスキップして即実行
```

## サブエージェント一覧

| エージェント | 責務 | 使いどころ |
|-------------|------|-----------|
| **xbm-build** | ビルド実行 & エラー報告 | 「ビルドして」「コンパイルして」 |
| **xbm-test** | テスト実行 & 結果報告 | 「テストして」「テスト走らせて」 |
| **xbm-run** | ビルド & シミュレータ実行 & スクショ | 「実行して」「動かして」「見せて」 |
| **xbm-project-setup** | プロジェクト検出 & セッション設定 | 初回 / 「スキーム教えて」 |
| **xbm-ui-verify** | UI 検証（スクショ + ビュー階層 + 操作） | 「画面確認して」「ボタン押して」 |

## タスク判定 → サブエージェント振り分け

### ビルド要求
- キーワード: build, compile, ビルド, コンパイル
- → **xbm-build** をフォアグラウンドで起動

```
Agent(
  subagent_type: "ios-dev:xbm-build",
  prompt: "ビルドしてください。\nプロジェクトパス: /path/to/project\nスキーム: MyApp\nシミュレータ: iPhone 16 Pro"
)
```

**重要: scheme/simulator が判明済みなら必ず prompt に含める。**
未確定の場合は「スキーム: 自動検出」とし、サブエージェントに検出を任せる。

### テスト要求
- キーワード: test, テスト, XCTest
- → **xbm-test** をフォアグラウンドで起動

```
Agent(
  subagent_type: "ios-dev:xbm-test",
  prompt: "テストを実行してください。\nプロジェクトパス: /path/to/project\nスキーム: MyApp\n対象テスト: 全テスト"
)
```

### ビルド & 実行要求
- キーワード: run, 実行, 動かして, launch
- → **xbm-run** をフォアグラウンドで起動

```
Agent(
  subagent_type: "ios-dev:xbm-run",
  prompt: "ビルドしてシミュレータで実行してください。\nプロジェクトパス: /path/to/project\nスキーム: MyApp\nスクリーンショット: yes"
)
```

### プロジェクト情報要求 / 初回セットアップ
- キーワード: scheme, スキーム, simulator, プロジェクト構成
- または初回のビルド/テスト要求時に scheme が未確定の場合
- → **xbm-project-setup** をフォアグラウンドで起動

```
Agent(
  subagent_type: "ios-dev:xbm-project-setup",
  prompt: "プロジェクトを検出し、セッションデフォルトを設定してください。\nプロジェクトパス: /path/to/project"
)
```

**xbm-project-setup の結果から scheme/simulator を記憶し、以降の prompt に含める。**

### UI 検証要求
- キーワード: 画面確認, スクショ, screenshot, UI 確認, タップ
- → **xbm-ui-verify** をフォアグラウンドで起動

## コード変更後の自動フィードバックループ

```
1. コード変更完了
   ↓
2. xbm-build（scheme を prompt で渡す → 即ビルド）
   ↓ 成功
3. xbm-test（scheme を prompt で渡す → 即テスト）
   ↓ 全パス
4. 完了報告
   ↓ 失敗
5. エラー分析 → コード修正 → Step 2 に戻る
```

2回目以降のループでは scheme/simulator が確定済みなので、
各サブエージェントは discover/list をスキップして即実行する。

## 他のスキルとの関係

| スキル | 用途 | このワークフローとの関係 |
|--------|------|----------------------|
| **ios-diagnostics** | エラー・警告の簡易チェック | xbm-build を使用 |
| **ios-preview-repl** | SwiftUI プレビュー・REPL・Apple ドキュメント | Xcode ネイティブ MCP（別系統） |
| **ios-project-info** | プロジェクト情報表示 | xbm-project-setup に委譲 |
| **ios-maintenance** | クリーン・シミュレータ管理 | XcodeBuildMCP の clean / sim 管理ツール使用 |

## XcodeBuildMCP セットアップ

未設定の場合、サブエージェントがエラーを返す。以下を案内:

```bash
# インストール
brew tap getsentry/xcodebuildmcp && brew install xcodebuildmcp

# Claude Code に MCP サーバーとして登録
claude mcp add XcodeBuildMCP -- xcodebuildmcp mcp
```

## 関連プラグイン

- **ios-architecture**: iOS クリーンアーキテクチャの設計原則
- **swift-design-system**: Swift Design System を使った UI 実装
