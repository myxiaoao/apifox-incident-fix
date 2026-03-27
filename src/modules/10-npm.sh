#!/usr/bin/env bash

run_module_10() {
    section 10 "MOD10_NAME"

    if ! should_run_module 10 || ! ${MODULE_APPLICABLE[10]}; then
        info "$(msg NPM_NONE)"
        return
    fi

    # Show found tokens (masked), excluding comment lines
    info "$(msg NPM_FOUND)"
    grep -vE '^[[:space:]]*[#;]' "$HOME/.npmrc" 2>/dev/null | grep -E '_authToken=' | sed 's/\(_authToken=\).*/\1****/' | tee -a "$LOG_FILE"

    if ! pause; then return; fi

    local backup="$HOME/.npmrc.compromised_backup_$(date +%Y%m%d_%H%M%S)"
    run_or_dry "backup ~/.npmrc" cp "$HOME/.npmrc" "$backup"
    if [[ "$DRY_RUN" != true ]]; then
        log "$(msg NPM_BACKUP) $backup"
    fi

    echo ""
    manual "$(msg NPM_MANUAL)"
}
