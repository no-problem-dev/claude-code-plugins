#!/bin/bash
# go-backend plugin: 共通関数

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

# Go バックエンドディレクトリを検出
# 優先順位: 環境変数 > サブディレクトリ > カレントディレクトリ
detect_go_backend() {
    # 環境変数で指定されている場合
    if [[ -n "$GO_BACKEND_DIR" && -f "$GO_BACKEND_DIR/go.mod" ]]; then
        echo "$GO_BACKEND_DIR"
        return 0
    fi

    # カレントディレクトリに go.mod がある場合
    if [[ -f "go.mod" ]]; then
        echo "."
        return 0
    fi

    # 一般的なサブディレクトリ名
    for subdir in backend server api go; do
        if [[ -f "$subdir/go.mod" ]]; then
            echo "$subdir"
            return 0
        fi
    done

    # 再帰的に探索（深さ2まで）
    local gomod
    gomod=$(find . -maxdepth 2 -name "go.mod" -type f 2>/dev/null | head -1)
    if [[ -n "$gomod" ]]; then
        dirname "$gomod"
        return 0
    fi

    return 1
}

# main.go のパスを取得
get_main_path() {
    local backend_dir="$1"

    if [[ -n "$GO_MAIN_PATH" ]]; then
        echo "$GO_MAIN_PATH"
        return 0
    fi

    # 一般的なパス
    for path in "cmd/server/main.go" "cmd/api/main.go" "cmd/main.go" "main.go"; do
        if [[ -f "$backend_dir/$path" ]]; then
            echo "$path"
            return 0
        fi
    done

    # cmd/ 以下を探索
    local main_go
    main_go=$(find "$backend_dir/cmd" -name "main.go" -type f 2>/dev/null | head -1)
    if [[ -n "$main_go" ]]; then
        echo "${main_go#$backend_dir/}"
        return 0
    fi

    # ルートの main.go
    if [[ -f "$backend_dir/main.go" ]]; then
        echo "main.go"
        return 0
    fi

    return 1
}

# 出力バイナリ名を取得
get_bin_name() {
    if [[ -n "$GO_BIN_NAME" ]]; then
        echo "$GO_BIN_NAME"
        return 0
    fi

    echo "server"
}

# golangci-lint がインストールされているか確認
check_golangci_lint() {
    if command -v golangci-lint &> /dev/null; then
        return 0
    fi
    return 1
}

# swag がインストールされているか確認
check_swag() {
    if command -v swag &> /dev/null; then
        return 0
    fi
    if [[ -f "$HOME/go/bin/swag" ]]; then
        return 0
    fi
    return 1
}

# swag コマンドを取得
get_swag_cmd() {
    if command -v swag &> /dev/null; then
        echo "swag"
    elif [[ -f "$HOME/go/bin/swag" ]]; then
        echo "$HOME/go/bin/swag"
    else
        echo ""
    fi
}
