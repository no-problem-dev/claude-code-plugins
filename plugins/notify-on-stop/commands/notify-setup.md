---
description: notify-on-stop プラグインのセットアップガイドを表示
allowed-tools: Read, Bash
---

# notify-on-stop セットアップガイド

ユーザーの現在の設定状況を確認し、必要なセットアップ手順を案内してください。

## 確認手順

1. `~/.claude/settings.json` を読み取り、現在の `env` セクションの設定を確認
2. `SLACK_WEBHOOK_URL` が設定されているかチェック

## 案内内容

### 設定済みの場合

```
✅ notify-on-stop は正しく設定されています

現在の設定:
- SLACK_WEBHOOK_URL: 設定済み
- NOTIFY_SOUND: [値または "Glass (デフォルト)"]
- NOTIFY_SLACK_ENABLED: [値または "true (デフォルト)"]
- NOTIFY_LOCAL_ENABLED: [値または "true (デフォルト)"]

テストするには `/notify-test` を実行してください。
```

### 未設定の場合

```
📋 notify-on-stop セットアップガイド

## Slack 通知を有効にする

1. Slack API (https://api.slack.com/apps) でアプリを作成
2. Incoming Webhooks を有効化
3. Add New Webhook to Workspace でチャンネルを選択
4. 生成された URL を以下のコマンドで設定:

   ~/.claude/settings.json を編集して以下を追加:

   {
     "env": {
       "SLACK_WEBHOOK_URL": "https://hooks.slack.com/services/..."
     }
   }

## Slack 通知が不要な場合

ローカル通知のみで使用する場合、追加設定は不要です。
プラグインをインストールした時点で macOS 通知は有効です。

## 通知音をカスタマイズ

{
  "env": {
    "NOTIFY_SOUND": "Ping"
  }
}

利用可能な音: Glass, Basso, Ping, Pop, Submarine など
```
