#!/usr/bin/env bash

run_module_09() {
    section 9 "MOD9_NAME"

    if ! should_run_module 9; then
        info "$(msg NOT_APPLICABLE)"
        return
    fi

    manual "$(msg AUDIT_GITHUB)"

    echo ""
    manual "$(msg AUDIT_GIT) ${RISK_START}"
    info "  git log --since=\"${RISK_START}\" --oneline"

    if $HAS_KUBECTL && [[ -f "$HOME/.kube/config" ]]; then
        echo ""
        manual "$(msg AUDIT_K8S)"
        if [[ "$DRY_RUN" != true ]]; then
            kubectl get events --sort-by='.lastTimestamp' -A 2>/dev/null | head -20 | tee -a "$LOG_FILE" || true
        fi
    fi
}
