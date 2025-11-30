# no-problem-plugins

Claude Code プラグインマーケットプレイス

## インストール

```bash
/plugin marketplace add no-problem-dev/claude-code-plugins
```

## プラグイン一覧

### 開発ワークフロー

| プラグイン | 説明 |
|-----------|------|
| [ios-dev](./plugins/ios-dev/) | iOS/Swift/Xcode ビルド・テスト・実行コマンド群 |
| [go-backend](./plugins/go-backend/) | Go バックエンド ビルド・テスト・Lint コマンド群 |
| [firebase-emulator](./plugins/firebase-emulator/) | Firebase Emulator Suite 起動・停止・管理 |

### アーキテクチャ・設計

| プラグイン | 説明 |
|-----------|------|
| [ios-architecture](./plugins/ios-architecture/) | iOS Clean Architecture スキル |

### ユーティリティ

| プラグイン | 説明 |
|-----------|------|
| [release-flow](./plugins/release-flow/) | リリースワークフロー自動化 |
| [notify-on-stop](./plugins/notify-on-stop/) | 停止・権限要求時に Slack / macOS 通知を送信 |

## 開発

このリポジトリでは [plugin-dev@anthropic-official](https://github.com/anthropics/claude-code/tree/main/plugins/plugin-dev) が設定済みです。

```bash
# プラグイン作成ガイド
/plugin-dev:create-plugin
```

## ライセンス

MIT
