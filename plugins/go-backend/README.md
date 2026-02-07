# go-backend

Go バックエンドのビルド・テスト・Lint・Swagger。API サーバー開発をサポート。

## インストール

Claude Code の `/plugins` UI からインストール、または:

```bash
claude plugins:install go-backend
```

## エージェント

| エージェント | 用途 |
|-------------|------|
| **go-build-runner** | バイナリビルド（隔離実行） |
| **go-test-runner** | テスト実行（隔離実行） |

ビルド・テストはサブエージェントで実行され、メインコンテキストにログを流しません。

## スキル

| スキル | 用途 |
|--------|------|
| **go-backend-workflow** | 開発ワークフロー全体のオーケストレーター |
| **go-quality** | 静的解析（golangci-lint）+ Swagger 生成 |
| **go-dev-server** | 開発サーバー起動・管理 |
| **go-maintenance** | 依存整理（go mod tidy）・キャッシュクリア |

キーワードで自動トリガーされます。

## 環境変数

プロジェクト固有の設定は環境変数で上書き可能:

| 変数 | 説明 | デフォルト |
|------|------|-----------|
| `GO_BACKEND_DIR` | バックエンドディレクトリ | 自動検出 |
| `GO_MAIN_PATH` | main.go のパス | `cmd/server/main.go` |
| `GO_BIN_NAME` | 出力バイナリ名 | `server` |

## プロジェクト構成

このプラグインは以下の構成を自動検出:

### 1. 標準 Go プロジェクト

```
project/
├── go.mod
└── cmd/
    └── server/
        └── main.go
```

### 2. シンプル構成

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
├── agents/
│   ├── go-build-runner.md
│   └── go-test-runner.md
├── skills/
│   ├── go-backend-workflow/
│   │   └── SKILL.md
│   ├── go-quality/
│   │   └── SKILL.md
│   ├── go-dev-server/
│   │   └── SKILL.md
│   └── go-maintenance/
│       └── SKILL.md
└── README.md
```

## 推奨ワークフロー

```
1. コード変更
2. go-build-runner  → ビルド確認
3. go-test-runner   → テスト実行
4. go-quality       → 品質チェック
5. コミット・PR
```

## 必要なツール

- **Go** 1.21+
- **golangci-lint** (Lint用): `brew install golangci-lint`
- **swag** (Swagger用): `go install github.com/swaggo/swag/cmd/swag@latest`

## ライセンス

MIT
