#!/bin/bash
# firebase-emulator plugin: エミュレーター起動

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

main() {
    log_info "Firebase Emulator を起動中..."

    # Firebase ディレクトリ検出
    local firebase_dir
    firebase_dir=$(detect_firebase_dir) || {
        log_error "Firebase プロジェクト (firebase.json) が見つかりません"
        log_info "firebase init でプロジェクトを初期化してください"
        exit 1
    }
    log_info "ディレクトリ: $firebase_dir"

    cd "$firebase_dir"

    # プロジェクトID
    local project_id
    project_id=$(get_project_id "$firebase_dir")
    log_info "プロジェクト: $project_id"

    # ポート確認
    local port_firestore port_auth port_storage port_ui
    port_firestore=$(get_port_firestore)
    port_auth=$(get_port_auth)
    port_storage=$(get_port_storage)
    port_ui=$(get_port_ui)

    log_info "ポート設定:"
    log_info "  Firestore: $port_firestore"
    log_info "  Auth: $port_auth"
    log_info "  Storage: $port_storage"
    log_info "  UI: $port_ui"

    # 既存プロセス確認
    local ports_in_use=false
    for port in $port_firestore $port_auth $port_storage $port_ui; do
        if is_port_in_use "$port"; then
            log_warning "ポート $port は既に使用中です"
            ports_in_use=true
        fi
    done

    if [[ "$ports_in_use" == true ]]; then
        log_warning "既存のエミュレーターが起動中の可能性があります"
        log_info "停止する場合: /firebase-emulator:emulator-stop"
    fi

    # バックグラウンドで起動
    log_info "エミュレーターをバックグラウンドで起動..."

    nohup firebase emulators:start --project="$project_id" > emulator.log 2>&1 &

    # 起動待機
    sleep 3

    # 起動確認
    if is_port_in_use "$port_ui"; then
        log_success "Firebase Emulator が起動しました"
        log_info "UI: http://localhost:$port_ui"
        log_info "ログ: $firebase_dir/emulator.log"
    else
        log_error "エミュレーターの起動に失敗した可能性があります"
        log_info "ログを確認: cat $firebase_dir/emulator.log"
        exit 1
    fi
}

main "$@"
