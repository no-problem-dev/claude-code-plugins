---
description: iOSアプリのフルビルドを実行（全出力表示）
allowed-tools: Bash
argument-hint: [scheme] [configuration] - 省略時はデフォルト値
---

# iOS フルビルド

iOSアプリの完全なビルドを実行します。全ての出力を表示。

## 実行

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/ios-build.sh $ARGUMENTS
```

## 引数

- `scheme`: ビルドスキーム名（省略時は自動検出）
- `configuration`: ビルド構成（Debug/Release、省略時はDebug）

## 環境変数

- `IOS_PROJECT`: .xcodeproj パス
- `IOS_SCHEME`: デフォルトスキーム
- `IOS_SIMULATOR`: シミュレーター名

## 使用タイミング

- `ios-check` でエラーがないことを確認後
- CI/CDと同等のビルドをローカルで確認したい時
- Release構成でのビルド確認

## 次のステップ

- 成功 → `/ios-dev:ios-run` でシミュレーター実行
- 成功 → `/ios-dev:ios-test` でテスト実行
