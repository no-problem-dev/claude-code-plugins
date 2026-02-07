---
name: go-dev-server
description: Go 開発サーバーの起動・管理。「go run」「サーバー起動」「開発サーバー」「API サーバー」「ローカルサーバー」などのキーワードで自動適用。
---

# Go 開発サーバー

Go バックエンドの開発サーバーを起動・管理する。

## プロジェクト検出

以下の優先順位で Go プロジェクトを検出:

1. 環境変数 `GO_BACKEND_DIR`（go.mod の存在を確認）
2. カレントディレクトリの `go.mod`
3. サブディレクトリ（`backend/`, `server/`, `api/`, `go/`）
4. 再帰検索（深さ2まで）

## サーバー起動

```bash
cd <backend_dir>

# main.go の検出
# GO_MAIN_PATH > cmd/server/main.go > cmd/api/main.go > cmd/main.go > main.go
MAIN_PATH="${GO_MAIN_PATH:-}"
if [[ -z "$MAIN_PATH" ]]; then
  for p in cmd/server/main.go cmd/api/main.go cmd/main.go main.go; do
    [[ -f "$p" ]] && MAIN_PATH="$p" && break
  done
fi

# 開発サーバー起動（フォアグラウンド）
go run "$MAIN_PATH"
```

## 環境変数

| 変数 | 説明 | デフォルト |
|------|------|-----------|
| `GO_BACKEND_DIR` | バックエンドディレクトリ | 自動検出 |
| `GO_MAIN_PATH` | main.go のパス | `cmd/server/main.go` |

## 注意事項

- `go run` はフォアグラウンドで実行される（ブロッキング）
- 停止するには Ctrl+C
- Firebase Emulator と併用する場合、エミュレーターを先に起動すること
