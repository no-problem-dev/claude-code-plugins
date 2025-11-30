---
description: iOSアプリのユニットテストを実行
allowed-tools: Bash
argument-hint: [--coverage] [target] - カバレッジオプションとテストターゲット
---

# iOS テスト実行

iOSアプリのユニットテストを実行します。

## 実行

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/ios-test.sh $ARGUMENTS
```

## 引数

- `--coverage`: カバレッジ付きで実行
- `target`: 特定のテストターゲット（省略時は全テスト）

## 環境変数

- `IOS_PROJECT`: .xcodeproj パス
- `IOS_SCHEME`: デフォルトスキーム
- `IOS_SIMULATOR`: シミュレーター名

## 使用タイミング

- PR作成前の最終確認
- リファクタリング後の回帰テスト
- CI/CDと同等のテストをローカルで実行

## 次のステップ

- 全テスト成功 → コミット・PR作成
- テスト失敗 → 該当テストを修正
