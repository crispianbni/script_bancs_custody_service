#!/bin/bash
###############################################################################
# Script Name  : sftp_count_table_dc.sh
# Description  : sftp file count 10.13.2.252 -> 192.168.140.30.
# Server       : DB DC
# Author       : M. Gusti Aji | P064209
# Division     : IT Application Services
# Last Update  : 13-04-2026
###############################################################################

set -u

SRC_FILE="/export/home/oracle/scripts/automation/output_count/output_count_table_dc.csv"
DEST_HOST="192.168.140.30"
DEST_USER="oracle"
DEST_DIR="/export/home/oracle/scripts/automation/output_count"

# Validasi file source
if [ ! -f "$SRC_FILE" ]; then
  echo "ERROR: Source file not found: $SRC_FILE"
  exit 1
fi

# SFTP batch mode (passwordless)
sftp -oBatchMode=yes -oStrictHostKeyChecking=no "${DEST_USER}@${DEST_HOST}" <<EOF
cd $DEST_DIR
put $SRC_FILE
bye
EOF

RC=$?
if [ $RC -ne 0 ]; then
  echo "ERROR: SFTP failed (rc=$RC)"
  exit $RC
fi

echo "SUCCESS: File successfully transferred."