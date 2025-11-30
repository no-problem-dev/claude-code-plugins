#!/bin/bash
# go-backend plugin: ビルド

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

main() {
    log_info "Go バックエンドをビルド中..."

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

    local bin_name
    bin_name=$(get_bin_name)
    local bin_dir="bin"

    mkdir -p "$bin_dir"

    log_info "go build -o $bin_dir/$bin_name $main_path"

    if go build -o "$bin_dir/$bin_name" "$main_path"; then
        log_success "ビルド成功: $bin_dir/$bin_name"
        exit 0
    else
        log_error "ビルド失敗"
        exit 1
    fi
}

main "$@"
