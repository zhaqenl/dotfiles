#!/usr/bin/env python3
"""Print active Odoo project.project.name values, one per line.

Reads credentials from env: ODOO_URL, ODOO_DB, ODOO_USER, ODOO_PW.
Exit codes: 0 ok, 2 auth, 3 network, 4 missing env.
"""
import os
import sys
import xmlrpc.client


def die(code: int, msg: str) -> None:
    print(msg, file=sys.stderr)
    sys.exit(code)


def main() -> None:
    required = ("ODOO_URL", "ODOO_DB", "ODOO_USER", "ODOO_PW")
    missing = [k for k in required if not os.environ.get(k)]
    if missing:
        die(4, f"missing env: {', '.join(missing)}")

    url = os.environ["ODOO_URL"].rstrip("/")
    db = os.environ["ODOO_DB"]
    user = os.environ["ODOO_USER"]
    pw = os.environ["ODOO_PW"]

    try:
        common = xmlrpc.client.ServerProxy(f"{url}/xmlrpc/2/common")
        uid = common.authenticate(db, user, pw, {})
    except (xmlrpc.client.Fault, xmlrpc.client.ProtocolError, OSError) as e:
        die(3, f"network: {e}")

    if not uid:
        die(2, "auth failed")

    try:
        models = xmlrpc.client.ServerProxy(f"{url}/xmlrpc/2/object")
        rows = models.execute_kw(
            db, uid, pw,
            "project.project", "search_read",
            [[["active", "=", True]]],
            {"fields": ["name"]},
        )
    except (xmlrpc.client.Fault, xmlrpc.client.ProtocolError, OSError) as e:
        die(3, f"network: {e}")

    out = sys.stdout
    for r in rows:
        name = (r.get("name") or "").strip()
        if name:
            out.write(name + "\n")


if __name__ == "__main__":
    main()
