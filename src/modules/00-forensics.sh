#!/usr/bin/env bash

run_module_00() {
    section 0 "MOD0_NAME"

    if ! should_run_module 0; then
        info "$(msg NOT_APPLICABLE)"
        return
    fi

    # --- LevelDB Check ---
    info "$(msg FORENSICS_CHECKING)"
    if [[ -n "$LEVELDB_MATCHES" ]]; then
        error "$(msg FORENSICS_FOUND)"
        echo "$LEVELDB_MATCHES" | tee -a "$LOG_FILE"
    elif [[ -n "$(get_apifox_data_dir)" ]]; then
        info "$(msg FORENSICS_CLEAN)"
    else
        warn "$(msg FORENSICS_NO_DIR)"
    fi

    # --- Version Check ---
    local apifox_ver
    apifox_ver="$(get_apifox_version)"
    if [[ -n "$apifox_ver" ]]; then
        if [[ "$(printf '%s\n' "$FIX_VERSION" "$apifox_ver" | sort -V | head -1)" != "$FIX_VERSION" ]]; then
            warn "$(msg FORENSICS_VERSION_WARN)"
        fi
    fi

    # --- Hosts Block ---
    if is_c2_blocked; then
        log "$(msg FORENSICS_HOSTS_EXISTS)"
    else
        if [[ "$DRY_RUN" == true ]]; then
            info "$(msg DRY_RUN_PREFIX): add 127.0.0.1 ${C2_DOMAIN} to /etc/hosts"
        else
            if [[ "$YES_MODE" == true ]]; then
                local answer="Y"
            else
                read -r -p "$(msg FORENSICS_HOSTS_PROMPT) " answer || true
            fi
            case "${answer:-Y}" in
                n|N) warn "$(msg SKIPPED)" ;;
                *)
                    echo "127.0.0.1 ${C2_DOMAIN}" | sudo tee -a /etc/hosts > /dev/null
                    log "$(msg FORENSICS_HOSTS_ADDED)"
                    ;;
            esac
        fi
    fi
}
