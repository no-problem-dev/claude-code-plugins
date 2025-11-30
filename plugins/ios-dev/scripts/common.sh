#!/bin/bash
# ios-dev plugin: 共通関数

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

# iOS プロジェクトを検出
# 優先順位: 環境変数 > サブディレクトリ > カレントディレクトリ
detect_ios_project() {
    # 環境変数で指定されている場合
    if [[ -n "$IOS_PROJECT" && -d "$IOS_PROJECT" ]]; then
        echo "$IOS_PROJECT"
        return 0
    fi

    # .xcodeproj を探索
    local xcodeproj

    # カレントディレクトリ
    xcodeproj=$(find . -maxdepth 1 -name "*.xcodeproj" -type d 2>/dev/null | head -1)
    if [[ -n "$xcodeproj" ]]; then
        echo "$xcodeproj"
        return 0
    fi

    # 一般的なサブディレクトリ名
    for subdir in ios ios-app app *-ios; do
        if [[ -d "$subdir" ]]; then
            xcodeproj=$(find "$subdir" -maxdepth 1 -name "*.xcodeproj" -type d 2>/dev/null | head -1)
            if [[ -n "$xcodeproj" ]]; then
                echo "$xcodeproj"
                return 0
            fi
        fi
    done

    # 再帰的に探索（深さ2まで）
    xcodeproj=$(find . -maxdepth 2 -name "*.xcodeproj" -type d 2>/dev/null | head -1)
    if [[ -n "$xcodeproj" ]]; then
        echo "$xcodeproj"
        return 0
    fi

    return 1
}

# iOS プロジェクトディレクトリを取得（.xcodeprojの親ディレクトリ）
get_ios_dir() {
    local project="$1"
    dirname "$project"
}

# スキーム名を取得
# 優先順位: 引数 > 環境変数 > プロジェクト名から推測
get_scheme() {
    local project="$1"
    local arg_scheme="$2"

    if [[ -n "$arg_scheme" ]]; then
        echo "$arg_scheme"
        return 0
    fi

    if [[ -n "$IOS_SCHEME" ]]; then
        echo "$IOS_SCHEME"
        return 0
    fi

    # プロジェクト名から推測
    local project_name
    project_name=$(basename "$project" .xcodeproj)
    echo "$project_name"
}

# シミュレーター名を取得
get_simulator() {
    local arg_simulator="$1"

    if [[ -n "$arg_simulator" ]]; then
        echo "$arg_simulator"
        return 0
    fi

    if [[ -n "$IOS_SIMULATOR" ]]; then
        echo "$IOS_SIMULATOR"
        return 0
    fi

    # デフォルト
    echo "iPhone 16 Pro"
}

# 起動中のシミュレーターIDを取得
get_booted_simulator_id() {
    xcrun simctl list devices | grep "Booted" | sed -E 's/.*\(([0-9A-F-]+)\).*/\1/' | head -1
}

# xcodebuild destination を構築
build_destination() {
    local simulator_name="$1"
    local simulator_id
    simulator_id=$(get_booted_simulator_id)

    if [[ -n "$simulator_id" ]]; then
        echo "id=$simulator_id"
    else
        echo "platform=iOS Simulator,name=$simulator_name"
    fi
}
