# Odoo 12 Database Restore — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers-extended-cc:subagent-driven-development (recommended) or superpowers-extended-cc:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restore the client's production Loan_Smart database (37 GB SQL dump + 15 GB filestore) onto the Odoo 12 server, replacing the blank install database.

**Architecture:** Stop Odoo, drop blank DB, restore dump via nohup for SSH resilience, copy filestore, update config to lock to Loan_Smart, restart and verify.

**Tech Stack:** PostgreSQL 10, psql, nohup, systemd, Odoo 12 config

**Server Access:** `ssh LSProdLinux@4.194.232.85` / password: `LSProdLinux1234!`

**SSH method:** Use paramiko from local machine (sshpass not available). All remote commands run via:
```python
import paramiko
ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
ssh.connect('4.194.232.85', username='LSProdLinux', password='LSProdLinux1234!', timeout=15)
stdin, stdout, stderr = ssh.exec_command('<command>', timeout=<seconds>)
stdout.channel.recv_exit_status()
output = stdout.read().decode()
ssh.close()
```

---

### Task 1: Stop Odoo and Prepare Database

**Goal:** Stop the Odoo service, drop the blank `odoo12` database, and create the `Loan_Smart` database ready for restore.

**Acceptance Criteria:**
- [ ] Odoo service is stopped
- [ ] `odoo12` database no longer exists
- [ ] `Loan_Smart` database exists, owned by `odoo12`

**Verify:** `sudo -u odoo12 psql -l | grep Loan_Smart` → shows `Loan_Smart` with owner `odoo12`

**Steps:**

- [ ] **Step 1: Stop the Odoo service**

```bash
sudo systemctl stop odoo12
```

- [ ] **Step 2: Verify Odoo is stopped**

```bash
systemctl is-active odoo12
```

Expected: `inactive`

- [ ] **Step 3: Drop the blank odoo12 database**

```bash
sudo -u odoo12 dropdb odoo12
```

- [ ] **Step 4: Verify odoo12 database is gone**

```bash
sudo -u odoo12 psql -l | grep odoo12
```

Expected: no output (database no longer listed)

- [ ] **Step 5: Create the Loan_Smart database**

```bash
sudo -u odoo12 createdb -O odoo12 -E UTF8 -T template0 Loan_Smart
```

- [ ] **Step 6: Verify Loan_Smart database exists**

```bash
sudo -u odoo12 psql -l | grep Loan_Smart
```

Expected: `Loan_Smart | odoo12 | UTF8 | ...`

---

### Task 2: Restore SQL Dump

**Goal:** Restore the 37 GB `dump.sql` into the `Loan_Smart` database using `nohup` for SSH session resilience, then verify the restore completed successfully.

**Acceptance Criteria:**
- [ ] `dump.sql` fully restored into `Loan_Smart`
- [ ] No critical errors in restore log
- [ ] Database size is reasonable (multi-GB)

**Verify:** `sudo -u odoo12 psql -c "SELECT pg_size_pretty(pg_database_size('Loan_Smart'));"` → multi-GB size

**Steps:**

- [ ] **Step 1: Start the restore via nohup**

```bash
nohup sudo -u odoo12 psql Loan_Smart < /home/LSProdLinux/Backup/dump.sql > /tmp/restore.log 2>&1 &
echo $!
```

Note the PID from `echo $!` for monitoring.

- [ ] **Step 2: Monitor — check if psql is still running**

Poll periodically (e.g., every 60–120 seconds):

```bash
pgrep -f "psql Loan_Smart"
```

If output shows a PID, restore is still in progress. If no output, restore has finished.

- [ ] **Step 3: Monitor — check DB size growth (optional)**

```bash
sudo -u odoo12 psql -c "SELECT pg_size_pretty(pg_database_size('Loan_Smart'));"
```

Size should grow over time as the restore progresses.

- [ ] **Step 4: After restore completes, check log tail for errors**

```bash
tail -30 /tmp/restore.log
```

Look for `ERROR` lines. Warnings about existing roles/extensions are acceptable. Critical errors about data or schema are not.

- [ ] **Step 5: Verify final database size**

