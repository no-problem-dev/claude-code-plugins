#!/bin/bash
# firebase-emulator plugin: 共通関数

set -e

# 色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ログ関数
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Firebase ディレクトリを検出
detect_firebase_dir() {
    # 環境変数で指定されている場合
    if [[ -n "$FIREBASE_DIR" && -f "$FIREBASE_DIR/firebase.json" ]]; then
        echo "$FIREBASE_DIR"
        return 0
    fi

    # カレントディレクトリに firebase.json がある場合
    if [[ -f "firebase.json" ]]; then
        echo "."
        return 0
    fi

    # firebase/ サブディレクトリ
    if [[ -f "firebase/firebase.json" ]]; then
        echo "firebase"
        return 0
    fi

    # 再帰的に探索（深さ2まで）
    local firebase_json
    firebase_json=$(find . -maxdepth 2 -name "firebase.json" -type f 2>/dev/null | head -1)
    if [[ -n "$firebase_json" ]]; then
        dirname "$firebase_json"
        return 0
    fi

    return 1
}

# プロジェクトIDを取得
get_project_id() {
    if [[ -n "$FIREBASE_PROJECT_ID" ]]; then
        echo "$FIREBASE_PROJECT_ID"
        return 0
    fi

    if [[ -n "$GCP_PROJECT_ID" ]]; then
        echo "$GCP_PROJECT_ID"
        return 0
    fi

    # .firebaserc から取得
    local firebase_dir="$1"
    if [[ -f "$firebase_dir/.firebaserc" ]]; then
        local project_id
        project_id=$(grep -o '"default": *"[^"]*"' "$firebase_dir/.firebaserc" | sed 's/"default": *"\([^"]*\)"/\1/')
        if [[ -n "$project_id" ]]; then
            echo "$project_id"
            return 0
        fi
    fi

    echo "demo-project"
}

# ポート設定を取得
get_port_firestore() {
    echo "${EMULATOR_PORT_FIRESTORE:-8090}"
}

get_port_auth() {
    echo "${EMULATOR_PORT_AUTH:-9099}"
}

get_port_storage() {
    echo "${EMULATOR_PORT_STORAGE:-9199}"
}

get_port_ui() {
    echo "${EMULATOR_PORT_UI:-4000}"
}

# ポートが使用中か確認
is_port_in_use() {
    local port="$1"
    lsof -i ":$port" > /dev/null 2>&1
}

# ポートのプロセスを終了
kill_port() {
    local port="$1"
    lsof -ti ":$port" | xargs kill -9 2>/dev/null || true
}
