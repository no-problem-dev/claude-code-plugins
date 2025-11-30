---
description: Swagger/OpenAPIドキュメントを生成
allowed-tools: Bash
argument-hint: なし
---

# Swagger 生成

swag を使用してSwagger/OpenAPIドキュメントを生成します。

## 実行

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/go-swagger.sh
```

## 前提条件

swag がインストールされている必要があります（未インストールの場合は自動インストール）:

```bash
go install github.com/swaggo/swag/cmd/swag@latest
```

## 環境変数

- `GO_BACKEND_DIR`: バックエンドディレクトリ
- `GO_MAIN_PATH`: main.go のパス

## 使用タイミング

- APIエンドポイントを追加・変更した後
- ドキュメントを更新したい時
- OpenAPI仕様をエクスポートしたい時

## 次のステップ

- 生成完了 → docs/ ディレクトリを確認
- `/go-backend:go-run` でSwagger UIを確認
