#!/usr/bin/env bash

run_module_08() {
    section 8 "MOD8_NAME"

    if ! should_run_module 8 || ! ${MODULE_APPLICABLE[8]}; then
        info "$(msg NOT_APPLICABLE)"
        return
    fi

    info "$(msg ENV_SCANNING)"

    # .env / .key / .pem files
    if [[ -n "$ENV_FILES" ]]; then
        warn "$(msg ENV_FOUND)"
        echo "$ENV_FILES" | tee -a "$LOG_FILE"
    else
        info "$(msg ENV_NONE)"
    fi

    # Additional sensitive files that may have been exfiltrated
    local extra_files=(
        "$HOME/.git-credentials"
        "$HOME/.npmrc"
        "$HOME/.zshrc"
    )
    local extra_dirs=(
        "$HOME/.subversion"
    )
    local found_extra=false
    for f in "${extra_files[@]}"; do
        [[ -f "$f" ]] && found_extra=true && break
    done
    if ! $found_extra; then
        for d in "${extra_dirs[@]}"; do
            [[ -d "$d" ]] && found_extra=true && break
        done
    fi

    if $found_extra; then
        echo ""
        info "$(msg ENV_EXTRA_CHECK)"
        for f in "${extra_files[@]}"; do
            if [[ -f "$f" ]]; then
                warn "  $(basename "$f") → $f"
                echo "  $f" >> "$LOG_FILE"
            fi
        done
        for d in "${extra_dirs[@]}"; do
            if [[ -d "$d" ]]; then
                warn "  $(basename "$d")/ → $d"
                echo "  $d/" >> "$LOG_FILE"
            fi
        done
    fi
}
