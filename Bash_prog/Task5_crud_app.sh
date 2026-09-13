#!/usr/bin/env bash
# ------------------------------------------------------------------
# @title       Task5_crud_app.sh
# @author      Fawaz Rufai Mohammed
# @index       7357623
# @school      Kwame Nkrumah University of Science and Technology (KNUST)
# @description Terminal-based CRUD Phonebook console application with CSV storage, backup triggers, and error validation.
# @date        2026-09-13
# ------------------------------------------------------------------

DATA_FILE="data.txt"
BACKUP_FILE="data.txt.bak"

# Usage function printed to stderr
usage() {
    echo "Usage: $0 [-h|--help]" >&2
    echo "  Launches the interactive Phonebook CRUD console application." >&2
    echo "  -h, --help    Display this help message and exit" >&2
    exit 1
}

# Check for help flags
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    usage
fi

# Ensure data storage file exists
touch "$DATA_FILE"

# Helper function to create file backups prior to destructive changes
backup_data() {
    if [ -f "$DATA_FILE" ]; then
        cp "$DATA_FILE" "$BACKUP_FILE" 2>/dev/null
        if [ "$?" -ne 0 ]; then
            echo "Error: Failed to create backup file '$BACKUP_FILE'." >&2
            return 1
        fi
    fi
    return 0
}

# Helper function to auto-generate incremental IDs
get_next_id() {
    if [ ! -s "$DATA_FILE" ]; then
        echo "1"
    else
        awk -F',' '{print $1}' "$DATA_FILE" | sort -n | tail -n 1 | awk '{print $1 + 1}'
    fi
}

# 1. CREATE Operation
add_record() {
    echo ""
    echo "--- Add New Contact ---"
    
    read -p "Enter Name: " name
    if [ -z "$name" ]; then
        echo "Error: Name cannot be empty." >&2
        return 1
    fi

    read -p "Enter Phone Number: " phone
    if [ -z "$phone" ]; then
        echo "Error: Phone number cannot be empty." >&2
        return 1
    fi

    read -p "Enter Email: " email
    if [ -z "$email" ]; then
        echo "Error: Email cannot be empty." >&2
        return 1
    fi

    id=$(get_next_id)
    echo "${id},${name},${phone},${email}" >> "$DATA_FILE"
    
    if [ "$?" -eq 0 ]; then
        echo "[SUCCESS] Contact added with ID: ${id}"
    else
        echo "Error: Failed to append record to '$DATA_FILE'." >&2
    fi
}

# 2. READ / LIST Operation
list_records() {
    echo ""
    echo "--- Phonebook Directory ---"
    if [ ! -s "$DATA_FILE" ]; then
        echo "[NOTICE] No records found in phonebook."
        return 0
    fi

    printf "%-5s | %-20s | %-15s | %-25s\n" "ID" "Name" "Phone" "Email"
    echo "------------------------------------------------------------------"
    while IFS=',' read -r id name phone email; do
        printf "%-5s | %-20s | %-15s | %-25s\n" "$id" "$name" "$phone" "$email"
    done < "$DATA_FILE"
}

# 3. SEARCH Operation
search_records() {
    echo ""
    echo "--- Search Contacts ---"
    read -p "Enter search keyword (Name, Phone, or Email): " keyword
    if [ -z "$keyword" ]; then
        echo "Error: Search term cannot be empty." >&2
        return 1
    fi

    echo ""
    matches=$(grep -i "$keyword" "$DATA_FILE")
    if [ -z "$matches" ]; then
        echo "[NOTICE] No records matching '$keyword' were found."
    else
        printf "%-5s | %-20s | %-15s | %-25s\n" "ID" "Name" "Phone" "Email"
        echo "------------------------------------------------------------------"
        echo "$matches" | while IFS=',' read -r id name phone email; do
            printf "%-5s | %-20s | %-15s | %-25s\n" "$id" "$name" "$phone" "$email"
        done
    fi
}

# 4. UPDATE Operation
update_record() {
    echo ""
    echo "--- Update Contact ---"
    read -p "Enter ID of the record to update: " target_id
    if [ -z "$target_id" ]; then
        echo "Error: ID cannot be empty." >&2
        return 1
    fi

    existing_record=$(grep "^${target_id}," "$DATA_FILE")
    if [ -z "$existing_record" ]; then
        echo "[NOTICE] Record with ID '${target_id}' not found."
        return 0
    fi

    echo "Found record: $existing_record"
    read -p "Enter New Name: " new_name
    read -p "Enter New Phone: " new_phone
    read -p "Enter New Email: " new_email

    if [ -z "$new_name" ] || [ -z "$new_phone" ] || [ -z "$new_email" ]; then
        echo "Error: All fields are required for update." >&2
        return 1
    fi

    # Perform required file backup prior to modification
    backup_data || return 1

    # Atomic write replacement
    grep -v "^${target_id}," "$DATA_FILE" > "${DATA_FILE}.tmp"
    echo "${target_id},${new_name},${new_phone},${new_email}" >> "${DATA_FILE}.tmp"
    sort -n -t',' -k1 "${DATA_FILE}.tmp" > "$DATA_FILE"
    rm -f "${DATA_FILE}.tmp"

    echo "[SUCCESS] Record ID '${target_id}' updated successfully."
}

# 5. DELETE Operation
delete_record() {
    echo ""
    echo "--- Delete Contact ---"
    read -p "Enter ID of the record to delete: " target_id
    if [ -z "$target_id" ]; then
        echo "Error: ID cannot be empty." >&2
        return 1
    fi

    existing_record=$(grep "^${target_id}," "$DATA_FILE")
    if [ -z "$existing_record" ]; then
        echo "[NOTICE] Record with ID '${target_id}' not found."
        return 0
    fi

    echo "Target Record: $existing_record"
    read -p "Are you sure you want to delete this record? (y/n): " confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo "[SKIPPED] Deletion cancelled by user."
        return 0
    fi

    # Perform required file backup prior to deletion
    backup_data || return 1

    grep -v "^${target_id}," "$DATA_FILE" > "${DATA_FILE}.tmp"
    mv "${DATA_FILE}.tmp" "$DATA_FILE"

    echo "[SUCCESS] Record ID '${target_id}' deleted successfully."
}

# Main Application Menu Loop
while true; do
    echo ""
    echo "======================================"
    echo "    PHONEBOOK CRUD APPLICATION MENU   "
    echo "======================================"
    echo "1. Add Contact"
    echo "2. View All Contacts"
    echo "3. Search Contact"
    echo "4. Update Contact"
    echo "5. Delete Contact"
    echo "6. Exit"
    read -p "Select an option [1-6]: " choice

    case "$choice" in
        1) add_record ;;
        2) list_records ;;
        3) search_records ;;
        4) update_record ;;
        5) delete_record ;;
        6)
            echo "Exiting application. Goodbye!"
            exit 0
            ;;
        *)
            echo "Error: Invalid choice. Please select an option between 1 and 6." >&2
            ;;
    esac
done
