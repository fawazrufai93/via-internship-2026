#!/usr/bin/env bash
# ------------------------------------------------------------------
# @title       Task2_permissions_sudo.sh
# @author      Fawaz Rufai Mohammed
# @index       7357623
# @school      Kwame Nkrumah University of Science and Technology (KNUST)
# @description Inspects file permissions, modifies them using numeric and symbolic syntax, and safely handles root/sudo ownership changes.
# @date        2026-09-12
# ------------------------------------------------------------------

# Usage guide printed to stderr on missing or help arguments
usage() {
    echo "Usage: $0 <file-path>" >&2
    echo "  <file-path>    Path to the target file to inspect and modify permissions" >&2
    echo "  -h, --help     Display this help message and exit" >&2
    exit 1
}

# Validate input arguments and print usage guide on help flags
if [ "$#" -ne 1 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    usage
fi

TARGET_FILE="$1"

# Validate input (check if file exists) before operating on it
if [ ! -e "$TARGET_FILE" ]; then
    echo "Error: Target file '$TARGET_FILE' does not exist." >&2
    exit 1
fi

# Function to safely display file permissions
report_permissions() {
    echo "--- File Permissions Report ---"
    # Using stat to extract human-readable symbolic (%A) and numeric (%a) access rights
    if ! stat -c "Symbolic: %A | Numeric: %a" "$TARGET_FILE" 2>/dev/null; then
        echo "Error: Failed to read permissions for '$TARGET_FILE'." >&2
        return 1
    fi
    echo "-------------------------------"
}

# Task Requirement 1: Report initial permissions
echo "[STEP 1] Initial Permissions:"
report_permissions

# Task Requirement 2: Apply numeric modification (chmod 644)
echo "[STEP 2] Modifying permissions..."
chmod 644 "$TARGET_FILE"
# Rule 3: Check exit code ($?) of critical chmod command
if [ "$?" -ne 0 ]; then
    echo "Error: Failed to apply numeric permissions (chmod 644) to '$TARGET_FILE'." >&2
    exit 1
fi
echo "-> Successfully applied numeric mode: chmod 644"

# Task Requirement 2: Apply symbolic modification (chmod u+x)
chmod u+x "$TARGET_FILE"
# Rule 3: Check exit code ($?) of second chmod command
if [ "$?" -ne 0 ]; then
    echo "Error: Failed to apply symbolic permissions (chmod u+x) to '$TARGET_FILE'." >&2
    exit 1
fi
echo "-> Successfully applied symbolic mode: chmod u+x"

# Task Requirement 3: Conditional root privilege check & graceful ownership change
echo "[STEP 3] Checking root/sudo privileges for chown..."
# Checking EUID to see if running under root/sudo without causing script execution failure
if [ "$(id -u)" -eq 0 ]; then
    echo "-> Running with root privileges. Executing chown..."
    # Fallback to SUDO_USER if logname fails in subshell environments
    CURRENT_USER=$(logname 2>/dev/null || echo "$SUDO_USER")
    
    chown "$CURRENT_USER" "$TARGET_FILE" 2>/dev/null
    if [ "$?" -eq 0 ]; then
        echo "[SUCCESS] Updated file ownership to: $CURRENT_USER"
    else
        echo "Error: Failed to change file ownership." >&2
    fi
else
    # Graceful fallback per instructions (skips instead of failing non-root execution)
    echo "[SKIPPED] chown step skipped gracefully (root/sudo privileges required)."
fi

# Task Requirement 4: Report updated permissions
echo "[STEP 4] Updated Permissions:"
report_permissions

# Rule 3: Exit with 0 on successful completion
exit 0
