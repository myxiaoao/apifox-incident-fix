#!/usr/bin/env bash

run_module_06() {
    section 6 "MOD6_NAME"

    if ! should_run_module 6 || ! ${MODULE_APPLICABLE[6]}; then
        if ! $HAS_DOCKER; then
            info "$(msg DOCKER_NO_CLI)"
        else
            info "$(msg DOCKER_NO_CONFIG)"
        fi
        return
    fi

    info "$(msg DOCKER_REGISTRIES)"
    echo "$DOCKER_REGISTRIES" | tee -a "$LOG_FILE"

    if ! pause; then return; fi

    if [[ "$DRY_RUN" == true ]]; then
        info "$(msg DRY_RUN_PREFIX): logout all Docker registries"
    else
        while IFS= read -r registry; do
            [[ -z "$registry" ]] && continue
            docker logout "$registry" 2>/dev/null || true
        done <<< "$DOCKER_REGISTRIES"
        log "$(msg DOCKER_LOGOUT)"
    fi

    echo ""
    manual "$(msg DOCKER_MANUAL)"
}
