---
name: ios-preview-repl
description: SwiftUI プレビュー・Swift REPL・Apple ドキュメント検索。「preview」「SwiftUI preview」「プレビュー」「REPL」「playground」「Swift 実行」「Apple docs」「ドキュメント検索」「DocumentationSearch」「ExecuteSnippet」「RenderPreview」などのキーワードで自動適用。Xcode MCP サーバー必須。
---

# SwiftUI プレビュー・REPL・ドキュメント（MCP 専用）

Xcode MCP サーバー経由でのみ利用可能な機能群。

## 前提: MCP 可用性チェック

```
XcodeListWindows を試行
  → 成功: 以下の機能が利用可能
  → 失敗: 「Xcode MCP サーバーが利用できません。Xcode を起動し、MCP サーバーが設定されていることを確認してください。」と通知
```

## 機能

### 1. SwiftUI プレビュー描画

```
RenderPreview(
  filePath: "/path/to/ContentView.swift",
  previewName: "ContentView"  // optional: 特定のプレビューを指定
)
→ プレビュー画像を取得・表示
```

**使いどころ:**
- SwiftUI ビューの見た目を確認
- レイアウト変更後のビジュアル検証
- UI コンポーネントのデバッグ

### 2. Swift REPL 実行

```
ExecuteSnippet(
  code: "let x = 42\nprint(x * 2)"
)
→ 実行結果を返却
```

**使いどころ:**
- Swift コードの素早い検証
- API の動作確認
- アルゴリズムのプロトタイピング
- 型やプロトコルの確認

### 3. Apple ドキュメント検索

```
DocumentationSearch(
  query: "URLSession async"
)
→ Apple 公式ドキュメントの検索結果を返却
```

**使いどころ:**
- API の使い方を調べる
- フレームワークの機能を確認
- 非推奨 API の代替を探す
- 最新 API の仕様確認

## MCP 未設定時のガイド

MCP サーバーが利用できない場合、以下の手順を案内:

```
1. Xcode 26.3 以降がインストールされていることを確認
2. Xcode を起動
3. MCP サーバーを追加:
   claude mcp add xcode -- xcrun mcpbridge
4. Claude Code を再起動
```
