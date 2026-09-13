#!/usr/bin/env bash
# ------------------------------------------------------------------
# @title       Task4_return_codes_error_handling.sh
# @author      Fawaz Rufai Mohammed
# @index       7357623
# @school      Kwame Nkrumah University of Science and Technology (KNUST)
# @description Runs system checks and enforces exit codes using custom status handlers and cleanup traps.
# @date        2026-09-12
# ------------------------------------------------------------------

# Exit code scheme:
# 0 = All checks passed
# 1 = Missing required argument or help flag requested
# 2 = Host unreachable
# 3 = Insufficient disk space
# 4 = Required config file missing/unreadable
# 5 = Required tool/command not found

# Temporary file used for check state tracking
TEMP_FILE=$(mktemp /tmp/task4_check_XXXXXX.tmp)

# Cleanup trap function (runs on normal exit, error exit, or Ctrl+C / SIGINT / SIGTERM)
cleanup() {
    if [ -f "$TEMP_FILE" ]; then
        rm -f "$TEMP_FILE"
    fi
}
trap cleanup EXIT SIGINT SIGTERM

# Usage guide printed to stderr
usage() {
    echo "Usage: $0 <hostname>" >&2
    echo "  <hostname>    Host IP or domain name to test reachability (e.g., 8.8.8.8)" >&2
    echo "  -h, --help    Display this help message and exit" >&2
    exit 1
}

# Input validation
if [ "$#" -ne 1 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    usage
fi

HOST="$1"

# Helper function to evaluate $?, log pass/fail, and exit with documented code on failure
check_status() {
    local status_code="$1"
    local check_name="$2"
    local exit_code="$3"

    if [ "$status_code" -eq 0 ]; then
        echo "[PASS] $check_name"
    else
        echo "[FAIL] $check_name (Error Code: $exit_code)" >&2
        exit "$exit_code"
    fi
}

echo "=== System Health & Environment Verification ==="

# Check 1: Is host reachable?
ping -c 1 -W 2 "$HOST" > /dev/null 2>&1
check_status "$?" "Host Reachability Check ($HOST)" 2

# Check 2: Is there enough free disk space (> 10% available)?
AVAILABLE_PCT=$(df / | awk 'NR==2 {print 100 - $5}')
[ "$AVAILABLE_PCT" -gt 10 ]
check_status "$?" "Disk Space Availability Check (>10% free)" 3

# Check 3: Is a required tool installed (e.g., curl)?
command -v curl > /dev/null 2>&1
check_status "$?" "Required Command Check ('curl')" 5

# Check 4: Does a required config file exist and is readable?
CONFIG_FILE="/etc/resolv.conf"
[ -f "$CONFIG_FILE" ] && [ -r "$CONFIG_FILE" ]
check_status "$?" "Configuration File Readability Check ($CONFIG_FILE)" 4

echo "==============================================="
echo "All system checks completed successfully!"
exit 0
