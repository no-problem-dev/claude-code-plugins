---
name: go-backend-workflow
description: Go バックエンド開発ワークフロー全体のガイド。「Go」「バックエンド」「API サーバー」「golang」などのキーワードで自動適用。ビルド・テストはサブエージェント、品質・メンテナンスはスキルを推奨。
---

# Go バックエンド開発ワークフロー（v2.0）

Go バックエンドプロジェクトのビルド・テスト・品質管理を統合管理するオーケストレーター。

## エージェント（重い処理はサブエージェントで実行）

| エージェント | 用途 | 使いどころ |
|-------------|------|-----------|
| **go-build-runner** | バイナリビルド | 「ビルドして」「コンパイルして」 |
| **go-test-runner** | テスト実行 | 「テストして」「テスト走らせて」 |

**原則**: ビルド・テストは必ずサブエージェントで実行。メインコンテキストにログを流さない。

## スキル（品質・開発・メンテナンス）

| スキル | 用途 | 使いどころ |
|--------|------|-----------|
| **go-quality** | 静的解析 + Swagger 生成 | 「lint して」「Swagger 生成」 |
| **go-dev-server** | 開発サーバー起動 | 「サーバー起動」「go run」 |
| **go-maintenance** | 依存整理・キャッシュクリア | 「go mod tidy」「キャッシュクリア」 |

## 推奨ワークフロー

```
コード変更
    ↓
go-build-runner（ビルド）
    ↓ 成功
go-test-runner（テスト）
    ↓ 全テストパス
go-quality（品質チェック）
    ↓ 問題なし
コミット・PR
```

## プロジェクト検出順序

1. 環境変数 `GO_BACKEND_DIR`（go.mod の存在を確認）
2. カレントディレクトリの `go.mod`
3. サブディレクトリ（`backend/`, `server/`, `api/`, `go/`）
4. 再帰検索（深さ2まで）

## 環境変数

| 変数 | 説明 | デフォルト |
|------|------|-----------|
| `GO_BACKEND_DIR` | バックエンドディレクトリ | 自動検出 |
| `GO_MAIN_PATH` | main.go のパス | `cmd/server/main.go` |
| `GO_BIN_NAME` | 出力バイナリ名 | `server` |

## よくあるエラーと対処

### go mod tidy が必要

```
go: modules disabled by GO111MODULE=off
```

**対処**:
```bash
export GO111MODULE=on
go mod tidy
```

### golangci-lint が見つからない

```
golangci-lint: command not found
```

**対処**:
```bash
brew install golangci-lint
# または
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
```

### swag が見つからない

```
swag: command not found
```

**対処**:
```bash
go install github.com/swaggo/swag/cmd/swag@latest
```

## テストカバレッジ

カバレッジ付きテストの実行:

```bash
go test -cover -coverprofile=coverage.out ./...
go tool cover -html=coverage.out -o coverage.html
open coverage.html
```

## Lint 設定

プロジェクトルートに `.golangci.yml` を配置することでLintルールをカスタマイズ可能。

推奨設定例:
```yaml
linters:
  enable:
    - errcheck
    - gosimple
    - govet
    - ineffassign
    - staticcheck
    - unused

linters-settings:
  errcheck:
    check-type-assertions: true
```
