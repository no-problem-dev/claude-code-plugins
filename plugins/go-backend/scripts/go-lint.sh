#!/bin/bash
# go-backend plugin: Lint実行

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

main() {
    log_info "Go Lint を実行中..."

    # バックエンドディレクトリ検出
    local backend_dir
    backend_dir=$(detect_go_backend) || {
        log_error "Go プロジェクト (go.mod) が見つかりません"
        exit 1
    }
    log_info "ディレクトリ: $backend_dir"

    cd "$backend_dir"

    # golangci-lint を確認
    if ! check_golangci_lint; then
        log_error "golangci-lint がインストールされていません"
        log_info "インストール方法: brew install golangci-lint"
        log_info "または: go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest"
        exit 1
    fi

    log_info "golangci-lint run ./..."

    if golangci-lint run ./...; then
        log_success "Lint 問題なし"
        exit 0
    else
        log_error "Lint エラーあり"
        exit 1
    fi
}

main "$@"
