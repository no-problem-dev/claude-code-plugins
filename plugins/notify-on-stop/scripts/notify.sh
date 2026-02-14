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
#   NOTIFY_SLACK_ENABLED  - Slack通知の有効化 (true/false, デフォルト: true)
#   NOTIFY_LOCAL_ENABLED  - ローカル通知の有効化 (true/false, デフォルト: true)
#   NOTIFY_SUBAGENT_ENABLED - サブエージェント完了通知 (true/false, デフォルト: false)
# ============================================================================

set -euo pipefail

# --- 設定 ---
EVENT_TYPE="${1:-unknown}"
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
# 各イベントで音・emoji・色を完全に分けて、聞くだけ/見るだけで何が起きたかわかるようにする
#
#   stop        完了（穏やか）     Glass   緑  ✅
#   notification 入力待ち（注意）   Ping    黄  👋
#   permission   権限要求（緊急）   Sosumi  赤  🔐
#   subagent     サブ完了（軽い）   Tink    青  ⚡
get_message_config() {
  local event="$1"
  local title=""
  local message=""
  local detail=""
  local emoji=""
  local sound=""
  local color=""

  case "$event" in
    stop)
      title="完了"
      message="作業が完了しました"
      emoji="white_check_mark"
      sound="Glass"
      color="#2ea44f"
      detail=$(get_task_summary)
      ;;
    notification)
      title="入力待ち"
      hook_message=$(get_json_field "message")
      if [[ -n "$hook_message" ]]; then
        message="$hook_message"
      else
        message="入力を待っています"
      fi
      emoji="wave"
      sound="Ping"
      color="#d29922"
      ;;
    subagent)
      title="サブエージェント完了"
      message="サブエージェントが完了しました"
      emoji="zap"
      sound="Tink"
      color="#388bfd"
      ;;
    permission)
      title="権限が必要"
      local tool_name tool_input
      tool_name=$(get_json_field "tool_name")
      tool_input=$(get_json_field "tool_input")

      if [[ -n "$tool_name" ]]; then
        message="$tool_name の実行許可が必要です"
        if [[ -n "$tool_input" ]]; then
          detail=$(echo "$tool_input" | jq -r 'if type == "object" then (to_entries | map("\(.key): \(.value)") | join(", ")) else . end' 2>/dev/null | head -c 100)
        fi
      else
        message="権限の許可が必要です"
      fi
      emoji="lock"
      sound="Sosumi"
      color="#da3633"
      ;;
    *)
      title="Claude Code"
      message="通知があります"
      emoji="speech_balloon"
      sound="Glass"
      color="#848d97"
      ;;
  esac

  echo "$title|$message|$detail|$emoji|$sound|$color"
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

  osascript -e "display notification \"$full_message\" with title \"Claude Code - $title\" sound name \"$sound\"" 2>/dev/null || true
}

# --- Slack 通知 ---
send_slack_notification() {
  local title="$1"
  local message="$2"
  local detail="$3"
  local emoji="$4"
  local color="$5"

  if [[ "$SLACK_ENABLED" != "true" ]]; then
    return 0
  fi

  if [[ -z "${SLACK_WEBHOOK_URL:-}" ]]; then
    return 0
  fi

  # detail があれば付加
  local detail_block=""
  if [[ -n "$detail" ]]; then
    detail_block=", {\"type\": \"context\", \"elements\": [{\"type\": \"mrkdwn\", \"text\": \"\`$detail\`\"}]}"
  fi

  local payload
  payload=$(cat <<EOF
{
  "attachments": [
    {
      "color": "${color}",
      "blocks": [
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": ":${emoji}: *${title}*  ${message}"
          }
        }${detail_block}
      ]
    }
  ]
}
EOF
)

  curl -s -X POST \
    -H 'Content-type: application/json' \
    --data "$payload" \
    "$SLACK_WEBHOOK_URL" >/dev/null 2>&1 || true
}

# --- メイン処理 ---
main() {
  # サブエージェント通知はデフォルト無効（環境変数で有効化可能）
  if [[ "$EVENT_TYPE" == "subagent" && "${NOTIFY_SUBAGENT_ENABLED:-false}" != "true" ]]; then
    exit 0
  fi

  local config
  config=$(get_message_config "$EVENT_TYPE")

  IFS='|' read -r title message detail emoji sound color <<< "$config"

  # 並列で通知を送信
  send_local_notification "$title" "$message" "$detail" "$sound" &
  send_slack_notification "$title" "$message" "$detail" "$emoji" "$color" &

  wait
}

main
