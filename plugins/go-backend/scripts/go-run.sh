#!/bin/bash
# go-backend plugin: 開発サーバー起動

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

main() {
    log_info "Go 開発サーバーを起動中..."

    # バックエンドディレクトリ検出
    local backend_dir
    backend_dir=$(detect_go_backend) || {
        log_error "Go プロジェクト (go.mod) が見つかりません"
        exit 1
    }
    log_info "ディレクトリ: $backend_dir"

    cd "$backend_dir"

    local main_path
    main_path=$(get_main_path ".") || {
        log_error "main.go が見つかりません"
        exit 1
    }
    log_info "メインパス: $main_path"

    log_info "go run $main_path"
    go run "$main_path"
}

main "$@"
