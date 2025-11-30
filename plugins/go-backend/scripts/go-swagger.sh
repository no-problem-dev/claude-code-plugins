#!/bin/bash
# go-backend plugin: Swagger生成

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

main() {
    log_info "Swagger ドキュメントを生成中..."

    # バックエンドディレクトリ検出
    local backend_dir
    backend_dir=$(detect_go_backend) || {
        log_error "Go プロジェクト (go.mod) が見つかりません"
        exit 1
    }
    log_info "ディレクトリ: $backend_dir"

    cd "$backend_dir"

    # swag を確認
    if ! check_swag; then
        log_warning "swag がインストールされていません"
        log_info "インストール中: go install github.com/swaggo/swag/cmd/swag@latest"
        go install github.com/swaggo/swag/cmd/swag@latest
    fi

    local swag_cmd
    swag_cmd=$(get_swag_cmd)
    if [[ -z "$swag_cmd" ]]; then
        log_error "swag のインストールに失敗しました"
        exit 1
    fi

    # main.go のパスを取得
    local main_path
    main_path=$(get_main_path ".") || {
        log_error "main.go が見つかりません"
        exit 1
    }

    local docs_dir="docs"

    log_info "$swag_cmd init -g $main_path -o $docs_dir"

    if $swag_cmd init -g "$main_path" -o "$docs_dir" --parseDependency --parseInternal; then
        log_success "Swagger 生成完了: $docs_dir/"
        exit 0
    else
        log_error "Swagger 生成失敗"
        exit 1
    fi
}

main "$@"
