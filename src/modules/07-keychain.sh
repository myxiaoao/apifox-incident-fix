#!/usr/bin/env bash

run_module_07() {
    section 7 "MOD7_NAME"

    if ! should_run_module 7 || ! ${MODULE_APPLICABLE[7]}; then
        info "$(msg NOT_APPLICABLE)"
        return
    fi

    if [[ "$OS_TYPE" != "macos" ]]; then
        info "$(msg KEYCHAIN_LINUX)"
        return
    fi

    info "$(msg KEYCHAIN_SEARCHING)"
    local items
    items="$(security find-generic-password -l "apifox" 2>&1 || true)"

    if echo "$items" | grep -q "could not be found"; then
        info "$(msg KEYCHAIN_NONE)"
    else
        warn "$(msg KEYCHAIN_FOUND)"
        echo "$items" | tee -a "$LOG_FILE"
    fi

    echo ""
    manual "$(msg KEYCHAIN_MANUAL)"
}
