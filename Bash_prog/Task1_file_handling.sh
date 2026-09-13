# !/usr/bin/env bash
# --------------------------------------------------------------------------------------------------
# @title                 Task1_file_handling.sh
# @author                Fawaz Rufai Mohammed
# @index                 7357623
# @school                Kwame Nkrumah University of Science and Technology (KNUST)
# @description           Handles directory creation, writing/appending files, displaying contents,
#                        creating backups, and safe deletion.
# @date                  12/09/2026
# --------------------------------------------------------------------------------------------------

set -euo pipefail

usage() {
  echo "Usage: $0 <target-directory>"
  echo " <target-directory>  Path to the directory you want to create or manage"
  exit 1
}

# Check if argument is missing or help flag is passed 
if [ $# -ne 1 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  usage
fi

TARGET_DIR="$1"
TARGET_FILE="${TARGET_DIR}/data.txt"
BACKUP_FILE="${TARGET_DIR}/data.txt.bak"

# Create directory
if [ -d "$TARGET_DIR" ]; then
  echo "[INFO] Directory '$TARGET_DIR' already exists."
else
  if mkdir -p "$TARGET_DIR"; then
    echo "[SUCCESS] Created directory '$TARGET_DIR'."
  else
    echo "Error: Failed to create directory '$TARGET_DIR'." >&2
    exit 1
  fi
fi

# Write initial content
if echo "Initial entry - $(date)" > "$TARGET_FILE"; then
  echo "[SUCCESS] Created and wrote initial content to '$TARGET_FILE'."
else
  echo "Error: Failed to write to '$TARGET_FILE'." >&2
  exit 1
fi

# Append additional content
if echo "Appended entry - $(date)" >> "$TARGET_FILE"; then
  echo "[SUCCESS] Appended content to '$TARGET_FILE'."
else
  echo "Error: Failed to append content to '$TARGET_FILE'." >&2
  exit 1
fi

# Display contents
echo "--- File Contents ---"
cat "$TARGET_FILE"
echo "---------------------"

# Copy file to .bak
if cp "$TARGET_FILE" "$BACKUP_FILE"; then
  echo "[SUCCESS] Created backup copy at '$BACKUP_FILE'."
else
  echo "Error: Failed to create backup file." >&2
  exit 1
fi

# Safely delete original after verifying existence
if [ -f "$TARGET_FILE" ]; then
  echo "[CONFIRMATION] Original file exists. Deleting '$TARGET_FILE' now..."
  if rm "$TARGET_FILE"; then
    echo "[SUCCESS] Deleted original file '$TARGET_FILE'."
  else
    echo "Error: Failed to delete '$TARGET_FILE'." >&2
    exit 1
  fi
else
  echo "Error: Target file '$TARGET_FILE' does not exist." >&2
  exit 1
fi

exit 0
