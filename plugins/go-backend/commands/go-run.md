---
description: Go開発サーバーを起動
allowed-tools: Bash
argument-hint: なし
---

# Go 開発サーバー起動

Goバックエンドの開発サーバーを起動します。

## 実行

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/go-run.sh
```

## 環境変数

- `GO_BACKEND_DIR`: バックエンドディレクトリ
- `GO_MAIN_PATH`: main.go のパス

## 使用タイミング

- ローカル開発時のAPI確認
- デバッグ時
- iOSアプリとの結合テスト

## 次のステップ

- サーバー起動後 → APIエンドポイントをテスト
- 終了 → Ctrl+C
