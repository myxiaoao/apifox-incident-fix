#!/usr/bin/env bash

run_module_05() {
    section 5 "MOD5_NAME"

    if ! should_run_module 5 || ! ${MODULE_APPLICABLE[5]}; then
        info "$(msg K8S_NONE)"
        return
    fi

    local ctx
    ctx="$(kubectl config current-context 2>/dev/null || echo 'unknown')"
    info "$(msg K8S_FOUND) $ctx"

    if ! pause; then return; fi

    local backup="$HOME/.kube/config.compromised_backup_$(date +%Y%m%d_%H%M%S)"
    run_or_dry "backup kubeconfig" cp "$HOME/.kube/config" "$backup"
    if [[ "$DRY_RUN" != true ]]; then
        log "$(msg K8S_BACKUP) $backup"
    fi

    echo ""
    manual "$(msg K8S_MANUAL)"
}
