#!/bin/bash
# ============================================================================
# notify.sh - Claude Code 停止・権限要求時の通知スクリプト
# ============================================================================
# 使用方法: notify.sh <event_type>
#   event_type: stop | notification | subagent | permission
#
# 環境変数（Slack 通知）:
#   SLACK_WEBHOOK_URL     - Slack Incoming Webhook URL
#
# 環境変数（通知設定）:
#   NOTIFY_SOUND          - 通知音 (デフォルト: Glass)
#   NOTIFY_SLACK_ENABLED  - Slack通知の有効化 (true/false, デフォルト: true)
#   NOTIFY_LOCAL_ENABLED  - ローカル通知の有効化 (true/false, デフォルト: true)
# ============================================================================

set -euo pipefail

# --- 設定 ---
EVENT_TYPE="${1:-unknown}"
SOUND="${NOTIFY_SOUND:-Glass}"
SLACK_ENABLED="${NOTIFY_SLACK_ENABLED:-true}"
LOCAL_ENABLED="${NOTIFY_LOCAL_ENABLED:-true}"

# stdin から JSON を読み取り
INPUT_JSON=""
if [ -t 0 ]; then
  : # stdin が tty の場合はスキップ
else
  INPUT_JSON=$(cat)
fi

# --- JSON からフィールドを抽出 ---
get_json_field() {
  local field="$1"
  if [[ -n "$INPUT_JSON" ]] && command -v jq &>/dev/null; then
    echo "$INPUT_JSON" | jq -r ".$field // empty" 2>/dev/null || echo ""
  else
    echo ""
  fi
}

# --- トランスクリプトから最後のタスク要約を取得 ---
get_task_summary() {
  local transcript_path
  transcript_path=$(get_json_field "transcript_path")

  if [[ -z "$transcript_path" || ! -f "$transcript_path" ]]; then
    echo ""
    return
  fi

  # トランスクリプトの最後の assistant メッセージから要約を抽出
  # 最後の数行を取得し、テキスト部分を抽出
  local summary
  summary=$(tail -20 "$transcript_path" 2>/dev/null | \
    grep -o '"text":"[^"]*"' | \
    tail -1 | \
    sed 's/"text":"//;s/"$//' | \
    head -c 100)

  if [[ -n "$summary" ]]; then
    echo "$summary..."
  else
    echo ""
  fi
}

# --- イベント別のメッセージ設定 ---
get_message_config() {
  local event="$1"
  local title=""
  local message=""
  local detail=""
  local emoji=""
  local sound="$SOUND"

  case "$event" in
    stop)
      title="Claude Code"
      message="作業が完了しました"
      emoji="white_check_mark"
      # タスク要約を取得
      detail=$(get_task_summary)
      ;;
    notification)
      title="Claude Code"
      # hooks から渡されたメッセージを使用
      local hook_message
      hook_message=$(get_json_field "message")
      if [[ -n "$hook_message" ]]; then
        message="$hook_message"
      else
        message="入力を待っています"
      fi
      emoji="bell"
      sound="Basso"
      ;;
    subagent)
      title="Claude Code"
      message="サブエージェントが完了しました"
      emoji="robot_face"
      ;;
    permission)
      title="Claude Code - 確認が必要"
      # ツール名と入力を取得
      local tool_name tool_input
      tool_name=$(get_json_field "tool_name")
      tool_input=$(get_json_field "tool_input")

      if [[ -n "$tool_name" ]]; then
        message="権限を求めています: $tool_name"
        # tool_input から詳細を抽出（最初の100文字）
        if [[ -n "$tool_input" ]]; then
          detail=$(echo "$tool_input" | jq -r 'if type == "object" then (to_entries | map("\(.key): \(.value)") | join(", ")) else . end' 2>/dev/null | head -c 100)
        fi
      else
        message="権限の許可を求めています"
      fi
      emoji="warning"
      sound="Basso"
      ;;
    *)
      title="Claude Code"
      message="通知があります"
      emoji="speech_balloon"
      ;;
  esac

  echo "$title|$message|$detail|$emoji|$sound"
}

# --- macOS ローカル通知 ---
send_local_notification() {
  local title="$1"
  local message="$2"
  local detail="$3"
  local sound="$4"

  if [[ "$LOCAL_ENABLED" != "true" ]]; then
    return 0
  fi

  local full_message="$message"
  if [[ -n "$detail" ]]; then
    full_message="$message\n$detail"
  fi

  # osascript を使用（依存関係なし）
  osascript -e "display notification \"$full_message\" with title \"$title\" sound name \"$sound\"" 2>/dev/null || true
}

# --- Slack 通知 ---
send_slack_notification() {
  local title="$1"
  local message="$2"
  local detail="$3"
  local emoji="$4"

  if [[ "$SLACK_ENABLED" != "true" ]]; then
    return 0
  fi

  # メッセージ本文を構築
  local text=":${emoji}: *${title}*\n${message}"
  if [[ -n "$detail" ]]; then
    text="${text}\n\`\`\`${detail}\`\`\`"
  fi

  local payload
  payload=$(cat <<EOF
{
  "blocks": [
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "${text}"
      }
    }
  ]
}
EOF
)

  if [[ -n "${SLACK_WEBHOOK_URL:-}" ]]; then
    curl -s -X POST \
      -H 'Content-type: application/json' \
      --data "$payload" \
      "$SLACK_WEBHOOK_URL" >/dev/null 2>&1 || true
  fi
}

# --- メイン処理 ---
main() {
  local config
  config=$(get_message_config "$EVENT_TYPE")

  IFS='|' read -r title message detail emoji sound <<< "$config"

  # 並列で通知を送信
  send_local_notification "$title" "$message" "$detail" "$sound" &
  send_slack_notification "$title" "$message" "$detail" "$emoji" &

  wait
}

main
