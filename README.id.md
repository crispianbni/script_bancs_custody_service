# Script BaNCS Custody Service

![Version](https://img.shields.io/badge/version-1.0-blue)
![License](https://img.shields.io/badge/license-Private-red)
![Status](https://img.shields.io/badge/status-Production-green)

Repositori ini berisi kumpulan script Linux untuk tugas housekeeping yang dijalankan oleh layanan BaNCS Custody. Semua skrip dirancang agar mudah dibaca, lingkungan‑agnostik, dan cocok dipasang pada server produksi.

---
🌐 **Bahasa / Languages**
- 🇮🇩 Bahasa Indonesia
- 🇬🇧 [English](README.md)

## 📋 Daftar Isi

- [Ringkasan](#ringkasan)
- [Prasyarat](#prasyarat)
- [Instalasi & Setup](#instalasi--setup)
- [Struktur Direktori](#struktur-direktori)
- [Deskripsi Script](#deskripsi-script)
- [Cara Penggunaan](#cara-penggunaan)
- [Konfigurasi](#konfigurasi)
- [Troubleshooting](#troubleshooting)
- [Kontak & Dukungan](#kontak--dukungan)

---

## 📌 Ringkasan

Proyek ini menampung dua script utama:

1. **housekeeping_sihome_log.sh** – mengorganisir dan mengarsipkan log BaNCSSI, EAI, dan SILOG berdasarkan tanggal.
2. **housekeeping_sihome_bis4o2.sh** – memproses file BIS4O2, memindahkannya ke struktur folder tahunan/bulanan, serta mengarsipkan tahun‑lama.

Keduanya mempromosikan kebersihan filesystem, mempermudah pelacakan, dan mengurangi jumlah file dalam direktori sumber.

---

## 🔧 Prasyarat

- Sistem Operasi: Linux (semua distribusi standar)
- Shell: Bash 4.x atau lebih baru
- Utilitas umum: `mkdir`, `mv`, `tar`, `gzip`, `date`, `cut`, `basename`
- Izin tulis di direktori sumber dan target yang dikonfigurasi
- Ruang disk memadai untuk arsip dan kompresi

---

## 📦 Instalasi & Setup

```bash
# misalnya di /home/ops/scripts/
cd /home/ops/
git clone <repository-url> script_bancs_custody_service
cd script_bancs_custody_service

# buat output jika belum ada
mkdir -p housekeeping_sihome_logs/output
mkdir -p housekeeping_sihome_bis4o2/output

# berikan eksekusi
chmod +x housekeeping_sihome_logs/housekeeping_sihome_log.sh
chmod +x housekeeping_sihome_bis4o2/housekeeping_sihome_bis4o2.sh
```

Opsional: jalankan di crontab untuk otomatisasi harian/periodik.

```bash
crontab -e
# contoh setiap tengah malam
0 0 * * * /home/ops/script_bancs_custody_service/housekeeping_sihome_logs/housekeeping_sihome_log.sh >> /var/log/bancs_housekeeping.log 2>&1
0 1 * * * /home/ops/script_bancs_custody_service/housekeeping_sihome_bis4o2/housekeeping_sihome_bis4o2.sh >> /var/log/bis4o2_housekeeping.log 2>&1
```

---

## 📂 Struktur Direktori

```
script_bancs_custody_service/
│
├── README.id.md                 # Dokumentasi Bahasa Indonesia
├── README.md                    # Dokumentasi Bahasa Inggris
│
├── housekeeping_sihome_logs/     # Modul log housekeeping
│   ├── housekeeping_sihome_log.sh
│   ├── file/                     # contoh file input
│   └── output/                   # struktur output hasil pemrosesan
│       ├── BANCSSI/
│       ├── EAI/
│       └── SILOG/
│
└── housekeeping_sihome_bis4o2/   # Modul BIS4O2 housekeeping
    ├── housekeeping_sihome_bis4o2.sh
    ├── file/                     # contoh file input
    └── output/                   # struktur output hasil pemrosesan
        └── bis4/
```

---

## 🚀 Deskripsi Script

### 1. housekeeping_sihome_log.sh

**Tujuan**: Memindahkan file log BaNCSSI.log.YYYY-MM-DD, EAI.log.YYYY-MM-DD, dan arsip SILog_*.tar.gz ke struktur direktori per tahun/bulan; kemudian mengompresi folder tahunan kecuali tahun berjalan.

**Alur kerja**:
- Cari file sesuai pola dalam `SOURCE_DIR` (default: `LOGS`)
- Ekstrak tahun/bulan dari nama file
- Buat direktori target (`OUTFILE_BANCSSI`, `OUTFILE_EAI`, `OUTFILE_SILOG`)
- Pindahkan file ke folder yang sesuai
- Setelah memproses semua file, jalankan fungsi kompresi untuk setiap jenis log
  - Buat tar + gzip untuk setiap direktori tahun (kecuali tahun berjalan)

**Konfigurasi default**:
```bash
SOURCE_DIR="LOGS"
OUTFILE_BANCSSI="LOGS/BANCSSI/"
OUTFILE_EAI="LOGS/EAI/"
OUTFILE_SILOG="LOGS/SILOG/"
```

**Catatan**: Variabel dapat diubah menjadi path absolut sesuai lingkungan produksi.

### 2. housekeeping_sihome_bis4o2.sh

**Tujuan**: Membersihkan file `BIS4*.txt` di direktori sumber dengan memindahkan ke struktur `bis4/YYYY/MM` berdasarkan tanggal yang tersimpan di nama file; lalu mengompresi direktori tahun sebelum tahun berjalan.

**Alur kerja**:
- Baca semua file `BIS4*.txt` dari `SOURCE_DIR`
- Ambil tanggal dari karakter 5‑10 nama file (ddmmyy)
- Konversi tahun dua digit ke empat digit
- Pindahkan file ke `OUTFILE_BIS4/YYYY/MM`
- Setelah selesai, buat arsip tar.gz untuk tiap tahun selain tahun berjalan dan hapus foldernya (opsional, sudah ditandai)

**Konfigurasi default**:
```bash
SOURCE_DIR="/export/home/cusadmin/BANCSHOME/SIHOME/datafiles/BIS4O2/archive/"
OUTFILE_BIS4="/export/home/cusadmin/BANCSHOME/SIHOME/datafiles/BIS4O2/archive/bis4/"
# variable commented memiliki contoh local path
```

---

## 💻 Cara Penggunaan

Jalankan skrip secara manual:

```bash
cd script_bancs_custody_service/housekeeping_sihome_logs
./housekeeping_sihome_log.sh

cd ../housekeeping_sihome_bis4o2
./housekeeping_sihome_bis4o2.sh
```

Output log dan struktur target akan terlihat di direktori `output/` masing‑masing.

Gunakan cron atau systemd untuk operasi rutin.

---

## ⚙️ Konfigurasi

Ubah variabel di awal setiap file skrip jika perlu:

- `SOURCE_DIR` – lokasi log atau data file input
- `OUTFILE_*` – direktori tujuan pemrosesan
- Untuk BIS4O2 ada helper `convert_year_to_4digit` jika pola tahun berubah

---

## 🔍 Troubleshooting

### Tidak ada file yang diproses
- Periksa path `SOURCE_DIR` dan pola nama file.
- Jalankan `ls -l $SOURCE_DIR`.

### Hak akses ditolak
```bash
chmod -R 750 $SOURCE_DIR $OUTFILE_BANCSSI $OUTFILE_EAI $OUTFILE_SILOG $OUTFILE_BIS4
chown ops:ops ...
```

### Kompresi gagal
- Pastikan utilitas `tar` dan `gzip` terpasang
- Periksa ruang disk tersedia

### File tidak berpindah ke folder yang benar
- Cek nama file, skrip mengekstrak tanggal berdasarkan posisi karakter. Pola harus konsisten.

---

## 📞 Kontak & Dukungan

**Author**: Crispian (901146) – IT Application Services

Untuk masalah atau permintaan fitur, ajukan issue di repositori ini atau hubungi tim IT Application Services.

---

## 📝 License

Proprietary Software – All Rights Reserved. 
Penggunaan terbatas untuk keperluan internal perusahaan, tanpa izin dilarang mendistribusikan.

---

## 📊 Changelog

### Version 1.0 – 19 Februari 2026
- Dokumen awal
- Dua skrip housekeeping siap produksi

---

**Last Updated**: 19 Februari 2026  
**Maintained By**: IT Application Services
