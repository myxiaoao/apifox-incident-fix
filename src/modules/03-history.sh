#!/usr/bin/env bash

run_module_03() {
    section 3 "MOD3_NAME"

    if ! should_run_module 3 || ! ${MODULE_APPLICABLE[3]}; then
        info "$(msg NOT_APPLICABLE)"
        return
    fi

    info "$(msg HISTORY_CLEANING)"

    local pattern="token|secret|password=|secret=|SECRET=|key=|credential|auth"
    if [[ -n "${EXTRA_PATTERNS:-}" ]]; then
        pattern="${pattern}|${EXTRA_PATTERNS}"
    fi

    if ! pause; then return; fi

    local history_files
    history_files="$(scan_history_files)"
    if [[ -z "$history_files" ]]; then
        info "$(msg HISTORY_NOT_FOUND)"
        return
    fi

    while IFS= read -r hfile; do
        [[ -z "$hfile" ]] && continue
        local fname
        fname="$(basename "$hfile")"
        local backup="${hfile}.backup"

        run_or_dry "backup $fname" cp "$hfile" "$backup"

        if [[ "$DRY_RUN" != true ]]; then
            local before after
            before="$(wc -l < "$hfile" | tr -d ' ')"
            grep -v -iE "$pattern" "$backup" > "$hfile" || true
            after="$(wc -l < "$hfile" | tr -d ' ')"
            log "$fname $(msg HISTORY_CLEANED) (${before} → ${after} $(msg HISTORY_LINES)), $(msg HISTORY_BACKUP) ${backup}"
        else
            info "$(msg DRY_RUN_PREFIX): clean $fname"
        fi
    done <<< "$history_files"

    echo ""
    manual "Rotate any tokens/secrets that appeared in your shell history (ngrok, API keys, etc.)"
}
