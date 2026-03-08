---
name: ios-diagnostics
description: iOS プロジェクトのエラー・警告を XcodeBuildMCP 経由で診断する。「check」「errors」「warnings」「diagnostics」「issues」「compile check」「lint」「エラーチェック」「コンパイルチェック」「警告チェック」などのキーワードで自動適用。
---

# iOS 診断（XcodeBuildMCP）

プロジェクトのエラー・警告を検出するための軽量診断。

## 方式

xbm-build サブエージェントを使用してビルドを実行し、エラー・警告を検出する。
ビルドログはサブエージェント内で消費され、構造化された診断結果のみが返却される。

## ワークフロー

### エラー・警告チェック

xbm-build をフォアグラウンドで起動:

```
Agent(
  subagent_type: "ios-dev:xbm-build",
  prompt: "以下のプロジェクトをビルドし、エラーと警告を報告してください。\n警告も詳細に報告してください。\nプロジェクトパス: <path>"
)
```

### 結果の解釈

- エラーあり → コード修正を提案
- 警告のみ → 重要度を判定し、修正すべきものを提案
- 問題なし → 「診断結果: 問題なし」と報告
