# Odoo 12 — Nginx Reverse Proxy with SSL

**Date:** 2026-04-02
**Server:** 4.194.232.85 (Ubuntu 18.04)
**SSH:** `LSProdLinux@4.194.232.85` / `LSProdLinux1234!`
**Domain:** `loansmartproduction.encorefinancials.com`
**Context:** The Odoo 12 production instance is running with the restored Loan_Smart database. This sets up Nginx as a reverse proxy with Let's Encrypt SSL, then locks Odoo to localhost.

## What

Install Nginx as a reverse proxy in front of Odoo, obtain a free SSL certificate via Certbot (Let's Encrypt), enable HTTP-to-HTTPS redirect, then bind Odoo to 127.0.0.1 so all traffic must go through Nginx.

## Prerequisites

- DNS A record for `loansmartproduction.encorefinancials.com` must point to `4.194.232.85` (currently resolves to `217.21.73.240` — blocking gate)
- Port 80 must be reachable from the internet (currently open, UFW inactive)
- Odoo is running on ports 8069 (web) and 8072 (longpolling) on `0.0.0.0`

## Server State

- **Odoo**: 16 workers + longpolling on 8072, `db_name = Loan_Smart`
- **Nginx**: not installed
- **Certbot**: not installed
- **UFW**: inactive
- **No existing web server** on ports 80/443

## 1. Nginx Reverse Proxy Configuration

Install Nginx and create a virtual host at `/etc/nginx/sites-available/odoo`:

- Proxy `/` → `http://127.0.0.1:8069` (Odoo web)
- Proxy `/longpolling` → `http://127.0.0.1:8072` (Odoo longpolling for live chat/notifications)
- Set proxy headers: `X-Forwarded-For`, `X-Forwarded-Proto`, `Host`
- Set `client_max_body_size` to a reasonable value (e.g., 100M) for file uploads
- Enable gzip compression for static assets
- Symlink to `sites-enabled/`, remove default site

## 2. SSL with Certbot (Let's Encrypt)

- Install Certbot with Nginx plugin (`python-certbot-nginx` on Ubuntu 18.04)
- Run `certbot --nginx -d loansmartproduction.encorefinancials.com`
  - Obtains certificate via HTTP-01 challenge
  - Automatically modifies Nginx config for SSL
  - Sets up HTTP → HTTPS redirect
- Certbot auto-renewal via systemd timer/cron (no manual renewal)
- Verify with `certbot renew --dry-run`

## 3. Lock Down Odoo & Enable Proxy Mode

After Nginx + SSL are confirmed working:

- Add `proxy_mode = True` to `/etc/odoo12.conf` — trust `X-Forwarded-*` headers
- Add `xmlrpc_interface = 127.0.0.1` — bind web port to localhost
- Add `netrpc_interface = 127.0.0.1` — bind longpolling port to localhost
- Restart Odoo

Direct access via `http://4.194.232.85:8069` stops working after this step.

## 4. Execution Order (Safety)

The order prevents lockout:

1. DNS check — confirm domain resolves to `4.194.232.85` (blocking gate)
2. Install & configure Nginx — proxy to Odoo, test HTTP
3. Verify HTTP — `curl http://loansmartproduction.encorefinancials.com` returns Odoo
4. Run Certbot — obtain SSL, enable HTTPS redirect
5. Verify HTTPS — `curl https://loansmartproduction.encorefinancials.com` returns 200
6. Lock down Odoo — bind to 127.0.0.1, enable proxy_mode
7. Final verify — HTTPS works, direct IP access is blocked

Odoo remains directly accessible as a fallback until step 6.

## Verification

- `curl -s -o /dev/null -w "%{http_code}" https://loansmartproduction.encorefinancials.com/web/login` → `200`
- `curl -s -o /dev/null -w "%{http_code}" http://loansmartproduction.encorefinancials.com/web/login` → `301` (redirect to HTTPS)
- `curl -s -o /dev/null -w "%{http_code}" http://4.194.232.85:8069/web/login` → connection refused (locked down)
- `certbot renew --dry-run` → success
- `sudo journalctl -u odoo12 --no-pager -n 20` → no critical errors
