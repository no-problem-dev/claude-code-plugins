#!/bin/bash
# ios-dev plugin: テスト実行

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# 引数解析
COVERAGE=false
TARGET=""

for arg in "$@"; do
    case $arg in
        --coverage)
            COVERAGE=true
            ;;
        *)
            TARGET="$arg"
            ;;
    esac
done

main() {
    log_info "iOS テストを実行中..."

    # プロジェクト検出
    local project
    project=$(detect_ios_project) || {
        log_error "iOS プロジェクト (.xcodeproj) が見つかりません"
        exit 1
    }
    log_info "プロジェクト: $project"

    local scheme
    scheme=$(get_scheme "$project")
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

    # テスト実行
    local xcodebuild_args=(
        -project "$project"
        -scheme "$scheme"
        -destination "$destination"
    )

    if [[ "$COVERAGE" == true ]]; then
        log_info "カバレッジ付きでテスト実行..."
        xcodebuild_args+=(-enableCodeCoverage YES)
    fi

    xcodebuild_args+=(-resultBundlePath TestResults)
    xcodebuild_args+=(test)

    log_info "xcodebuild test 実行中..."

    # 既存の結果バンドルを削除
    rm -rf TestResults.xcresult 2>/dev/null || true

    if xcodebuild "${xcodebuild_args[@]}"; then
        log_success "全テスト成功"

        if [[ "$COVERAGE" == true ]]; then
            log_info "カバレッジレポートは TestResults.xcresult を参照"
        fi
        exit 0
    else
        log_error "テスト失敗"
        exit 1
    fi
}

main "$@"
