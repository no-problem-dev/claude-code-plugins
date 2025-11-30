# no-problem-plugins

Claude Code プラグインマーケットプレイス

## インストール

```bash
/plugin marketplace add no-problem-dev/claude-code-plugins
```

## プラグイン一覧

| プラグイン | 説明 |
|-----------|------|
| [release-flow](./plugins/release-flow/) | リリースワークフロー自動化 |
| [ios-architecture](./plugins/ios-architecture/) | iOS Clean Architecture スキル |
| [notify-on-stop](./plugins/notify-on-stop/) | 停止・権限要求時に Slack / macOS 通知を送信 |

## 開発

このリポジトリでは [plugin-dev@anthropic-official](https://github.com/anthropics/claude-code/tree/main/plugins/plugin-dev) が設定済みです。

```bash
# プラグイン作成ガイド
/plugin-dev:create-plugin
```

## ライセンス

MIT
