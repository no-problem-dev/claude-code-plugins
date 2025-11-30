---
description: iOSアプリをシミュレーターでビルド・実行
allowed-tools: Bash
argument-hint: [simulator] - シミュレーター名（例: "iPhone 16 Pro"）
---

# iOS シミュレーター実行

iOSアプリをビルドしてシミュレーターで実行します。

## 実行

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/ios-run.sh $ARGUMENTS
```

## 引数

- `simulator`: シミュレーター名（省略時は自動検出または環境変数）

## 環境変数

- `IOS_PROJECT`: .xcodeproj パス
- `IOS_SCHEME`: デフォルトスキーム
- `IOS_SIMULATOR`: シミュレーター名（デフォルト: iPhone 16 Pro）

## 前提条件

- シミュレーターが起動していない場合は自動で起動を試みる

## 使用タイミング

- 動作確認が必要な時
- UI/UXの確認
- デバッグ時

## 次のステップ

- 動作確認OK → `/ios-dev:ios-test` でテスト実行
- 問題あり → 修正して `/ios-dev:ios-check` から再開
