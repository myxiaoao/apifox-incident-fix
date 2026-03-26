#!/usr/bin/env bash

run_module_08() {
    section 8 "MOD8_NAME"

    if ! should_run_module 8 || ! ${MODULE_APPLICABLE[8]}; then
        info "$(msg NOT_APPLICABLE)"
        return
    fi

    info "$(msg ENV_SCANNING)"

    if [[ -n "$ENV_FILES" ]]; then
        warn "$(msg ENV_FOUND)"
        echo "$ENV_FILES" | tee -a "$LOG_FILE"
    else
        info "$(msg ENV_NONE)"
    fi
}
