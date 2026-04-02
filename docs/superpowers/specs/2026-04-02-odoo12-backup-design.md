# Odoo 12 — Automated Daily Database Backup

**Date:** 2026-04-02
**Server:** 4.194.232.85 (Ubuntu 18.04)
**SSH:** `LSProdLinux@4.194.232.85` / `LSProdLinux1234!`
**Context:** The Odoo 12 production instance is running with the restored Loan_Smart database (31 GB) and filestore (15 GB). This sets up automated daily backups with 7-day retention and a disk space safety check.

## What

A shell script at `/opt/odoo12/backup.sh` run daily at 2:00 AM UTC via cron. It creates a compressed database dump and filestore archive, rotates backups older than 7 days, and skips the backup if free disk space is below 100 GB.

## Server State

- **Database:** `Loan_Smart`, 31 GB, PostgreSQL 10.23, owned by `odoo12`
- **Filestore:** `/opt/odoo12/.local/share/Odoo/filestore/Loan_Smart/`, 15 GB, 257 subdirs
- **Disk:** 912 GB free on 993 GB partition (single `/dev/sda1`)
- **Odoo user:** `odoo12` — has PostgreSQL peer auth and filestore read access

## Estimated Storage

- Per backup: ~15-20 GB (compressed DB ~5-8 GB + compressed filestore ~10-12 GB)
- 7-day retention: ~105-140 GB total
- Disk warning threshold: 100 GB free (~5 backup cycles of headroom)

## 1. Backup Script

Script at `/opt/odoo12/backup.sh`, owned by `odoo12:odoo12`, executable.

**Flow:**
1. Check free disk space on `/opt` — if below 100 GB, log warning and exit
2. Create dated backup directory: `/opt/odoo12/backups/YYYY-MM-DD/`
3. `pg_dump Loan_Smart | gzip` → `/opt/odoo12/backups/YYYY-MM-DD/Loan_Smart.sql.gz`
4. `tar czf` the filestore → `/opt/odoo12/backups/YYYY-MM-DD/filestore.tar.gz`
5. Delete backup directories older than 7 days
6. Log all operations with timestamps to `/var/log/odoo12-backup.log`

All operations run as `odoo12` user (no root needed).

## 2. Cron Job & Permissions

- Cron entry in `odoo12`'s crontab: `0 2 * * * /opt/odoo12/backup.sh`
- Backup directory: `/opt/odoo12/backups/` owned by `odoo12:odoo12`
- Log file: `/var/log/odoo12-backup.log` writable by `odoo12`

## Verification

- `crontab -u odoo12 -l` → shows the 2 AM entry
- `ls /opt/odoo12/backups/` → dated directories
- Manual run: `sudo -u odoo12 /opt/odoo12/backup.sh` → creates today's backup
- Check log: `/var/log/odoo12-backup.log` shows success with timestamps
- Verify compressed dump: `zcat Loan_Smart.sql.gz | head -5` → SQL header
- Verify filestore archive: `tar tzf filestore.tar.gz | head -5` → file listing
