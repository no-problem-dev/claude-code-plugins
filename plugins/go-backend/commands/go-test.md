---
description: Goバックエンドのテストを実行
allowed-tools: Bash
argument-hint: [--coverage] [--verbose] [package] - オプション指定
---

# Go テスト

Goバックエンドのテストを実行します。

## 実行

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/go-test.sh $ARGUMENTS
```

## 引数

- `--coverage` または `coverage`: カバレッジ付き実行
- `--verbose` または `-v`: 詳細出力
- `package`: 特定パッケージのみ（例: `./internal/handler/...`）

## 環境変数

- `GO_BACKEND_DIR`: バックエンドディレクトリ

## 使用タイミング

- コード変更後の検証
- PR作成前の最終確認
- CI/CDと同等のテストをローカルで実行

## 次のステップ

- 全テスト成功 → `/go-backend:go-lint` で品質チェック
- テスト失敗 → 該当テストを修正
