---
description: Goバックエンドの静的解析（golangci-lint）を実行
allowed-tools: Bash
argument-hint: なし
---

# Go Lint

golangci-lint を使用してコードの静的解析を実行します。

## 実行

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/go-lint.sh
```

## 前提条件

golangci-lint がインストールされている必要があります:

```bash
brew install golangci-lint
# または
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
```

## 環境変数

- `GO_BACKEND_DIR`: バックエンドディレクトリ

## 使用タイミング

- PR作成前の品質チェック
- コードレビュー前の事前確認
- CI/CDと同等のLintをローカルで実行

## 次のステップ

- 問題なし → コミット・PR作成
- エラーあり → 該当箇所を修正
