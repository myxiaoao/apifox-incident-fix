#!/usr/bin/env bash

run_module_01() {
    section 1 "MOD1_NAME"

    if ! should_run_module 1 || ! ${MODULE_APPLICABLE[1]}; then
        info "$(msg KILL_NONE)"
        return
    fi

    # Use same precise pattern as detection in detect.sh
    local pids
    pids="$(pgrep -f "$APIFOX_PROC_PATTERN" 2>/dev/null || true)"

    if [[ -z "$pids" ]]; then
        log "$(msg KILL_NONE)"
        return
    fi

    warn "$(msg KILL_FOUND)"
    ps -p "$(echo "$pids" | tr '\n' ',' | sed 's/,$//')" -o pid,comm 2>/dev/null || true

    if ! pause; then return; fi

    if [[ "$DRY_RUN" == true ]]; then
        info "$(msg DRY_RUN_PREFIX): kill Apifox processes (PIDs: $(echo "$pids" | tr '\n' ',' | sed 's/,$//'))"
        return
    fi

    # Kill by exact PIDs instead of pattern to avoid collateral
    while IFS= read -r pid; do
        [[ -z "$pid" ]] && continue
        kill "$pid" 2>/dev/null || true
    done <<< "$pids"

    sleep 1

    # Check if any survived, force kill by PID
    local remaining
    remaining="$(pgrep -f "$APIFOX_PROC_PATTERN" 2>/dev/null || true)"
    if [[ -n "$remaining" ]]; then
        warn "$(msg KILL_FORCE)"
        while IFS= read -r pid; do
            [[ -z "$pid" ]] && continue
            kill -9 "$pid" 2>/dev/null || true
        done <<< "$remaining"
    fi
    log "$(msg KILL_DONE)"
}
