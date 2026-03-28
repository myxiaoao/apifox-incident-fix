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
        if [[ -n "$LEVELDB_SUSPICIOUS" ]]; then
            echo "$LEVELDB_SUSPICIOUS" | tee -a "$LOG_FILE"
        fi
    elif [[ -n "$LEVELDB_SUSPICIOUS" ]]; then
        warn "$(msg FORENSICS_SUSPICIOUS)"
        echo "$LEVELDB_SUSPICIOUS" | tee -a "$LOG_FILE"
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

    # --- Hosts Block (all malicious domains) ---
    local unblocked_domains
    unblocked_domains="$(get_unblocked_c2_domains)"
    if [[ -z "$unblocked_domains" ]]; then
        log "$(msg FORENSICS_HOSTS_EXISTS)"
    else
        local unblocked_count
        unblocked_count="$(echo "$unblocked_domains" | wc -l | tr -d ' ')"
        if [[ "$DRY_RUN" == true ]]; then
            info "$(msg DRY_RUN_PREFIX): add ${unblocked_count} malicious domains to /etc/hosts"
            echo "$unblocked_domains" | while IFS= read -r d; do
                info "  127.0.0.1 $d"
            done
        else
            if [[ "$YES_MODE" == true ]]; then
                local answer="Y"
            else
                info "$(msg FORENSICS_HOSTS_PARTIAL)"
                echo "$unblocked_domains" | while IFS= read -r d; do
                    echo "  $d"
                done
                read -r -p "$(msg FORENSICS_HOSTS_PROMPT) " answer || true
            fi
            case "${answer:-Y}" in
                n|N) warn "$(msg SKIPPED)" ;;
                *)
                    echo "$unblocked_domains" | while IFS= read -r d; do
                        [[ -z "$d" ]] && continue
                        echo "127.0.0.1 $d" | sudo tee -a /etc/hosts > /dev/null
                    done
                    log "$(msg FORENSICS_HOSTS_ADDED)"
                    ;;
            esac
        fi
    fi
}
