---
name: ios-dev-workflow
description: iOS/Swift/Xcode 開発ワークフロー全体のガイド。「iOS」「Xcode」「Swift」「build」「test」「compile」「simulator」「xcodebuild」「preview」「SwiftUI」「ビルド」「テスト」「コンパイル」などのキーワードで自動適用。MCP 利用可能時はスキルで直接ビルド・テスト、不可時はサブエージェントで CLI 実行。
---

# iOS 開発ワークフロー（v2.1 — MCP スキル層実行）

iOS/Swift/Xcode プロジェクトのビルド・テスト・診断・プレビューを統合管理するオーケストレーター。
Xcode MCP サーバーが利用可能な場合はこのスキル内で直接 MCP ツールを実行し、利用不可の場合はサブエージェント経由で CLI 実行する。

> **設計背景:** サブエージェント（agents/）は Claude Code の制限により MCP ツールにアクセスできない。
> MCP 実行はメイン会話コンテキスト（スキル層）で行う必要がある。

## ビルド・テスト実行

### Step 0: MCP 可用性チェック

ビルドまたはテスト要求を受けたら、まず MCP の利用可否を判定する。

```
ToolSearch で "select:mcp__xcode__XcodeListWindows" をロード
  → XcodeListWindows を試行
    → 成功: MCP 利用可能
    → 失敗（ツールなし / Xcode 未起動）: CLI フォールバック
```

### MCP ルート（MCP 利用可能 & スキーム指定なし & iOS プロジェクト）

**このスキル内で直接実行する**（出力が小さいためメインコンテキストで問題ない）。

#### MCP ビルド:
```
1. BuildProject → 現在の GUI 設定でビルド実行
2. GetBuildLog(filter: errors) → エラーのみ取得
3. サマリーをユーザーに返却
```

#### MCP テスト（全テスト）:
```
1. RunAllTests → 全テスト実行
2. サマリーをユーザーに返却
```

#### MCP テスト（個別テスト）:
```
1. RunSomeTests(tests: ["Target/Class/method"]) → 指定テストのみ実行
2. サマリーをユーザーに返却
```

#### MCP テスト一覧:
```
GetTestList → テストターゲット・テストケース一覧を返却
```

### CLI ルート（MCP 利用不可 or スキーム指定あり or SPM）

**サブエージェントに委譲する**（ビルドログが大量のためメインコンテキストに流さない）。

| エージェント | 用途 | 使いどころ |
|-------------|------|-----------|
| **ios-build-runner** | ビルド（CLI 専用） | MCP 不可時 / スキーム指定あり / SPM |
| **ios-test-runner** | テスト（CLI 専用） | MCP 不可時 / スキーム指定あり / SPM |

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

## MCP / CLI の役割分担

### MCP でしかできないこと（MCP 必須 — スキルで実行）
- SwiftUI プレビュー描画（`RenderPreview`）
- Apple ドキュメント検索（`DocumentationSearch`）
- Swift REPL 実行（`ExecuteSnippet`）
- Xcode Issue Navigator（`XcodeListNavigatorIssues`）
- ファイル単位ライブ診断（`XcodeRefreshCodeIssuesInFile`）

### MCP でも CLI でもできること（MCP 優先 — スキルで実行、CLI はサブエージェント）
- ビルド: `BuildProject` → `xcodebuild build`
- テスト: `RunAllTests` / `RunSomeTests` → `xcodebuild test`
- テスト一覧: `GetTestList` → テストターゲット手動解析
- ビルドログ: `GetBuildLog` → `2>&1 | tail`

### CLI でしかできないこと（サブエージェントで実行）
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
ビルド（MCP or サブエージェント）
    ↓ 成功
テスト（MCP or サブエージェント）
    ↓ 全テストパス
コミット・PR
```

## 関連プラグイン

- **ios-architecture**: iOS クリーンアーキテクチャの設計原則
- **swift-design-system**: Swift Design System を使った UI 実装
