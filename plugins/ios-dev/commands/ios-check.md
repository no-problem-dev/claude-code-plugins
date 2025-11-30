---
description: iOSアプリのコンパイルエラーを高速チェック（警告・エラーのみ出力）
allowed-tools: Bash
argument-hint: [scheme] - 省略時はデフォルトscheme
---

# iOS コンパイルチェック

コンパイルエラーのみを高速でチェックします。フルビルドより大幅に高速。

## 実行

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/ios-check.sh $ARGUMENTS
```

## 引数

- `scheme`: ビルドスキーム名（省略時は自動検出）

## 環境変数

- `IOS_PROJECT`: .xcodeproj パス
- `IOS_SCHEME`: デフォルトスキーム
- `IOS_SIMULATOR`: シミュレーター名

## 使用タイミング

- コード変更後の素早い検証
- PRレビュー前の確認
- リファクタリング中の継続的チェック

## 次のステップ

- エラーなし → `/ios-dev:ios-build` でフルビルド
- エラーあり → 該当箇所を修正して再度チェック
