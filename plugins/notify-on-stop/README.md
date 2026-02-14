# notify-on-stop

Claude Code の停止・権限要求時に通知を送信するプラグイン

## 機能

Claude Code が以下の状態になったとき、**Slack** と **macOS ローカル通知**で知らせます：

| イベント | 説明 | 通知音 | Slack 色 | デフォルト |
|---------|------|--------|---------|-----------|
| ✅ 作業完了 | メインエージェントの作業が終了 | Glass（穏やか） | 🟢 緑 | 有効 |
| 👋 入力待ち | ユーザー入力を待っている | Ping（注意） | 🟡 黄 | 有効 |
| 🔐 権限要求 | ツール使用の許可が必要 | Sosumi（緊急） | 🔴 赤 | 有効 |
| ⚡ サブエージェント完了 | サブエージェントの作業が終了 | Tink（軽い） | 🔵 青 | **無効** |

## インストール

### 1. マーケットプレイスの追加（初回のみ）

```bash
/plugin marketplace add no-problem-dev/claude-code-plugins
```

### 2. プラグインのインストール

Claude Code の設定画面（`/plugins`）から **notify-on-stop** を選択してインストール

## コマンド

| コマンド | 説明 |
|---------|------|
| `/notify-setup` | セットアップガイドを表示、現在の設定状況を確認 |
| `/notify-test` | 通知のテストを実行 |

## セットアップ

### Slack 通知の設定

`~/.claude/settings.json` に Incoming Webhook URL を追加します。

```json
{
  "env": {
    "SLACK_WEBHOOK_URL": "https://hooks.slack.com/services/T.../B.../xxx"
  }
}
```

**Webhook の取得手順：**
1. [Slack API](https://api.slack.com/apps) でアプリを作成
2. **Incoming Webhooks** を有効化
3. **Add New Webhook to Workspace** でチャンネルを選択
4. 生成された URL をコピー

> **Slack 通知が不要な場合**は、この設定をスキップしてください。ローカル通知のみ動作します。

### 動作確認

プラグインインストール後、Claude Code を再起動すると hooks が自動的に有効になります。

## 設定オプション

`~/.claude/settings.json` の `env` セクションで以下を設定できます：

| 環境変数 | 説明 | デフォルト |
|---------|------|-----------|
| `SLACK_WEBHOOK_URL` | Slack Incoming Webhook URL | - |
| `NOTIFY_SLACK_ENABLED` | Slack 通知の有効/無効 | `true` |
| `NOTIFY_LOCAL_ENABLED` | ローカル通知の有効/無効 | `true` |
| `NOTIFY_SUBAGENT_ENABLED` | サブエージェント完了通知の有効/無効 | `false` |

## 仕組み

このプラグインは Claude Code の **Hooks** 機能を使用しています：

```
プラグインインストール
    ↓
hooks/hooks.json が自動統合
    ↓
Claude Code イベント発生（Stop, Notification 等）
    ↓
scripts/notify.sh が実行
    ↓
ローカル通知 + Slack 通知（並列）
```

## トラブルシューティング

### 通知が表示されない

1. **macOS の通知設定を確認**
   - システム設定 → 通知 → ターミナル（または使用中のターミナルアプリ）
   - 「通知を許可」が有効になっているか確認

2. **Claude Code を再起動**
   - プラグインインストール後は再起動が必要です

### Slack に通知が届かない

1. **環境変数が設定されているか確認**
   ```bash
   claude config get env
   ```

2. **Webhook URL をテスト**
   ```bash
   curl -X POST -H 'Content-type: application/json' \
     --data '{"text":"テスト"}' \
     "YOUR_WEBHOOK_URL"
   ```

3. **Slack アプリの権限を確認**
   - Incoming Webhooks が有効か
   - 正しいチャンネルが選択されているか

### hooks が動作しない

プラグインの hooks が正しく統合されているか確認：

```bash
claude config get hooks
```

## アンインストール

Claude Code の設定画面（`/plugins`）から **notify-on-stop** を選択してアンインストール

## ライセンス

MIT

## 参考リンク

- [Claude Code Hooks ドキュメント](https://code.claude.com/docs/en/hooks)
- [Slack Incoming Webhooks](https://api.slack.com/messaging/webhooks)
