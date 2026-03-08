# ios-dev v3.0

XcodeBuildMCP ベースの iOS 開発ワークフロー。フォアグラウンドサブエージェントによるコンテキスト隔離設計。

## 前提条件

XcodeBuildMCP が MCP サーバーとして登録されていること:

```bash
# インストール
brew tap getsentry/xcodebuildmcp && brew install xcodebuildmcp

# MCP サーバー登録
claude mcp add XcodeBuildMCP -- xcodebuildmcp mcp
```

CLI フォールバックはありません。XcodeBuildMCP が必須です。

## 設計思想

ビルド・テスト等の重い MCP 操作は**フォアグラウンドサブエージェント**に委譲し、
ビルドログ等のコンテキスト消費をサブエージェント内に隔離する。
メインコンテキストには構造化されたサマリーのみが返却される。

## サブエージェント

| エージェント | 責務 | モデル |
|-------------|------|--------|
| **xbm-build** | ビルド実行 & エラー報告 | Sonnet |
| **xbm-test** | テスト実行 & 結果報告 | Sonnet |
| **xbm-run** | ビルド & シミュレータ実行 & スクショ | Sonnet |
| **xbm-project-setup** | プロジェクト検出 & セッション設定 | Sonnet |
| **xbm-ui-verify** | UI 検証（スクショ + ビュー階層 + 操作） | Sonnet |

### 使用例

```
「ビルドして」
  → xbm-build が XcodeBuildMCP でビルド → サマリー返却

「テストして」
  → xbm-test が XcodeBuildMCP でテスト → 結果サマリー返却

「実行して画面見せて」
  → xbm-run がビルド・起動・スクショ → 画像付きサマリー返却

「スキーム一覧教えて」
  → xbm-project-setup がプロジェクト情報取得 → 構造化情報返却
```

## スキル

| スキル | 用途 |
|--------|------|
| **ios-dev-workflow** | オーケストレーター（サブエージェント振り分け） |
| **ios-diagnostics** | エラー・警告チェック（xbm-build に委譲） |
| **ios-preview-repl** | SwiftUI プレビュー・REPL・Apple ドキュメント（Xcode ネイティブ MCP） |
| **ios-project-info** | プロジェクト情報（xbm-project-setup に委譲） |
| **ios-maintenance** | クリーン・シミュレータ管理（軽量 MCP 直接呼び出し） |

## 推奨ワークフロー

```
コード変更
    |
xbm-build（ビルド）
    | 成功
xbm-test（テスト）
    | 全パス
完了
    | 失敗
エラー分析 → コード修正 → 再ビルド
```

## プラグイン構成

```
ios-dev/
├── .claude-plugin/
│   └── plugin.json
├── agents/
│   ├── xbm-build.md           # ビルド実行
│   ├── xbm-test.md            # テスト実行
│   ├── xbm-run.md             # ビルド & 実行
│   ├── xbm-project-setup.md   # プロジェクト情報
│   └── xbm-ui-verify.md       # UI 検証
├── skills/
│   ├── ios-dev-workflow/       # オーケストレーター
│   ├── ios-diagnostics/        # 診断
│   ├── ios-preview-repl/       # プレビュー・REPL
│   ├── ios-project-info/       # プロジェクト情報
│   └── ios-maintenance/        # メンテナンス
└── README.md
```

## MCP 構成

| MCP サーバー | 用途 | 必須 |
|-------------|------|:---:|
| **XcodeBuildMCP** | ビルド・テスト・実行・UI 操作 | 必須 |
| **xcode (xcrun mcpbridge)** | SwiftUI プレビュー・REPL・Apple ドキュメント | 任意 |

## v2.x からの変更点

- CLI フォールバック廃止 → XcodeBuildMCP 必須
- Xcode ネイティブ MCP でのビルド・テスト廃止 → XcodeBuildMCP に統合
- ios-build-runner / ios-test-runner 廃止 → xbm-build / xbm-test / xbm-run / xbm-project-setup / xbm-ui-verify に再編
- サブエージェントから MCP ツール直接呼び出し（フォアグラウンド実行）
- UI 検証エージェント追加（スクリーンショット + ビュー階層 + UI 操作）

## 関連プラグイン

- **ios-architecture**: iOS クリーンアーキテクチャの設計原則
- **swift-design-system**: Swift Design System を使った UI 実装

## ライセンス

MIT
