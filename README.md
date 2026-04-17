# BaNCS Custody Service Scripts

![Version](https://img.shields.io/badge/version-1.0-blue)
![License](https://img.shields.io/badge/license-Private-red)
![Status](https://img.shields.io/badge/status-Production-green)

This repository contains a set of Linux scripts used for housekeeping tasks performed by the BaNCS Custody service. The scripts are simple, environment‑agnostic, and suitable for deployment on production servers.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Installation & Setup](#installation--setup)
- [Directory Structure](#directory-structure)
- [Script Descriptions](#script-descriptions)
- [Usage Guide](#usage-guide)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)
- [Support & Contact](#support--contact)

---

## 📌 Overview

This project includes three primary script groups:

1. **housekeeping_sihome_log.sh** – organizes and archives BaNCSSI, EAI and SILOG log files by date.
2. **housekeeping_sihome_bis4o2.sh** – processes BIS4 data files, moving them into a year/month folder structure and archiving old years.
3. **rename_mocktest_files/** – manages mocktest configuration renames for active and original file sets.

All scripts keep the filesystem tidy, ease tracking, and reduce the number of files in source directories.

---

## 🔧 Prerequisites

- Operating System: Linux (any standard distribution)
- Shell: Bash 4.x or later
- Common utilities: `mkdir`, `mv`, `tar`, `gzip`, `date`, `cut`, `basename`
- Write permission on configured source/target directories
- Sufficient disk space for archives and compression

---

## 📦 Installation & Setup

```bash
# e.g. under /home/ops/
cd /home/ops/
git clone <repository-url> script_bancs_custody_service
cd script_bancs_custody_service

# create output dirs if they don't exist
mkdir -p housekeeping_sihome_logs/output
mkdir -p housekeeping_sihome_bis4o2/output

# make scripts executable
chmod +x housekeeping_sihome_logs/housekeeping_sihome_log.sh
chmod +x housekeeping_sihome_bis4o2/housekeeping_sihome_bis4o2.sh
chmod +x rename_mocktest_files/*.sh
```

Optional: run them from cron for daily/periodic automation.

```bash
crontab -e
# example midnight jobs
0 0 * * * /home/ops/script_bancs_custody_service/housekeeping_sihome_logs/housekeeping_sihome_log.sh >> /var/log/bancs_housekeeping.log 2>&1
0 1 * * * /home/ops/script_bancs_custody_service/housekeeping_sihome_bis4o2/housekeeping_sihome_bis4o2.sh >> /var/log/bis4o2_housekeeping.log 2>&1
```

---

## 📂 Directory Structure

```
script_bancs_custody_service/
│
├── README.id.md                 # Indonesian documentation
├── README.md                    # English documentation
│
├── housekeeping_sihome_logs/     # Log housekeeping module
│   ├── housekeeping_sihome_log.sh
│   ├── file/                     # sample input files
│   └── output/                   # processed output structure
│       ├── BANCSSI/
│       ├── EAI/
│       └── SILOG/
│
├── housekeeping_sihome_bis4o2/   # BIS4O2 housekeeping module
│   ├── housekeeping_sihome_bis4o2.sh
│   ├── file/                     # sample input files
│   └── output/                   # processed output structure
│       └── bis4/
└── rename_mocktest_files/        # Mocktest rename helper module
    ├── mock_active.sh
    └── original_active.sh
```

---

## 🚀 Script Descriptions

### 1. housekeeping_sihome_log.sh

**Purpose**: Move `BaNCSSI.log.YYYY-MM-DD`, `EAI.log.YYYY-MM-DD` and SILog archive files into a per-year/per-month directory structure, then compress year folders except the current year.

**Workflow**:
- Scan `SOURCE_DIR` (default `LOGS`) for matching filenames
- Extract year/month from each name
- Create target directories (`OUTFILE_BANCSSI`, `OUTFILE_EAI`, `OUTFILE_SILOG`)
- Move files into the correct folder
- After processing, run compression functions:
  - tar + gzip each yearly folder (skips current year)

**Default configuration**:
```bash
SOURCE_DIR="LOGS"
OUTFILE_BANCSSI="LOGS/BANCSSI/"
OUTFILE_EAI="LOGS/EAI/"
OUTFILE_SILOG="LOGS/SILOG/"
```

**Notes**: Variables may be changed to absolute paths as needed.

### 2. housekeeping_sihome_bis4o2.sh

**Purpose**: Clean up `BIS4*.txt` files in the source directory by moving them into `bis4/YYYY/MM` based on the date embedded in the filename, then compress directories of past years.

**Workflow**:
- Enumerate all `BIS4*.txt` files in `SOURCE_DIR`
- Parse the date from characters 5‑10 of the filename (`ddmmyy`)
- Convert two‑digit year to four digits
- Move file to `OUTFILE_BIS4/YYYY/MM`
- Once done, archive each yearly folder (excluding current year) as `BIS4_YYYY.tar.gz` and delete the original directory if desired

**Default configuration**:
```bash
SOURCE_DIR="/export/home/cusadmin/BANCSHOME/SIHOME/datafiles/BIS4O2/archive/"
OUTFILE_BIS4="/export/home/cusadmin/BANCSHOME/SIHOME/datafiles/BIS4O2/archive/bis4/"
# commented variables show a local testing alternative
```

---

### 3. rename_mocktest_files

**Purpose**: Manage mocktest configuration file renames between active and original environments.

**Scripts**:
- `mock_active.sh` — backup current active config files to `*_Original` and restore `_MOC2025` files as active.
- `original_active.sh` — backup current active config files to `*_Mock` and restore `*_Original` files as active.

**Workflow**:
- Use `BASE_DIR` to locate configuration files under the BaNCS installation tree.
- Rename files with checks to prevent overwriting existing destination files.
- Log each step and wait briefly between rename phases.

**Default configuration**:
```bash
BASE_DIR="/export/home/cusadmin/BANCSHOME"
```

**Notes**: Adjust `BASE_DIR` or run the script from the module directory as needed.

---

## 💻 Usage Guide

Run scripts manually:

```bash
cd script_bancs_custody_service/housekeeping_sihome_logs
./housekeeping_sihome_log.sh

cd ../housekeeping_sihome_bis4o2
./housekeeping_sihome_bis4o2.sh

cd ../rename_mocktest_files
./mock_active.sh
./original_active.sh
```

Processed output and logs will appear under each module’s `output/` directory.

Use cron or systemd for regular execution.

---

## ⚙️ Configuration

Edit the top of each script to adjust paths:

- `SOURCE_DIR` – location of log/data files
- `OUTFILE_*` – destination directories
- The BIS4O2 script includes a helper function `convert_year_to_4digit` for handling two‑digit years.

---

## 🔍 Troubleshooting

### No files processed
- Check `SOURCE_DIR` path and file name patterns:
  ```bash
  ls -l $SOURCE_DIR
  ```

### Permission denied
```bash
chmod -R 750 $SOURCE_DIR $OUTFILE_BANCSSI $OUTFILE_EAI $OUTFILE_SILOG $OUTFILE_BIS4
chown ops:ops ...
```

### Compression fails
- Ensure `tar` and `gzip` are installed
- Verify sufficient disk space

### Files moved to wrong folder
- Confirm filename format; parsing is position‑based and requires consistency.

---

## 📞 Support & Contact

**Author**: Crispian (901146) – IT Application Services

For issues or enhancement requests, raise an issue in this repository or contact the IT Application Services team.

---

## 📝 License

Proprietary Software – All Rights Reserved. 
Use is limited to internal company purposes; distribution without permission is prohibited.

---

## 📊 Changelog

### Version 1.0 – 19 February 2026
- Initial documentation
- Two production housekeeping scripts added

---

**Last Updated**: 19 February 2026  
**Maintained By**: IT Application Services
