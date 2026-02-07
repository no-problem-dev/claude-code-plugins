# firebase-emulator

Firebase Emulator Suite の起動・停止・管理。ローカル開発環境をサポート。

## インストール

Claude Code の `/plugins` UI からインストール、または:

```bash
claude plugins:install firebase-emulator
```

## スキル

| スキル | 用途 |
|--------|------|
| **firebase-emulator-workflow** | Emulator 管理ワークフロー全体のガイド |
| **emulator-control** | 起動・停止・状態確認 |

キーワードで自動トリガーされます:
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
├── scripts/
│   ├── common.sh
│   ├── emulator-start.sh
│   ├── emulator-stop.sh
│   └── emulator-status.sh
├── skills/
│   ├── firebase-emulator-workflow/
│   │   └── SKILL.md
│   └── emulator-control/
│       └── SKILL.md
└── README.md
```

## 推奨ワークフロー

```
1. emulator-control（起動）→ 開発開始
2. iOS / Backend 開発
3. emulator-control（停止）→ 開発終了
```

## 必要なツール

- **Firebase CLI**: `npm install -g firebase-tools`
- **firebase.json**: プロジェクト初期化済み

## ライセンス

MIT
