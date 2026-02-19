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
OUTFILE_SILOG="LOGS/SILOG/"

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
            
            # Extract year and month from filename (format: BaNCSSI.log.YYYY-MM-DD)
            # Get part after last dot (YYYY-MM-DD)
            date_part=$(echo "$filename" | cut -d'.' -f3)
            year=$(echo "$date_part" | cut -d'-' -f1)
            month=$(echo "$date_part" | cut -d'-' -f2)
            
            if [ -n "$year" ] && [ -n "$month" ] && [ "$year" != "*" ] && [ "$month" != "*" ]; then
                # Create yearly and monthly directory structure
                monthly_dir="${OUTFILE_BANCSSI}${year}/${month}"
                create_dir_if_not_exists "${OUTFILE_BANCSSI}${year}"
                create_dir_if_not_exists "$monthly_dir"
                
                # Move file to monthly directory
                mv "$logfile" "$monthly_dir/" && echo "Moved: $filename to $monthly_dir/ (File date: $year-$month)"
            else
                echo "Warning: Could not extract year and month from filename: $filename"
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
            
            # Extract year and month from filename (format: EAI.log.YYYY-MM-DD)
            # Get part after last dot (YYYY-MM-DD)
            date_part=$(echo "$filename" | cut -d'.' -f3)
            year=$(echo "$date_part" | cut -d'-' -f1)
            month=$(echo "$date_part" | cut -d'-' -f2)
            
            if [ -n "$year" ] && [ -n "$month" ] && [ "$year" != "*" ] && [ "$month" != "*" ]; then
                # Create yearly and monthly directory structure
                monthly_dir="${OUTFILE_EAI}${year}/${month}"
                create_dir_if_not_exists "${OUTFILE_EAI}${year}"
                create_dir_if_not_exists "$monthly_dir"
                
                # Move file to monthly directory
                mv "$logfile" "$monthly_dir/" && echo "Moved: $filename to $monthly_dir/ (File date: $year-$month)"
            else
                echo "Warning: Could not extract year and month from filename: $filename"
            fi
        fi
    done
}

# Function: Process SILog archive files
process_silog_archives() {
    echo "Processing SILog archive files..."
    
    # Find all SILog_*.tar.gz files
    for logfile in "$SOURCE_DIR"/SILog_*.tar.gz; do
        if [ -f "$logfile" ]; then
            # Extract filename
            filename=$(basename "$logfile")
            
            # Extract date from filename (format: SILog_YYYYMMDD_HHMMSS.tar.gz)
            # Get part before .tar.gz, then remove 'SILog_' prefix
            date_part=$(echo "$filename" | sed 's/\.tar\.gz$//' | sed 's/^SILog_//')
            
            # Take the first 8 characters (YYYYMMDD)
            date_yyyymmdd=$(echo "$date_part" | cut -c1-8)
            
            # Extract year (first 4 characters) and month (characters 5-6)
            year=$(echo "$date_yyyymmdd" | cut -c1-4)
            month=$(echo "$date_yyyymmdd" | cut -c5-6)
            
            if [ -n "$year" ] && [ -n "$month" ] && [ "$year" != "*" ] && [ "$month" != "*" ]; then
                # Create yearly and monthly directory structure
                monthly_dir="${OUTFILE_SILOG}${year}/${month}"
                create_dir_if_not_exists "${OUTFILE_SILOG}${year}"
                create_dir_if_not_exists "$monthly_dir"
                
                # Move file to monthly directory
                mv "$logfile" "$monthly_dir/" && echo "Moved: $filename to $monthly_dir/ (File date: $year-$month)"
            else
                echo "Warning: Could not extract year and month from filename: $filename"
            fi
        fi
    done
}

# Function: Compress SILog yearly directories
compress_silog_yearly_dirs() {
    echo ""
    echo "Compressing SILog yearly directories..."
    
    if [ ! -d "$OUTFILE_SILOG" ]; then
        echo "Warning: SILOG directory not found"
        return
    fi
    
    # Get current year
    current_year=$(date +%Y)
    
    # Find all year directories in SILOG
    for year_dir in "$OUTFILE_SILOG"*/; do
        if [ -d "$year_dir" ]; then
            year=$(basename "$year_dir")
            
            # Skip current year
            if [ "$year" = "$current_year" ]; then
                echo "Skipping: $year_dir (current year)"
                continue
            fi
            
            archive_name="${OUTFILE_SILOG}SILOG_${year}.tar.gz"
            
            echo "Compressing: $year_dir -> $archive_name"
            tar -cf "${OUTFILE_SILOG}SILOG_${year}.tar" -C "$OUTFILE_SILOG" "$year/"
            if [ $? -eq 0 ]; then
                gzip "${OUTFILE_SILOG}SILOG_${year}.tar"
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
create_dir_if_not_exists "$OUTFILE_SILOG"

# Process logs
process_bancssi_logs
process_eai_logs
process_silog_archives

# Compress yearly directories
compress_bancssi_yearly_dirs
compress_eai_yearly_dirs
compress_silog_yearly_dirs

echo "=========================================="
echo "End Time: $(date)"
echo "Housekeeping completed successfully!"
echo "=========================================="

