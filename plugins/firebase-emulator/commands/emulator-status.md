---
description: Firebase Emulator の状態を確認
allowed-tools: Bash
argument-hint: なし
---

# Firebase Emulator 状態確認

Firebase Emulator の起動状態を確認します。

## 実行

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/emulator-status.sh
```

## 環境変数

- `EMULATOR_PORT_FIRESTORE`: Firestore ポート（デフォルト: 8090）
- `EMULATOR_PORT_AUTH`: Auth ポート（デフォルト: 9099）
- `EMULATOR_PORT_STORAGE`: Storage ポート（デフォルト: 9199）
- `EMULATOR_PORT_UI`: UI ポート（デフォルト: 4000）

## 表示内容

- 各サービスの起動状態
- 使用中のポート
- UI へのアクセス URL
