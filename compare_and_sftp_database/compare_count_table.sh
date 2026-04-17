#!/bin/bash

###############################################################################
# Script Name  : compare_count_table.sh
# Description  : Script compare hasil count table DC vs DRC.
# Server       : DB DC & DRC
# Author       : Crispian | 901146
# Division     : IT Application Services
# Last Update  : 09-04-2026
###############################################################################

set -euo pipefail
IFS=$'\n\t'

DC_FILE="/export/home/oracle/scripts/automation/output_count/output_count_table_dc.csv"
DRC_FILE="/export/home/oracle/scripts/automation/output_count/output_count_table_drc.csv"
OUT_FILE="/export/home/oracle/scripts/automation/output_count/hasil_compare_dc_drc.txt"

TANGGAL=$(date +%d/%m/%Y)

if [[ ! -f "$DC_FILE" ]]; then
  echo "ERROR: File DC tidak ditemukan: $DC_FILE" >&2
  exit 1
fi

if [[ ! -f "$DRC_FILE" ]]; then
  echo "ERROR: File DRC tidak ditemukan: $DRC_FILE" >&2
  exit 1
fi

DC_TMP=$(mktemp --tmpdir compare_count_dc.XXXXXX)
DRC_TMP=$(mktemp --tmpdir compare_count_drc.XXXXXX)
NOT_MATCH_TMP=$(mktemp --tmpdir compare_count_not_match.XXXXXX)
MATCH_LIMIT=5
MATCH_COUNT=0

cleanup() {
  rm -f "$DC_TMP" "$DRC_TMP" "$NOT_MATCH_TMP"
}
trap cleanup EXIT

gawk -F',' 'NR>1 {
  gsub(/"/, ""); gsub(/\r/, "");
  if ($1 != "" && $2 != "") print $1 "|" $2
}' "$DC_FILE" | sort > "$DC_TMP"

gawk -F',' 'NR>1 {
  gsub(/"/, ""); gsub(/\r/, "");
  if ($1 != "" && $2 != "") print $1 "|" $2
}' "$DRC_FILE" | sort > "$DRC_TMP"

echo
echo "                                           SO SB BANCS 2026"
echo "                                          Tanggal : $TANGGAL"
echo
echo "+------------------------------+------------+------------------------------+------------+------------+" | tee -a "$OUT_FILE"
echo "|           DC TABLE NAME      |   COUNT    |         DRC TABLE NAME       |   COUNT    |   KET      |" | tee -a "$OUT_FILE"
echo "+------------------------------+------------+------------------------------+------------+------------+" | tee -a "$OUT_FILE"

while IFS='|' read -r DC_TABLE_NAME DC_COUNT; do
  DRC_LINE=$(gawk -F'|' -v t="$DC_TABLE_NAME" '$1==t {print; exit}' "$DRC_TMP")

  if [[ -z "$DRC_LINE" ]]; then
    printf "| %-28s | %-10s | %-28s | %-10s | %-10s |\n" \
      "$DC_TABLE_NAME" "$DC_COUNT" "-" "-" "DC ONLY" >> "$NOT_MATCH_TMP"
    continue
  fi

  IFS='|' read -r DRC_TABLE_NAME DRC_COUNT <<< "$DRC_LINE"

  if [[ "$DC_COUNT" == "$DRC_COUNT" ]]; then
    if [[ $MATCH_COUNT -lt $MATCH_LIMIT ]]; then
      printf "| %-28s | %-10s | %-28s | %-10s | %-10s |\n" \
        "$DC_TABLE_NAME" "$DC_COUNT" "$DRC_TABLE_NAME" "$DRC_COUNT" "MATCH" | tee -a "$OUT_FILE"
      MATCH_COUNT=$((MATCH_COUNT + 1))
    fi
  else
    printf "| %-28s | %-10s | %-28s | %-10s | %-10s |\n" \
      "$DC_TABLE_NAME" "$DC_COUNT" "$DRC_TABLE_NAME" "$DRC_COUNT" "NOT MATCH" >> "$NOT_MATCH_TMP"
  fi
 done < "$DC_TMP"

if [[ -s "$NOT_MATCH_TMP" ]]; then
  if [[ $MATCH_COUNT -gt 0 ]]; then
    printf "| %-28s | %-10s | %-28s | %-10s | %-10s |\n" \
      "..." "..." "..." "..." "..." | tee -a "$OUT_FILE"
  fi
  cat "$NOT_MATCH_TMP" | tee -a "$OUT_FILE"
fi

echo "+------------------------------+------------+------------------------------+------------+------------+" | tee -a "$OUT_FILE"