#!/bin/bash
# firebase-emulator plugin: エミュレーター停止

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

main() {
    log_info "Firebase Emulator を停止中..."

    local port_firestore port_auth port_storage port_ui
    port_firestore=$(get_port_firestore)
    port_auth=$(get_port_auth)
    port_storage=$(get_port_storage)
    port_ui=$(get_port_ui)

    local stopped=false

    for port in $port_firestore $port_auth $port_storage $port_ui; do
        if is_port_in_use "$port"; then
            log_info "ポート $port のプロセスを終了..."
            kill_port "$port"
            stopped=true
        fi
    done

    if [[ "$stopped" == true ]]; then
        log_success "Firebase Emulator を停止しました"
    else
        log_info "起動中のエミュレーターはありません"
    fi
}

main "$@"
