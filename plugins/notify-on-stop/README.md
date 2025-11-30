# notify-on-stop

Claude Code の停止・権限要求時に通知を送信するプラグイン

## 機能

Claude Code が以下の状態になったとき、**Slack** と **macOS ローカル通知**で知らせます：

| イベント | 説明 | 通知音 |
|---------|------|--------|
| 作業完了 | メインエージェントの作業が終了 | Glass |
| 入力待ち | 60秒以上ユーザー入力がない | Basso |
| 権限要求 | ツール使用の許可が必要 | Basso |
| サブエージェント完了 | サブエージェントの作業が終了 | Glass |

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

### Slack 通知の設定（2つの方法）

`~/.claude/settings.json` に環境変数を追加します。

#### 方法 A: Bot Token を使用（推奨）

```json
{
  "env": {
    "SLACK_BOT_TOKEN": "xoxb-xxxx-xxxx-xxxx",
    "SLACK_CHANNEL_ID": "C0XXXXXXXXX"
  }
}
```

**Bot Token の取得手順：**
1. [Slack API](https://api.slack.com/apps) でアプリを作成
2. **OAuth & Permissions** で `chat:write` スコープを追加
3. **Install to Workspace** でインストール
4. **Bot User OAuth Token** (xoxb-...) をコピー
5. 通知先チャンネルに Bot を招待（`/invite @Bot名`）
6. チャンネル ID は URL から取得（`slack.com/archives/C0XXXXXXXXX`）

#### 方法 B: Incoming Webhook を使用

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
| `SLACK_BOT_TOKEN` | Slack Bot Token (xoxb-...) | - |
| `SLACK_CHANNEL_ID` | Bot Token 使用時のチャンネル ID | - |
| `SLACK_WEBHOOK_URL` | Slack Incoming Webhook URL | - |
| `NOTIFY_SOUND` | 通知音の名前 | `Glass` |
| `NOTIFY_SLACK_ENABLED` | Slack 通知の有効/無効 | `true` |
| `NOTIFY_LOCAL_ENABLED` | ローカル通知の有効/無効 | `true` |

### 設定例（Bot Token）

```json
{
  "env": {
    "SLACK_BOT_TOKEN": "xoxb-xxxx-xxxx-xxxx",
    "SLACK_CHANNEL_ID": "C0XXXXXXXXX",
    "NOTIFY_SOUND": "Ping",
    "NOTIFY_SLACK_ENABLED": "true",
    "NOTIFY_LOCAL_ENABLED": "true"
  }
}
```

### 通知音の選択肢

macOS で利用可能な通知音：

| 音名 | 特徴 |
|------|------|
| `Glass` | 軽快な音（デフォルト） |
| `Basso` | 低い警告音 |
| `Ping` | シンプルなピング音 |
| `Pop` | ポップ音 |
| `Purr` | 猫の鳴き声風 |
| `Submarine` | 潜水艦のソナー風 |
| `Blow` | 風のような音 |
| `Bottle` | ポンという音 |
| `Frog` | カエルの鳴き声 |
| `Funk` | ファンキーな音 |
| `Hero` | ヒーロー風の音 |
| `Morse` | モールス信号風 |
| `Sosumi` | クラシックな音 |
| `Tink` | 軽い金属音 |

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
