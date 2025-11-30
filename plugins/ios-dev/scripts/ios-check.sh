#!/bin/bash
# ios-dev plugin: コンパイルエラーチェック（高速）

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# 引数
SCHEME_ARG="$1"

main() {
    log_info "iOS コンパイルエラーをチェック中..."

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

    local simulator
    simulator=$(get_simulator)

    local destination
    destination=$(build_destination "$simulator")

    # 実際に使用するシミュレーター名をログに表示
    local actual_simulator
    actual_simulator=$(get_booted_simulator_name)
    if [[ -n "$actual_simulator" ]]; then
        log_info "シミュレーター: $actual_simulator (起動中)"
    else
        log_info "シミュレーター: $simulator"
    fi

    log_info "xcodebuild でエラーチェック中..."

    # -quiet でビルドし、エラー・警告のみ抽出
    local output
    output=$(xcodebuild \
        -project "$project" \
        -scheme "$scheme" \
        -destination "$destination" \
        build -quiet 2>&1 || true)

    # エラー・警告を抽出
    local errors
    errors=$(echo "$output" | grep -E "(error:|warning:|FAILED)" | grep -v "note:" | head -50)

    if [[ -z "$errors" ]]; then
        log_success "コンパイルエラーはありません"
        exit 0
    else
        log_error "エラー/警告が見つかりました:"
        echo ""
        echo "$errors"
        exit 1
    fi
}

main "$@"
