# ios-dev v2.0

iOS/Swift/Xcode のビルド・テスト・診断・プレビュー。Xcode MCP ハイブリッド対応。

## インストール

Claude Code の `/plugins` UI からインストール、または:

```bash
claude plugins:install ios-dev
```

## MCP ハイブリッド設計

Xcode 26.3 の公式 MCP サーバー（`xcrun mcpbridge`）が利用可能な場合は MCP を優先し、
利用不可の場合は CLI にフォールバックする。**MCP がなくてもビルド・テストは必ず動く。**

### セットアップ（MCP 機能を使う場合）

```bash
claude mcp add xcode -- xcrun mcpbridge
```

## サブエージェント（ビルド・テスト用）

ビルドやテストは **サブエージェント** で実行。独立したコンテキストで動作し、メインの会話を消費しない。

| エージェント | 用途 | モデル |
|-------------|------|--------|
| **ios-build-runner** | iOS アプリ / SPM ビルド | Sonnet |
| **ios-test-runner** | ユニットテスト実行 | Sonnet |

### 使用例

```
「ビルドして」
→ ios-build-runner が xcworkspace を検出 → MCP or CLI でビルド → サマリー返却

「テストして」
→ ios-test-runner が MCP テスト or xcodebuild test で実行 → 結果サマリー返却

「サーバーをビルドして」
→ ios-build-runner が Package.swift を検出 → swift build で実行
```

## スキル

| スキル | 用途 | MCP |
|--------|------|-----|
| **ios-dev-workflow** | 全体のオーケストレーション・使い分けガイド | — |
| **ios-diagnostics** | エラー・警告チェック | MCP 優先 |
| **ios-preview-repl** | SwiftUI プレビュー・REPL・Apple ドキュメント | MCP 必須 |
| **ios-project-info** | スキーム・シミュレータ・ビルド設定一覧 | CLI 専用 |
| **ios-maintenance** | キャッシュクリア・シミュレータ管理 | CLI 専用 |

## プロジェクト検出順序

1. **xcworkspace**（最優先）— `.xcodeproj/project.xcworkspace` は除外
2. **xcodeproj** — ワークスペースがない場合
3. **Package.swift** — 純粋な SPM プロジェクト

## 対応プロジェクト構成

### iOS + Server-side Swift
```
project/
├── Project.xcworkspace    ← iOS ビルド
├── iOS/
│   ├── App.xcodeproj
│   └── Packages/
├── Server/
│   └── Package.swift      ← SPM ビルド
└── Shared/
    └── Package.swift
```

### iOS のみ（xcworkspace / xcodeproj）
```
project/
├── Project.xcworkspace
└── iOS/
    └── App.xcodeproj
```

### Swift Package のみ
```
project/
├── Package.swift
├── Sources/
└── Tests/
```

## プラグイン構成

```
ios-dev/
├── .claude-plugin/
│   └── plugin.json
├── agents/
│   ├── ios-build-runner.md    # ビルド（iOS + SPM 統合）
│   └── ios-test-runner.md     # テスト
├── skills/
│   ├── ios-dev-workflow/      # オーケストレーター
│   ├── ios-diagnostics/       # エラー・警告チェック
│   ├── ios-preview-repl/      # プレビュー・REPL・ドキュメント
│   ├── ios-project-info/      # プロジェクト情報
│   └── ios-maintenance/       # クリーン・シミュレータ管理
└── README.md
```

## 推奨ワークフロー

```
コード変更
    ↓
ios-build-runner（ビルド）
    ↓ 成功
ios-test-runner（テスト）
    ↓ 全テストパス
コミット・PR
```

## v1.x からの変更点

- `swift-build-runner` を `ios-build-runner` に統合
- `commands/` を全削除 → `skills/` に移行
- Xcode MCP サーバー対応（ハイブリッド設計）
- SwiftUI プレビュー・REPL・Apple ドキュメント検索を追加
- プロジェクト情報スキル（スキーム・シミュレータ・ビルド設定）を追加
- シミュレータ管理機能を追加

## 関連プラグイン

- **ios-architecture**: iOS クリーンアーキテクチャの設計原則
- **swift-design-system**: Swift Design System を使った UI 実装

## ライセンス

MIT
