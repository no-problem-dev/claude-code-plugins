---
description: Firebase Emulator をバックグラウンドで起動
allowed-tools: Bash
argument-hint: なし
---

# Firebase Emulator 起動

Firebase Emulator Suite をバックグラウンドで起動します。

## 実行

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/emulator-start.sh
```

## 環境変数

- `FIREBASE_DIR`: Firebase ディレクトリ
- `FIREBASE_PROJECT_ID`: プロジェクトID
- `EMULATOR_PORT_FIRESTORE`: Firestore ポート（デフォルト: 8090）
- `EMULATOR_PORT_AUTH`: Auth ポート（デフォルト: 9099）
- `EMULATOR_PORT_STORAGE`: Storage ポート（デフォルト: 9199）
- `EMULATOR_PORT_UI`: UI ポート（デフォルト: 4000）

## 前提条件

- Firebase CLI がインストールされている
- firebase.json が存在する

## 次のステップ

- 起動後 → http://localhost:4000 で UI を確認
- 停止 → `/firebase-emulator:emulator-stop`
