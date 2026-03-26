#!/usr/bin/env bash

run_module_02() {
    section 2 "MOD2_NAME"

    if ! should_run_module 2 || ! ${MODULE_APPLICABLE[2]}; then
        info "$(msg SSH_NONE)"
        return
    fi

    info "$(msg SSH_SCANNING)"

    # List keys with numbers
    local keys=()
    local i=1
    while IFS= read -r key; do
        [[ -z "$key" ]] && continue
        keys+=("$key")
        local hosts
        hosts="$(get_hosts_for_key "$key")"
        local host_info=""
        [[ -n "$hosts" ]] && host_info=" → $hosts"
        printf "  [%d] %s%s\n" "$i" "$(basename "$key")" "$host_info"
        ((i++))
    done <<< "$SSH_KEYS"

    if [[ ${#keys[@]} -eq 0 ]]; then
        log "$(msg SSH_NONE)"
        return
    fi

    echo ""
    if [[ "$YES_MODE" == true ]]; then
        local selection="all"
    else
        read -r -p "$(msg SSH_SELECT) " selection || true
    fi

    local selected_keys=()
    if [[ "$selection" == "all" ]]; then
        selected_keys=("${keys[@]}")
    else
        IFS=',' read -ra nums <<< "$selection"
        for n in "${nums[@]}"; do
            n="$(echo "$n" | tr -d ' ')"
            if [[ "$n" =~ ^[0-9]+$ ]] && [[ "$n" -ge 1 ]] && [[ "$n" -le ${#keys[@]} ]]; then
                selected_keys+=("${keys[$((n-1))]}")
            fi
        done
    fi

    if [[ ${#selected_keys[@]} -eq 0 ]]; then
        warn "$(msg SKIPPED)"
        return
    fi

    # Get email for new keys
    local email
    email="$(git config user.email 2>/dev/null || true)"
    if [[ -z "$email" ]]; then
        read -r -p "Email for new SSH keys: " email || true
    fi

    local backup_dir="$HOME/.ssh/compromised_backup_$(date +%Y%m%d_%H%M%S)"
    run_or_dry "create backup dir $backup_dir" mkdir -p "$backup_dir"

    for key in "${selected_keys[@]}"; do
        local keyname
        keyname="$(basename "$key")"

        # Backup
        run_or_dry "backup $keyname" mv "$key" "$backup_dir/"
        if [[ "$DRY_RUN" != true ]]; then
            log "$(msg SSH_BACKUP): $keyname"
        fi
        if [[ -f "${key}.pub" ]]; then
            run_or_dry "backup ${keyname}.pub" mv "${key}.pub" "$backup_dir/"
        fi

        # Generate new ed25519 key at same path
        if [[ "$DRY_RUN" != true ]]; then
            ssh-keygen -t ed25519 -C "$email" -f "$key"
            log "$(msg SSH_GENERATED): $keyname"

            # Show public key
            echo ""
            info "$(msg SSH_PUBKEY)"
            echo "--- $keyname ---"
            cat "${key}.pub"

            # Show host hint
            local hosts
            hosts="$(get_hosts_for_key "$key")"
            if [[ -n "$hosts" ]]; then
                info "$(msg SSH_PLATFORM_HINT) $hosts"
            fi
        else
            info "$(msg DRY_RUN_PREFIX): generate ed25519 key at $key"
        fi
    done

    echo ""
    manual "Update public keys on GitHub / GitLab / other platforms for the rotated keys above"
}
