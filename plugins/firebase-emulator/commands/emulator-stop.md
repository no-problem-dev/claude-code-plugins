---
description: Firebase Emulator を停止
allowed-tools: Bash
argument-hint: なし
---

# Firebase Emulator 停止

起動中の Firebase Emulator を停止します。

## 実行

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/emulator-stop.sh
```

## 環境変数

- `EMULATOR_PORT_FIRESTORE`: Firestore ポート（デフォルト: 8090）
- `EMULATOR_PORT_AUTH`: Auth ポート（デフォルト: 9099）
- `EMULATOR_PORT_STORAGE`: Storage ポート（デフォルト: 9199）
- `EMULATOR_PORT_UI`: UI ポート（デフォルト: 4000）

## 使用タイミング

- 開発終了時
- ポートを解放したい時
- エミュレーターを再起動したい時
