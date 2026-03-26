#!/usr/bin/env bash

run_module_04() {
    section 4 "MOD4_NAME"

    if ! should_run_module 4 || ! ${MODULE_APPLICABLE[4]}; then
        if ! $HAS_GH; then
            warn "$(msg GITHUB_NO_CLI)"
        fi
        return
    fi

    info "$(msg GITHUB_STATUS)"
    gh auth status 2>&1 | tee -a "$LOG_FILE" || true

    if ! pause; then return; fi

    if [[ "$DRY_RUN" == true ]]; then
        info "$(msg DRY_RUN_PREFIX): logout and re-login GitHub CLI"
    else
        gh auth logout 2>/dev/null || true
        log "$(msg GITHUB_LOGOUT)"
        echo ""
        info "$(msg GITHUB_LOGIN)"
        gh auth login
        log "$(msg GITHUB_DONE)"
    fi

    echo ""
    manual "$(msg GITHUB_MANUAL_TOKENS)"
    manual "$(msg GITHUB_MANUAL_SESSIONS)"
}
