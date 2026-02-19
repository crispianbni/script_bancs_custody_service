#!/bin/bash

###############################################################################
# Script Name  : housekeeping_sihome_bis4o2.sh
# Description  : Script housekeeping file archive for BIS4 files.
# Author       : Crispian | 901146
# Division     : IT Application Services
# Last Update  : 12-02-2026
###############################################################################

SOURCE_DIR="/export/home/cusadmin/BANCSHOME/SIHOME/datafiles/BIS4O2/archive/"
OUTFILE_BIS4="/export/home/cusadmin/BANCSHOME/SIHOME/datafiles/BIS4O2/archive/bis4/"

# SOURCE_DIR="file"
# OUTFILE_BIS4="file/bis4/"

# Function: Create directory if not exists
create_dir_if_not_exists() {
    local dir=$1
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        echo "Created directory: $dir"
    fi
}

# Function: Convert 2-digit year to 4-digit year
convert_year_to_4digit() {
    local yy=$1
    if [ "$yy" -le 50 ]; then
        echo "20$yy"
    else
        echo "19$yy"
    fi
}

# Function: Process BIS4 files
process_bis4_files() {
    echo "Processing BIS4 files..."
    
    # Find all BIS4*.txt files
    for logfile in "$SOURCE_DIR"/BIS4*.txt; do
        if [ -f "$logfile" ]; then
            # Extract filename
            filename=$(basename "$logfile")
            
            dd=$(echo "$filename" | cut -c5-6)
            mm=$(echo "$filename" | cut -c7-8)
            yy=$(echo "$filename" | cut -c9-10)
            
            # Convert 2-digit year to 4-digit year
            yyyy=$(convert_year_to_4digit "$yy")
            
            if [ -n "$yyyy" ] && [ -n "$mm" ] && [ "$yyyy" != "*" ] && [ "$mm" != "*" ]; then
                # Create yearly and monthly directory structure
                monthly_dir="${OUTFILE_BIS4}${yyyy}/${mm}"
                create_dir_if_not_exists "${OUTFILE_BIS4}${yyyy}"
                create_dir_if_not_exists "$monthly_dir"
                
                # Move file to monthly directory
                mv "$logfile" "$monthly_dir/" && echo "Moved: $filename to $monthly_dir/ (File date: ${dd}-${mm}-${yyyy})"
            else
                echo "Warning: Could not extract date from filename: $filename"
            fi
        fi
    done
}

# Function: Compress BIS4 yearly directories
compress_bis4_yearly_dirs() {
    echo ""
    echo "Compressing BIS4 yearly directories..."
    
    if [ ! -d "$OUTFILE_BIS4" ]; then
        echo "Warning: BIS4 directory not found"
        return
    fi
    
    # Get current year
    current_year=$(date +%Y)
    
    # Find all year directories in BIS4
    for year_dir in "$OUTFILE_BIS4"*/; do
        if [ -d "$year_dir" ]; then
            year=$(basename "$year_dir")
            
            # Skip current year
            if [ "$year" = "$current_year" ]; then
                echo "Skipping: $year_dir (current year)"
                continue
            fi
            
            archive_name="${OUTFILE_BIS4}BIS4_${year}.tar.gz"
            
            echo "Compressing: $year_dir -> $archive_name"
            tar -cf "${OUTFILE_BIS4}BIS4_${year}.tar" -C "$OUTFILE_BIS4" "$year/"
            if [ $? -eq 0 ]; then
                gzip "${OUTFILE_BIS4}BIS4_${year}.tar"
                echo "Successfully compressed: $archive_name"
                # Uncomment the line below to delete the original directory after compression
                rm -rf "$year_dir"
            else
                echo "Warning: Failed to create tar file for $year_dir"
            fi
        fi
    done
}

# Main execution
echo "=========================================="
echo "Script: Housekeeping BIS4 Files"
echo "Start Time: $(date)"
echo "=========================================="

# Create base output directory
create_dir_if_not_exists "$OUTFILE_BIS4"

# Process BIS4 files
process_bis4_files

# Compress yearly directories
compress_bis4_yearly_dirs

echo "=========================================="
echo "End Time: $(date)"
echo "Housekeeping completed successfully!"
echo "=========================================="