```bash
sudo -u odoo12 psql -c "SELECT pg_size_pretty(pg_database_size('Loan_Smart'));"
```

Expected: multi-GB size (comparable to the dump).

- [ ] **Step 6: Verify key tables exist**

```bash
sudo -u odoo12 psql -d Loan_Smart -c "SELECT count(*) FROM res_users;"
```

Expected: more than the 5 default users — confirms real data was restored.

---

### Task 3: Copy Filestore

**Goal:** Copy the 15 GB filestore (257 subdirs) into Odoo's data directory for the `Loan_Smart` database, with correct ownership.

**Acceptance Criteria:**
- [ ] Filestore exists at `/opt/odoo12/.local/share/Odoo/filestore/Loan_Smart/`
- [ ] Contains ~257 subdirectories
- [ ] All files owned by `odoo12:odoo12`

**Verify:** `ls /opt/odoo12/.local/share/Odoo/filestore/Loan_Smart/ | wc -l` → `257` (approximately)

**Steps:**

- [ ] **Step 1: Create the target directory structure**

```bash
sudo mkdir -p /opt/odoo12/.local/share/Odoo/filestore/Loan_Smart
```

- [ ] **Step 2: Copy filestore via nohup**

```bash
nohup sudo cp -a /home/LSProdLinux/Backup/filestore/* /opt/odoo12/.local/share/Odoo/filestore/Loan_Smart/ > /tmp/filestore-copy.log 2>&1 &
echo $!
```

Note the PID for monitoring. The `-a` flag preserves permissions and directory structure.

- [ ] **Step 3: Monitor — check if copy is still running**

Poll periodically:

```bash
pgrep -f "cp -a.*filestore"
```

If output shows a PID, copy is in progress. If no output, copy has finished.

- [ ] **Step 4: Fix ownership**

```bash
sudo chown -R odoo12:odoo12 /opt/odoo12/.local/share/Odoo/filestore/Loan_Smart
```

- [ ] **Step 5: Verify filestore contents**

```bash
ls /opt/odoo12/.local/share/Odoo/filestore/Loan_Smart/ | wc -l
```

Expected: `257` (approximately)

- [ ] **Step 6: Verify ownership**

```bash
ls -la /opt/odoo12/.local/share/Odoo/filestore/Loan_Smart/ | head -5
```

Expected: all owned by `odoo12 odoo12`

---

### Task 4: Update Config, Restart, and Verify

**Goal:** Add `db_name = Loan_Smart` to the Odoo config to restrict Odoo to this database, restart the service, and verify everything works.

**Acceptance Criteria:**
- [ ] `/etc/odoo12.conf` contains `db_name = Loan_Smart`
- [ ] Odoo service is running
- [ ] HTTP 200 on port 8069
- [ ] No critical errors in Odoo logs

**Verify:** `curl -s -o /dev/null -w "%{http_code}" http://localhost:8069/web/login` → `200`

**Steps:**

- [ ] **Step 1: Add db_name to odoo12.conf**

```bash
sudo sed -i '/^\[options\]/a db_name = Loan_Smart' /etc/odoo12.conf
```

- [ ] **Step 2: Verify config change**

```bash
grep -E "^(db_name|addons_path)" /etc/odoo12.conf
```

Expected:
```
db_name = Loan_Smart
addons_path = /opt/odoo12/odoo-custom-addons
```

- [ ] **Step 3: Restart Odoo**

```bash
sudo systemctl restart odoo12
```

- [ ] **Step 4: Wait and verify HTTP**

```bash
sleep 20 && curl -s -o /dev/null -w "%{http_code}" http://localhost:8069/web/login
```

Expected: `200`

- [ ] **Step 5: Check logs for errors**

```bash
sudo journalctl -u odoo12 --no-pager -n 30
```

Expected: No critical errors about missing modules or tables. Warnings are acceptable.

- [ ] **Step 6: Verify database size**

```bash
sudo -u odoo12 psql -c "SELECT pg_size_pretty(pg_database_size('Loan_Smart'));"
```

Expected: multi-GB size.

- [ ] **Step 7: Clean up restore logs**

```bash
rm -f /tmp/restore.log /tmp/filestore-copy.log
```
