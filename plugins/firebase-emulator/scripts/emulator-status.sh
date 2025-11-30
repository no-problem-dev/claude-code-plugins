#!/bin/bash
# firebase-emulator plugin: 状態確認

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

main() {
    log_info "Firebase Emulator 状態確認..."

    local port_firestore port_auth port_storage port_ui
    port_firestore=$(get_port_firestore)
    port_auth=$(get_port_auth)
    port_storage=$(get_port_storage)
    port_ui=$(get_port_ui)

    echo ""
    echo "サービス状態:"

    local running=0
    local total=4

    if is_port_in_use "$port_firestore"; then
        echo -e "  Firestore (${port_firestore}): ${GREEN}起動中${NC}"
        ((running++))
    else
        echo -e "  Firestore (${port_firestore}): ${RED}停止${NC}"
    fi

    if is_port_in_use "$port_auth"; then
        echo -e "  Auth (${port_auth}): ${GREEN}起動中${NC}"
        ((running++))
    else
        echo -e "  Auth (${port_auth}): ${RED}停止${NC}"
    fi

    if is_port_in_use "$port_storage"; then
        echo -e "  Storage (${port_storage}): ${GREEN}起動中${NC}"
        ((running++))
    else
        echo -e "  Storage (${port_storage}): ${RED}停止${NC}"
    fi

    if is_port_in_use "$port_ui"; then
        echo -e "  UI (${port_ui}): ${GREEN}起動中${NC}"
        ((running++))
    else
        echo -e "  UI (${port_ui}): ${RED}停止${NC}"
    fi

    echo ""

    if [[ $running -eq $total ]]; then
        log_success "全サービス起動中 ($running/$total)"
        log_info "UI: http://localhost:$port_ui"
    elif [[ $running -gt 0 ]]; then
        log_warning "一部サービス起動中 ($running/$total)"
    else
        log_info "エミュレーターは停止しています"
        log_info "起動: /firebase-emulator:emulator-start"
    fi
}

main "$@"
