#!/bin/bash

###############################################################################
# Script Name  : original_active.sh
# Description  : Melakukan simulasi original active dengan cara rename file konfigurasi.
#                - Original Active: Backup file aktif ke *_Mock, restore file *_Original ke aktif.
#                - Logging proses dan status setiap langkah.
# Author       : 901146
# Last Update  : 17-04-2026
###############################################################################

# Menentukan direktori dasar untuk semua operasi file.
# ========================
BASE_DIR="/export/home/cusadmin/BANCSHOME"

# Menampilkan pesan log dengan timestamp.
# ========================
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Melakukan rename file jika file sumber ada dan file tujuan belum ada.
# ========================
rename_with_check() {
  local src="$1"
  local dst="$2"

  if [ ! -f "$src" ]; then
    log "File not found: $src"
    return 1
  fi

  if [ -f "$dst" ]; then
    log "File already exists: $dst"
    return 0
  fi

  mv "$src" "$dst"
  log "Renamed: $src -> $dst"
  return 0
}

# Rename file aktif ke *_Mock, and file *_SO2025 ke aktif.
# ========================
do_original_active() {
  log "Starting Original Active..."

  # STEP 1: Rename file aktif ke *_Mock
  # ========================
  log "STEP 1: Renaming active config to *_Mock"
  rename_with_check "$BASE_DIR/ncshome/properties/InputFiles/MCSysProp.properties" \
                    "$BASE_DIR/ncshome/properties/InputFiles/MCSysProp.properties_Mock" || return 1

  rename_with_check "$BASE_DIR/ncshome/properties/ConfigFiles/BatchArch.properties" \
                    "$BASE_DIR/ncshome/properties/ConfigFiles/BatchArch.properties_Mock" || return 1

  rename_with_check "$BASE_DIR/SIHOME/MESSAGE/config/BIS4I.xml" \
                    "$BASE_DIR/SIHOME/MESSAGE/config/BIS4I.xml_Mock" || return 1

  rename_with_check "$BASE_DIR/SIHOME/MESSAGE/config/BIS4O2.xml" \
                    "$BASE_DIR/SIHOME/MESSAGE/config/BIS4O2.xml_Mock" || return 1

  rename_with_check "$BASE_DIR/SIHOME/MESSAGE/config/CBESTO2.xml" \
                    "$BASE_DIR/SIHOME/MESSAGE/config/CBESTO2.xml_Mock" || return 1
  log "Waiting for 10 seconds..."
  
  sleep 10
  log "STEP 1 completed."

  # STEP 2: Rename file *_Original ke aktif.
  # ========================
  log "STEP 2: Renaming *_Original to active"
  rename_with_check "$BASE_DIR/ncshome/properties/InputFiles/MCSysProp.properties_Original" \
                    "$BASE_DIR/ncshome/properties/InputFiles/MCSysProp.properties" || return 1

  rename_with_check "$BASE_DIR/ncshome/properties/ConfigFiles/BatchArch.properties_Original" \
                    "$BASE_DIR/ncshome/properties/ConfigFiles/BatchArch.properties" || return 1

  rename_with_check "$BASE_DIR/SIHOME/MESSAGE/config/BIS4I.xml_Original" \
                    "$BASE_DIR/SIHOME/MESSAGE/config/BIS4I.xml" || return 1

  rename_with_check "$BASE_DIR/SIHOME/MESSAGE/config/BIS4O2.xml_Original" \
                    "$BASE_DIR/SIHOME/MESSAGE/config/BIS4O2.xml" || return 1

  rename_with_check "$BASE_DIR/SIHOME/MESSAGE/config/CBESTO2.xml_Original" \
                    "$BASE_DIR/SIHOME/MESSAGE/config/CBESTO2.xml" || return 1
  log "Waiting for 10 seconds..."
  sleep 10
  log "STEP 2 completed."
  log "Original Active successfully."
}

# Jalankan fungsi SB
do_original_active