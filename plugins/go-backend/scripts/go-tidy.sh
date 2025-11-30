#!/bin/bash
# go-backend plugin: 依存関係整理

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

main() {
    log_info "Go 依存関係を整理中..."

    # バックエンドディレクトリ検出
    local backend_dir
    backend_dir=$(detect_go_backend) || {
        log_error "Go プロジェクト (go.mod) が見つかりません"
        exit 1
    }
    log_info "ディレクトリ: $backend_dir"

    cd "$backend_dir"

    log_info "go mod tidy"

    if go mod tidy; then
        log_success "依存関係を整理しました"
        exit 0
    else
        log_error "go mod tidy 失敗"
        exit 1
    fi
}

main "$@"
