#!/bin/bash
# ios-dev plugin: クリーンアップ

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# 引数
CLEAN_ALL=false

for arg in "$@"; do
    case $arg in
        --all)
            CLEAN_ALL=true
            ;;
    esac
done

main() {
    log_info "iOS ビルドキャッシュをクリア中..."

    # プロジェクト検出
    local project
    project=$(detect_ios_project) || {
        log_error "iOS プロジェクト (.xcodeproj) が見つかりません"
        exit 1
    }
    log_info "プロジェクト: $project"

    local scheme
    scheme=$(get_scheme "$project")

    log_info "xcodebuild clean 実行中..."
    xcodebuild clean \
        -project "$project" \
        -scheme "$scheme" 2>/dev/null || true

    # ビルドディレクトリ削除
    log_info "ビルドディレクトリを削除..."
    rm -rf build/ 2>/dev/null || true

    local ios_dir
    ios_dir=$(get_ios_dir "$project")
    rm -rf "$ios_dir/build/" 2>/dev/null || true

    # テスト結果削除
    rm -rf TestResults.xcresult 2>/dev/null || true
    rm -rf "$ios_dir/TestResults.xcresult" 2>/dev/null || true

    # 完全クリーン
    if [[ "$CLEAN_ALL" == true ]]; then
        log_info "DerivedData をクリア中..."

        local project_name
        project_name=$(basename "$project" .xcodeproj)

        # プロジェクト固有の DerivedData を削除
        rm -rf ~/Library/Developer/Xcode/DerivedData/"${project_name}-"* 2>/dev/null || true

        # SPM キャッシュ
        log_info "SPM キャッシュをクリア中..."
        rm -rf .build/ 2>/dev/null || true
        rm -rf "$ios_dir/.build/" 2>/dev/null || true

        log_success "完全クリーン完了"
    else
        log_success "クリーン完了"
        log_info "DerivedData も削除するには: --all オプションを使用"
    fi
}

main "$@"
