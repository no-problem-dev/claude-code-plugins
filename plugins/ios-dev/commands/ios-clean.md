---
description: iOSビルドキャッシュをクリア
allowed-tools: Bash
argument-hint: [--all] - 全キャッシュ削除（DerivedData含む）
---

# iOS クリーンアップ

ビルドキャッシュをクリアして、クリーンな状態からビルドできるようにします。

## 実行

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/ios-clean.sh $ARGUMENTS
```

## 引数

- `--all`: DerivedData、SPMキャッシュも含めて完全クリア

## 環境変数

- `IOS_PROJECT`: .xcodeproj パス
- `IOS_SCHEME`: デフォルトスキーム

## 使用タイミング

- ビルドが不安定な時
- キャッシュ起因と思われるエラー発生時
- ディスク容量を確保したい時
- ブランチ切り替え後にビルドエラーが出る時

## 次のステップ

- `/ios-dev:ios-build` でフルビルド
