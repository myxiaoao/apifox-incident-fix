#!/usr/bin/env bash
set -euo pipefail

VERSION="1.0.0"
SCRIPT_NAME="apifox-incident-fix"
RISK_START="2026-03-04"
RISK_END="2026-03-22"
FIX_VERSION="2.8.19"
C2_DOMAIN="apifox.it.com"
ANNOUNCEMENT_URL="https://mp.weixin.qq.com/s/GpACQdnhVNsMn51cm4hZig"
SECURITY_EMAIL="security@apifox.com"

# --- Argument Parsing ---
LANG_FIX=""
SCAN_DIRS=""
EXTRA_PATTERNS=""
DRY_RUN=false
YES_MODE=false
SELECTED_MODULES=""
NO_COLOR=false

require_arg() {
    if [[ $# -lt 2 || -z "$2" ]]; then
        echo "Error: $1 requires a value" >&2
        echo "Run with --help for usage information" >&2
        exit 1
    fi
}

# Like require_arg but also rejects values starting with -- (for enum-like params)
require_enum_arg() {
    require_arg "$@"
    if [[ "$2" == --* ]]; then
        echo "Error: $1 requires a value, got '$2'" >&2
        echo "Run with --help for usage information" >&2
        exit 1
    fi
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --lang)
            require_enum_arg "$1" "${2:-}"; LANG_FIX="$2"; shift 2 ;;
        --scan-dirs)
            require_arg "$1" "${2:-}"; SCAN_DIRS="$2"; shift 2 ;;
        --extra-patterns)
            require_arg "$1" "${2:-}"; EXTRA_PATTERNS="$2"; shift 2 ;;
        --dry-run)
            DRY_RUN=true; shift ;;
        --yes)
            YES_MODE=true; shift ;;
        --modules)
            require_enum_arg "$1" "${2:-}"; SELECTED_MODULES="$2"; shift 2 ;;
        --no-color)
            NO_COLOR=true; shift ;;
        --help|-h)
            SHOW_HELP=true; shift ;;
        *)
            echo "Error: Unknown option: $1" >&2
            echo "Run with --help for usage information" >&2
            exit 1 ;;
    esac
done

LOG_FILE="$HOME/${SCRIPT_NAME}-$(date +%Y%m%d_%H%M%S).log"
