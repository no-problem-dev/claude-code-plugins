# go-backend

Go バックエンドのビルド・テスト・Lint コマンド群。API サーバー開発をサポート。

## インストール

Claude Code の `/plugins` UI からインストール、または:

```bash
claude plugins:install go-backend
```

## コマンド一覧

| コマンド | 説明 |
|---------|------|
| `/go-backend:go-build` | バイナリビルド |
| `/go-backend:go-test` | テスト実行（カバレッジオプション付き） |
| `/go-backend:go-lint` | 静的解析（golangci-lint） |
| `/go-backend:go-run` | 開発サーバー起動 |
| `/go-backend:go-tidy` | 依存関係整理（go mod tidy） |
| `/go-backend:go-swagger` | Swagger/OpenAPI生成 |

## スキル

**go-backend-workflow**: Go バックエンド開発ワークフローの知識が自動適用されます。

以下のキーワードで自動トリガー:
- `Goビルド`, `バックエンドテスト`, `golangci-lint`
- `go mod`, `go test`, `swagger`

## 環境変数

プロジェクト固有の設定は環境変数で上書き可能:

| 変数 | 説明 | デフォルト |
|------|------|-----------|
| `GO_BACKEND_DIR` | バックエンドディレクトリ | 自動検出 |
| `GO_MAIN_PATH` | main.go のパス | `cmd/server/main.go` |
| `GO_BIN_NAME` | 出力バイナリ名 | `server` |

## プロジェクト構成

このプラグインは以下の構成を自動検出:

### 1. Makefile ベース（推奨）

```
project/
├── Makefile          # build, test, lint 等のターゲット
└── backend/
    ├── Makefile      # build, test, lint 等のターゲット
    ├── go.mod
    └── cmd/
        └── server/
            └── main.go
```

Makefileターゲットがあれば優先的に使用します。

### 2. 標準 Go プロジェクト

```
project/
├── go.mod
└── cmd/
    └── server/
        └── main.go
```

### 3. シンプル構成

```
project/
├── go.mod
└── main.go
```

## プラグイン構成

```
go-backend/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   ├── go-build.md
│   ├── go-lint.md
│   ├── go-run.md
│   ├── go-swagger.md
│   ├── go-test.md
│   └── go-tidy.md
├── scripts/
│   ├── common.sh       # 共通関数
│   ├── go-build.sh
│   ├── go-lint.sh
│   ├── go-run.sh
│   ├── go-swagger.sh
│   ├── go-test.sh
│   └── go-tidy.sh
├── skills/
│   └── go-backend-workflow/
│       └── SKILL.md
└── README.md
```

## 推奨ワークフロー

```
1. コード変更
2. /go-backend:go-build  → ビルド確認
3. /go-backend:go-test   → テスト実行
4. /go-backend:go-lint   → 品質チェック
5. コミット・PR
```

## 必要なツール

- **Go** 1.21+
- **golangci-lint** (Lint用): `brew install golangci-lint`
- **swag** (Swagger用): `go install github.com/swaggo/swag/cmd/swag@latest`

## ライセンス

MIT
