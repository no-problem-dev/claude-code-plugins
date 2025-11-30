#!/bin/bash
# ios-dev plugin: シミュレーターで実行

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# 引数
SIMULATOR_ARG="$1"

main() {
    log_info "iOS アプリをシミュレーターで実行..."

    # シミュレーター確認
    local simulator_id
    simulator_id=$(get_booted_simulator_id)

    if [[ -z "$simulator_id" ]]; then
        log_warning "起動中のシミュレーターがありません"
        log_info "シミュレーターを起動中..."

        # シミュレーターを起動
        open -a Simulator
        sleep 3

        # 再度確認
        simulator_id=$(get_booted_simulator_id)
        if [[ -z "$simulator_id" ]]; then
            log_error "シミュレーターの起動に失敗しました"
            log_info "手動で起動してください: open -a Simulator"
            exit 1
        fi
    fi

    log_info "シミュレーター ID: $simulator_id"

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

    local build_dir="build"

    # Bundle ID を取得
    local bundle_id
    bundle_id=$(xcodebuild -project "$project" -scheme "$scheme" -showBuildSettings 2>/dev/null | \
        grep "PRODUCT_BUNDLE_IDENTIFIER" | head -1 | awk '{print $3}')

    if [[ -z "$bundle_id" ]]; then
        log_error "Bundle ID を取得できません"
        exit 1
    fi
    log_info "Bundle ID: $bundle_id"

    # ビルド
    log_info "ビルド中..."
    if ! xcodebuild \
        -project "$project" \
        -scheme "$scheme" \
        -destination "id=$simulator_id" \
        -derivedDataPath "$build_dir" \
        build; then
        log_error "ビルド失敗"
        exit 1
    fi

    # アプリのパスを検索
    local app_path
    app_path=$(find "$build_dir" -name "*.app" -path "*Debug-iphonesimulator*" | head -1)

    if [[ -z "$app_path" ]]; then
        log_error "ビルドされたアプリが見つかりません"
        exit 1
    fi
    log_info "アプリ: $app_path"

    # インストール
    log_info "シミュレーターにインストール中..."
    xcrun simctl install "$simulator_id" "$app_path"

    # 起動
    log_info "アプリを起動中..."
    xcrun simctl launch "$simulator_id" "$bundle_id"

    log_success "アプリが起動しました"
}

main "$@"
