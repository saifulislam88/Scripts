#!/bin/bash

# -------------------------------------------
# | Script Created By: mSi                  |
# | Script Created at: 10-10-2024 23:05 PM  |
# -------------------------------------------

# Source directories
DIR_1="/minio-data/minio/pslupms/tallypay_media"
DIR_2="/minio-data/minio/pslupms/static-doc"
DATE=$(date +%Y%m%d-%H)
OUTPUT_FILE="/home/saiful/TP-media_directory-count_report_${DATE}.txt"

# Function to count files and subdirectories
process_directory() {
    local dir_path=$1
    local dir_name=$(basename "$dir_path")

    if [ ! -d "$dir_path" ]; then
        echo "Error: $dir_path does not exist or is not a directory." >> "$OUTPUT_FILE"
        return
    fi

    echo "Processing: $dir_name" >> "$OUTPUT_FILE"
    echo "--------------------------------" >> "$OUTPUT_FILE"

    # Count files directly in the root directory
    local root_file_count=$(find "$dir_path" -maxdepth 1 -type f | wc -l)
    echo "Files in $dir_name (Root): $root_file_count" >> "$OUTPUT_FILE"

    # Count subdirectories
    local subdir_count=$(find "$dir_path" -mindepth 1 -type d | wc -l)
    echo "Total Subdirectories: $subdir_count" >> "$OUTPUT_FILE"

    # Process each subdirectory and count files
    find "$dir_path" -type d | while read -r subdir; do
        local subdir_name=$(realpath --relative-to="$dir_path" "$subdir")
        local file_count=$(find "$subdir" -type f | wc -l)
        printf "  - %-30s : %d files\n" "$subdir_name" "$file_count" >> "$OUTPUT_FILE"
    done

    echo "" >> "$OUTPUT_FILE"
}

# Check if directories contain any files or subdirectories
check_directory_content() {
    local dir_path=$1
    if [ -z "$(find "$dir_path" -mindepth 1 2>/dev/null)" ]; then
        echo "No content found in $dir_path. Exiting." >> "$OUTPUT_FILE"
        return 1
    fi
    return 0
}

# Create or overwrite the output file
echo "Directory Report" > "$OUTPUT_FILE"
echo "================" >> "$OUTPUT_FILE"
echo "Start Time: $(date)" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

start_time=$(date +%s)

# Process directories if they contain content
if check_directory_content "$DIR_1" && check_directory_content "$DIR_2"; then
    process_directory "$DIR_1"
    process_directory "$DIR_2"
else
    echo "No content to process. Script terminated." >> "$OUTPUT_FILE"
    echo "Script terminated early." >&2
    exit 1
fi

end_time=$(date +%s)
elapsed_time=$((end_time - start_time))

# Log the time taken
echo "Script Execution Time: ${elapsed_time} seconds" >> "$OUTPUT_FILE"
echo "Report saved to $OUTPUT_FILE"

# Output summary to console
echo "Script completed. Execution time: ${elapsed_time} seconds. Report saved to $OUTPUT_FILE."
