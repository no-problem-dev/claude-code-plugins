---
name: ios-dev-workflow
description: iOS/Swift/Xcode 開発ワークフロー全体のガイド。「iOS」「Xcode」「Swift」「build」「test」「compile」「simulator」「xcodebuild」「preview」「SwiftUI」「ビルド」「テスト」「コンパイル」などのキーワードで自動適用。ビルド・テストはサブエージェント、診断・プレビュー・情報・メンテナンスはスキルを推奨。
---

# iOS 開発ワークフロー（v2.0 — Xcode MCP ハイブリッド）

iOS/Swift/Xcode プロジェクトのビルド・テスト・診断・プレビューを統合管理するオーケストレーター。
Xcode MCP サーバー（`xcrun mcpbridge`）が利用可能な場合は MCP を優先し、利用不可の場合は CLI にフォールバックする。

## エージェント（重い処理はサブエージェントで実行）

| エージェント | 用途 | 使いどころ |
|-------------|------|-----------|
| **ios-build-runner** | ビルド（iOS / SPM） | 「ビルドして」「コンパイルして」 |
| **ios-test-runner** | テスト実行 | 「テストして」「テスト走らせて」 |

**原則**: ビルド・テストは必ずサブエージェントで実行。メインコンテキストにログを流さない。

## スキル（診断・情報・メンテナンス）

| スキル | 用途 | 使いどころ |
|--------|------|-----------|
| **ios-diagnostics** | エラー・警告チェック | 「エラーある？」「警告チェック」 |
| **ios-preview-repl** | SwiftUI プレビュー・REPL・ドキュメント | 「プレビュー見せて」「Swift 実行して」「Apple ドキュメント検索」 |
| **ios-project-info** | スキーム・シミュレータ・設定一覧 | 「スキーム一覧」「シミュレータ一覧」「Bundle ID 教えて」 |
| **ios-maintenance** | キャッシュクリア・シミュレータ管理 | 「クリーンして」「DerivedData 消して」「シミュレータ起動」 |

## プロジェクト検出順序

1. **xcworkspace**（最優先）— `.xcodeproj/project.xcworkspace` は除外
2. **xcodeproj** — ワークスペースがない場合
3. **Package.swift** — 純粋な SPM プロジェクト

## MCP ハイブリッド設計

```
Step 0: MCP 可用性チェック（XcodeListWindows 試行）
  → 成功: MCP 優先で動作
  → 失敗: CLI のみで動作（MCP 専用機能はスキップ）
```

### MCP でしかできないこと（MCP 必須）
- SwiftUI プレビュー描画（`RenderPreview`）
- Apple ドキュメント検索（`DocumentationSearch`）
- Swift REPL 実行（`ExecuteSnippet`）
- Xcode Issue Navigator（`XcodeListNavigatorIssues`）
- ファイル単位ライブ診断（`XcodeRefreshCodeIssuesInFile`）

### MCP でも CLI でもできること（MCP 優先、CLI フォールバック）
- ビルド: `BuildProject` → `xcodebuild build`
- テスト: `RunAllTests` / `RunSomeTests` → `xcodebuild test`
- テスト一覧: `GetTestList` → テストターゲット手動解析
- ビルドログ: `GetBuildLog` → `2>&1 | tail`

### CLI でしかできないこと（CLI 固定）
- スキーム指定ビルド / スキーム一覧
- デスティネーション一覧
- シミュレータ管理（`xcrun simctl`）
- ビルドクリーン / DerivedData 削除
- SPM 依存解決
- ビルド設定確認

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

## 関連プラグイン

- **ios-architecture**: iOS クリーンアーキテクチャの設計原則
- **swift-design-system**: Swift Design System を使った UI 実装
