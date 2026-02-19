#!/bin/bash

###############################################################################
# Script Name  : housekeeping_sihome_logs.sh
# Description  : Script housekeeping file log.
# Author       : Crispian | 901146
# Division     : IT Application Services
# Last Update  : 11-02-2026
###############################################################################

# SOURCE_DIR="/export/home/cusadmin/BANCSHOME/SIHOME/LOGS"
# OUTFILE_BANCSSI="/export/home/cusadmin/BANCSHOME/SIHOME/LOGS/BANCSSI/"
# OUTFILE_EAI="/export/home/cusadmin/BANCSHOME/SIHOME/LOGS/EAI/"

SOURCE_DIR="LOGS"
OUTFILE_BANCSSI="LOGS/BANCSSI/"
OUTFILE_EAI="LOGS/EAI/"

# Function: Create directory if not exists
create_dir_if_not_exists() {
    local dir=$1
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        echo "Created directory: $dir"
    fi
}

# Function: Process BaNCSSI logs
process_bancssi_logs() {
    echo "Processing BaNCSSI logs..."
    
    # Find all BaNCSSI.log files
    for logfile in "$SOURCE_DIR"/BaNCSSI.log.*; do
        if [ -f "$logfile" ]; then
            # Extract filename
            filename=$(basename "$logfile")
            
            # Extract year from filename (format: BaNCSSI.log.YYYY-MM-DD)
            # Get part after last dot (YYYY-MM-DD), then get first part before dash (YYYY)
            year=$(echo "$filename" | cut -d'.' -f3 | cut -d'-' -f1)
            
            if [ -n "$year" ] && [ "$year" != "*" ]; then
                # Create yearly directory
                yearly_dir="${OUTFILE_BANCSSI}${year}"
                create_dir_if_not_exists "$yearly_dir"
                
                # Move file to yearly directory
                mv "$logfile" "$yearly_dir/" && echo "Moved: $filename to $yearly_dir/ (File date: $year)"
            else
                echo "Warning: Could not extract year from filename: $filename"
            fi
        fi
    done
}

# Function: Process EAI logs
process_eai_logs() {
    echo "Processing EAI logs..."
    
    # Find all EAI.log files
    for logfile in "$SOURCE_DIR"/EAI.log.*; do
        if [ -f "$logfile" ]; then
            # Extract filename
            filename=$(basename "$logfile")
            
            # Extract year from filename (format: EAI.log.YYYY-MM-DD)
            # Get part after last dot (YYYY-MM-DD), then get first part before dash (YYYY)
            year=$(echo "$filename" | cut -d'.' -f3 | cut -d'-' -f1)
            
            if [ -n "$year" ] && [ "$year" != "*" ]; then
                # Create yearly directory
                yearly_dir="${OUTFILE_EAI}${year}"
                create_dir_if_not_exists "$yearly_dir"
                
                # Move file to yearly directory
                mv "$logfile" "$yearly_dir/" && echo "Moved: $filename to $yearly_dir/ (File date: $year)"
            else
                echo "Warning: Could not extract year from filename: $filename"
            fi
        fi
    done
}

# Function: Compress BaNCSSI yearly directories
compress_bancssi_yearly_dirs() {
    echo ""
    echo "Compressing BaNCSSI yearly directories..."
    
    if [ ! -d "$OUTFILE_BANCSSI" ]; then
        echo "Warning: BANCSSI directory not found"
        return
    fi
    
    # Get current year
    current_year=$(date +%Y)
    
    # Find all year directories in BANCSSI
    for year_dir in "$OUTFILE_BANCSSI"*/; do
        if [ -d "$year_dir" ]; then
            year=$(basename "$year_dir")
            
            # Skip current year
            if [ "$year" = "$current_year" ]; then
                echo "Skipping: $year_dir (current year)"
                continue
            fi
            
            archive_name="${OUTFILE_BANCSSI}BaNCSSI_${year}.tar.gz"
            
            echo "Compressing: $year_dir -> $archive_name"
            tar -cf "${OUTFILE_BANCSSI}BaNCSSI_${year}.tar" -C "$OUTFILE_BANCSSI" "$year/"
            if [ $? -eq 0 ]; then
                gzip "${OUTFILE_BANCSSI}BaNCSSI_${year}.tar"
                # if [ $? -eq 0 ]; then
                #     rm -rf "$year_dir"
                #     echo "Successfully compressed and removed: $year_dir"
                # else
                #     echo "Warning: Failed to gzip tar file for $year_dir"
                # fi
            else
                echo "Warning: Failed to create tar file for $year_dir"
            fi
        fi
    done
}

# Function: Compress EAI yearly directories
compress_eai_yearly_dirs() {
    echo ""
    echo "Compressing EAI yearly directories..."
    
    if [ ! -d "$OUTFILE_EAI" ]; then
        echo "Warning: EAI directory not found"
        return
    fi
    
    # Get current year
    current_year=$(date +%Y)
    
    # Find all year directories in EAI
    for year_dir in "$OUTFILE_EAI"*/; do
        if [ -d "$year_dir" ]; then
            year=$(basename "$year_dir")
            
            # Skip current year
            if [ "$year" = "$current_year" ]; then
                echo "Skipping: $year_dir (current year)"
                continue
            fi
            
            archive_name="${OUTFILE_EAI}EAI_${year}.tar.gz"
            
            echo "Compressing: $year_dir -> $archive_name"
            tar -cf "${OUTFILE_EAI}EAI_${year}.tar" -C "$OUTFILE_EAI" "$year/"
            if [ $? -eq 0 ]; then
                gzip "${OUTFILE_EAI}EAI_${year}.tar"
                # if [ $? -eq 0 ]; then
                #     rm -rf "$year_dir"
                #     echo "Successfully compressed and removed: $year_dir"
                # else
                #     echo "Warning: Failed to gzip tar file for $year_dir"
                # fi
            else
                echo "Warning: Failed to create tar file for $year_dir"
            fi
        fi
    done
}

# Main execution
echo "=========================================="
echo "Script: Housekeeping Log Files"
echo "Start Time: $(date)"
echo "=========================================="

# Create base output directories
create_dir_if_not_exists "$OUTFILE_BANCSSI"
create_dir_if_not_exists "$OUTFILE_EAI"

# Process logs
process_bancssi_logs
process_eai_logs

# Compress yearly directories
compress_bancssi_yearly_dirs
compress_eai_yearly_dirs

echo "=========================================="
echo "End Time: $(date)"
echo "Housekeeping completed successfully!"
echo "=========================================="

