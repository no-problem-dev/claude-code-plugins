---
name: ios-preview-repl
description: SwiftUI プレビュー・Swift REPL・Apple ドキュメント検索。Xcode ネイティブ MCP 経由でのみ利用可能。「preview」「SwiftUI preview」「プレビュー」「REPL」「playground」「Swift 実行」「Apple docs」「ドキュメント検索」などのキーワードで自動適用。
---

# SwiftUI プレビュー・REPL・ドキュメント（Xcode ネイティブ MCP）

Xcode ネイティブ MCP サーバー（`xcrun mcpbridge`）経由でのみ利用可能な機能群。
XcodeBuildMCP では提供されない機能のため、別系統として維持。

## 前提

Xcode ネイティブ MCP が登録済みであること:
```bash
claude mcp add xcode -- xcrun mcpbridge
```

## 機能

### 1. SwiftUI プレビュー描画

```
ToolSearch("select:mcp__xcode__RenderPreview")
RenderPreview(filePath: "/path/to/ContentView.swift", previewName: "ContentView")
```

### 2. Swift REPL 実行

```
ToolSearch("select:mcp__xcode__ExecuteSnippet")
ExecuteSnippet(code: "let x = 42\nprint(x * 2)")
```

### 3. Apple ドキュメント検索

```
ToolSearch("select:mcp__xcode__DocumentationSearch")
DocumentationSearch(query: "URLSession async")
```

## MCP 未設定時

「Xcode ネイティブ MCP が利用できません」と通知し、セットアップ手順を案内:

1. Xcode 26.3 以降がインストールされていることを確認
2. Xcode を起動してプロジェクトを開く
3. `claude mcp add xcode -- xcrun mcpbridge`
4. Claude Code を再起動

## XcodeBuildMCP との関係

| 機能 | XcodeBuildMCP | Xcode ネイティブ MCP |
|------|:---:|:---:|
| SwiftUI プレビュー | - | RenderPreview |
| REPL 実行 | - | ExecuteSnippet |
| ドキュメント検索 | - | DocumentationSearch |
| ビルド / テスト | build_sim / test_sim | - (ios-dev-workflow で使用) |
