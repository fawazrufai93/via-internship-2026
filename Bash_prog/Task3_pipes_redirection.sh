#!/usr/bin/env bash
# ------------------------------------------------------------------
# @title       Task3_pipes_redirection.sh
# @author      Fawaz Rufai Mohammed
# @index       7357623
# @school      Kwame Nkrumah University of Science and Technology (KNUST)
# @description Programmatically generates 50 randomized log entries and processes them using text pipelines.
# @date        2026-09-12
# ------------------------------------------------------------------

usage() {
    echo "Usage: $0 [-h|--help]" >&2
    echo "  Generates 50 random log entries and prints metrics to results.txt." >&2
    echo "  -h, --help    Display this help message and exit" >&2
    exit 1
}

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    usage
fi

LOG_FILE="sample_app.log"
RESULTS_FILE="results.txt"
ERRORS_FILE="errors.log"

# Reset logs
> "$LOG_FILE"
> "$ERRORS_FILE"

echo "[INFO] Dynamically generating 50 random log entries..."

# Sample arrays for random generation
LEVELS=("INFO" "WARN" "ERROR")
IPS=("192.168.1.10" "192.168.1.23" "192.168.1.50" "192.168.1.15" "192.168.1.88")
MESSAGES=(
    "User login successful" 
    "Connection timeout" 
    "Disk usage above 80%" 
    "File uploaded successfully" 
    "Database connection failed" 
    "High memory usage detected"
)

# Loop 50 times to append random lines to sample_app.log
for i in $(seq 1 50); do
    RAND_LEVEL=${LEVELS[$RANDOM % ${#LEVELS[@]}]}
    RAND_IP=${IPS[$RANDOM % ${#IPS[@]}]}
    RAND_MSG=${MESSAGES[$RANDOM % ${#MESSAGES[@]}]}
    TIMESTAMP="2026-09-12 10:$(printf "%02d" $((i / 2))):$(printf "%02d" $((RANDOM % 60)))"
    
    echo "$TIMESTAMP $RAND_LEVEL $RAND_IP $RAND_MSG" >> "$LOG_FILE" 2>> "$ERRORS_FILE"
done

# Verify log generation succeeded
if [ ! -s "$LOG_FILE" ]; then
    echo "Error: Failed to create dynamic log data." >&2
    exit 1
fi

# Pipeline text analysis redirected to results.txt
{
    echo "=========================================="
    echo "       LOG ANALYSIS SUMMARY REPORT        "
    echo "=========================================="
    echo ""

    echo "1. TOTAL LOG LINES"
    echo "------------------"
    wc -l < "$LOG_FILE" | tr -d ' '
    echo ""

    echo "2. COUNT PER LOG LEVEL"
    echo "----------------------"
    awk '{print $3}' "$LOG_FILE" | sort | uniq -c | awk '{print $2 ": " $1}'
    echo ""

    echo "3. TOP 3 MOST FREQUENT IP ADDRESSES"
    echo "-----------------------------------"
    awk '{print $4}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -n 3 | awk '{print $2 " (" $1 " occurrences)"}'
    echo ""

    echo "4. ALL ERROR LINES ONLY"
    echo "-----------------------"
    grep "ERROR" "$LOG_FILE"
    echo ""
} > "$RESULTS_FILE" 2>> "$ERRORS_FILE"

if [ "$?" -eq 0 ]; then
    echo "[SUCCESS] Generated 50 random logs and saved summary to '$RESULTS_FILE'."
    exit 0
else
    echo "Error: Log analysis failed. Check '$ERRORS_FILE'." >&2
    exit 1
fi
