# Odoo 12 — Restore Production Database from Backup

**Date:** 2026-04-02
**Server:** 4.194.232.85 (Ubuntu 18.04)
**SSH:** `LSProdLinux@4.194.232.85` / `LSProdLinux1234!`
**Context:** Part of migration from Azure Windows. The client's data engineer transferred the production backup to the server. This restores the `Loan_Smart` database and filestore onto the freshly installed Odoo 12 instance.

## What

Drop the blank `odoo12` database, restore the 37 GB SQL dump as `Loan_Smart`, copy the 15 GB filestore into Odoo's data directory, update config to lock Odoo to the `Loan_Smart` database, and restart.

## Backup Inventory

Located at `/home/LSProdLinux/Backup/`:

| File | Size | Description |
|------|------|-------------|
| `dump.sql` | 37 GB | PostgreSQL plain-text dump |
| `filestore/` | 15 GB (257 subdirs) | Odoo filestore (attachments, images) |
| `manifest.json` | 4.4 KB | Odoo backup manifest |
| `Loan_Smart_2026-04-02_071150.zip` | 26 GB | Odoo-format backup (not used) |

Manifest details: DB name `Loan_Smart`, Odoo 12.0 final, PG 9.5 source, ~70 installed modules.

## Server State

- **PostgreSQL:** 10.23 (forward-compatible with PG 9.5 dump)
- **Disk:** 912 GB free on 993 GB partition
- **Current DB:** `odoo12` — blank install (only `base` + web modules, 5 default users)
- **Odoo config:** `addons_path = /opt/odoo12/odoo-custom-addons`, no `db_name` or `data_dir` set
- **Default data_dir:** `/opt/odoo12/.local/share/Odoo/`

## Steps

### 1. Stop Odoo & Drop Existing DB

- Stop the Odoo service
- Drop the blank `odoo12` database
- Create `Loan_Smart` database owned by `odoo12`

### 2. Restore SQL Dump

- Restore via `nohup` to survive SSH session drops:
  ```
  nohup sudo -u odoo12 psql Loan_Smart < /home/LSProdLinux/Backup/dump.sql > /tmp/restore.log 2>&1 &
  ```
- Monitor progress by checking if `psql` is still running, tailing the log, and querying DB size growth
- After completion, check log for errors

### 3. Copy Filestore

- Target: `/opt/odoo12/.local/share/Odoo/filestore/Loan_Smart/`
- Copy from `/home/LSProdLinux/Backup/filestore/` (15 GB, 257 subdirs)
- Also via `nohup` for resilience
- Fix ownership to `odoo12:odoo12`

### 4. Update Config & Restart

- Add `db_name = Loan_Smart` to `/etc/odoo12.conf` (restricts Odoo to this database only)
- Restart Odoo service
- Verify: HTTP 200 on port 8069, clean logs, DB size looks reasonable

## Verification

- `curl -s -o /dev/null -w "%{http_code}" http://localhost:8069/web/login` → `200`
- `sudo journalctl -u odoo12 --no-pager -n 30` — no critical errors
- `sudo -u odoo12 psql -c "SELECT pg_size_pretty(pg_database_size('Loan_Smart'));"` — reasonable size
- Filestore exists at `/opt/odoo12/.local/share/Odoo/filestore/Loan_Smart/` with 257 subdirs
