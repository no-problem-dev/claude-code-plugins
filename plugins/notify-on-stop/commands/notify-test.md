---
description: notify-on-stop プラグインの通知テストを実行
allowed-tools: Bash
---

# notify-on-stop 通知テスト

すべての通知タイプをテストします。

## テスト実行

以下のコマンドを順番に実行し、各通知が正しく動作するか確認してください：

```bash
# 1. 作業完了通知のテスト
${CLAUDE_PLUGIN_ROOT}/scripts/notify.sh stop

# 2. 入力待ち通知のテスト
${CLAUDE_PLUGIN_ROOT}/scripts/notify.sh notification

# 3. 権限要求通知のテスト
${CLAUDE_PLUGIN_ROOT}/scripts/notify.sh permission

# 4. サブエージェント完了通知のテスト
${CLAUDE_PLUGIN_ROOT}/scripts/notify.sh subagent
```

## 期待される結果

各テストで以下が発生するはずです：

1. **macOS 通知センター**に通知が表示される
2. **通知音**が鳴る（Glass または Basso）
3. **Slack チャンネル**にメッセージが投稿される（`SLACK_WEBHOOK_URL` 設定時のみ）

## トラブルシューティング

通知が表示されない場合：
- システム設定 → 通知 → ターミナルアプリの通知を許可
- `NOTIFY_LOCAL_ENABLED` が `false` になっていないか確認

Slack に届かない場合：
- `echo $SLACK_WEBHOOK_URL` で URL が設定されているか確認
- `NOTIFY_SLACK_ENABLED` が `false` になっていないか確認
