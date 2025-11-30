#!/bin/bash
# ios-dev plugin: フルビルド

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# 引数
SCHEME_ARG="$1"
CONFIG_ARG="${2:-Debug}"

main() {
    log_info "iOS フルビルドを実行中..."

    # プロジェクト検出
    local project
    project=$(detect_ios_project) || {
        log_error "iOS プロジェクト (.xcodeproj) が見つかりません"
        exit 1
    }
    log_info "プロジェクト: $project"

    local scheme
    scheme=$(get_scheme "$project" "$SCHEME_ARG")
    log_info "スキーム: $scheme"
    log_info "構成: $CONFIG_ARG"

    local simulator
    simulator=$(get_simulator)
    log_info "シミュレーター: $simulator"

    local destination
    destination=$(build_destination "$simulator")

    log_info "xcodebuild でビルド中..."

    if xcodebuild \
        -project "$project" \
        -scheme "$scheme" \
        -destination "$destination" \
        -configuration "$CONFIG_ARG" \
        build; then
        log_success "ビルド成功"
        exit 0
    else
        log_error "ビルド失敗"
        exit 1
    fi
}

main "$@"
