#!/bin/bash
# go-backend plugin: テスト実行

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# 引数解析
COVERAGE=false
VERBOSE=false
PACKAGE=""

for arg in "$@"; do
    case $arg in
        --coverage|coverage)
            COVERAGE=true
            ;;
        --verbose|-v|verbose)
            VERBOSE=true
            ;;
        *)
            PACKAGE="$arg"
            ;;
    esac
done

main() {
    log_info "Go テストを実行中..."

    # バックエンドディレクトリ検出
    local backend_dir
    backend_dir=$(detect_go_backend) || {
        log_error "Go プロジェクト (go.mod) が見つかりません"
        exit 1
    }
    log_info "ディレクトリ: $backend_dir"

    cd "$backend_dir"

    local test_args=()

    if [[ "$VERBOSE" == true ]]; then
        test_args+=("-v")
    fi

    if [[ "$COVERAGE" == true ]]; then
        log_info "カバレッジ付きでテスト実行..."
        test_args+=("-cover" "-coverprofile=coverage.out")
    fi

    local target="./..."
    if [[ -n "$PACKAGE" ]]; then
        target="$PACKAGE"
    fi

    log_info "go test ${test_args[*]} $target"

    if go test "${test_args[@]}" "$target"; then
        log_success "全テスト成功"

        if [[ "$COVERAGE" == true ]]; then
            log_info "カバレッジレポートを生成中..."
            go tool cover -html=coverage.out -o coverage.html
            log_success "カバレッジレポート: coverage.html"
        fi
        exit 0
    else
        log_error "テスト失敗"
        exit 1
    fi
}

main "$@"
