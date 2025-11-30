# firebase-emulator

Firebase Emulator Suite の起動・停止・管理コマンド群。ローカル開発環境をサポート。

## インストール

Claude Code の `/plugins` UI からインストール、または:

```bash
claude plugins:install firebase-emulator
```

## コマンド一覧

| コマンド | 説明 |
|---------|------|
| `/firebase-emulator:emulator-start` | エミュレーター起動（バックグラウンド） |
| `/firebase-emulator:emulator-stop` | エミュレーター停止 |
| `/firebase-emulator:emulator-status` | 状態確認 |

## スキル

**firebase-emulator-workflow**: Firebase Emulator 管理の知識が自動適用されます。

以下のキーワードで自動トリガー:
- `エミュレーター`, `Firebase`, `Firestore`
- `Auth`, `ローカル開発`

## 環境変数

プロジェクト固有の設定は環境変数で上書き可能:

| 変数 | 説明 | デフォルト |
|------|------|-----------|
| `FIREBASE_DIR` | Firebase ディレクトリ | 自動検出 |
| `FIREBASE_PROJECT_ID` | プロジェクトID | 自動検出 |
| `EMULATOR_PORT_FIRESTORE` | Firestore ポート | 8090 |
| `EMULATOR_PORT_AUTH` | Auth ポート | 9099 |
| `EMULATOR_PORT_STORAGE` | Storage ポート | 9199 |
| `EMULATOR_PORT_UI` | UI ポート | 4000 |

## プロジェクト構成

このプラグインは以下の構成を自動検出:

```
project/
├── firebase.json
└── firebase/
    └── firebase.json
```

## プラグイン構成

```
firebase-emulator/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   ├── emulator-start.md
│   ├── emulator-stop.md
│   └── emulator-status.md
├── scripts/
│   ├── common.sh
│   ├── emulator-start.sh
│   ├── emulator-stop.sh
│   └── emulator-status.sh
├── skills/
│   └── firebase-emulator-workflow/
│       └── SKILL.md
└── README.md
```

## 推奨ワークフロー

```
1. /firebase-emulator:emulator-start  → 開発開始
2. iOS/Backend 開発
3. /firebase-emulator:emulator-stop   → 開発終了
```

## 必要なツール

- **Firebase CLI**: `npm install -g firebase-tools`
- **firebase.json**: プロジェクト初期化済み

## ライセンス

MIT
