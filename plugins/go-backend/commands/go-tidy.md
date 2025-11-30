---
description: Go依存関係を整理（go mod tidy）
allowed-tools: Bash
argument-hint: なし
---

# Go 依存関係整理

go mod tidy を実行して依存関係を整理します。

## 実行

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/go-tidy.sh
```

## 環境変数

- `GO_BACKEND_DIR`: バックエンドディレクトリ

## 使用タイミング

- 新しいパッケージを追加した後
- 不要なパッケージを削除した後
- go.mod / go.sum の不整合がある時

## 次のステップ

- `/go-backend:go-build` でビルド確認
