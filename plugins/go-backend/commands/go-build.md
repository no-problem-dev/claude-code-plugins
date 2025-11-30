---
description: Goバックエンドのバイナリをビルド
allowed-tools: Bash
argument-hint: なし
---

# Go ビルド

Goバックエンドのバイナリをビルドします。

## 実行

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/go-build.sh
```

## 環境変数

- `GO_BACKEND_DIR`: バックエンドディレクトリ
- `GO_MAIN_PATH`: main.go のパス（デフォルト: cmd/server/main.go）
- `GO_BIN_NAME`: 出力バイナリ名（デフォルト: server）

## 使用タイミング

- デプロイ用バイナリを作成
- ビルド可能かの確認

## 次のステップ

- 成功 → `/go-backend:go-test` でテスト実行
- 成功 → `/go-backend:go-run` で開発サーバー起動
