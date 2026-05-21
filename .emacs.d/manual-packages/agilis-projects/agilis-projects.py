#!/usr/bin/env python3
"""Query active Odoo project.project data.

With no argument: print each active project's name, one per line.

With "scaffold <project-name>": print "task" or "ticket" on the first
line (per the project's helpdesk status), then that project's task
names (or the caller's open ticket names) one per line.  The project
name is matched ignoring leading/trailing whitespace.

Reads credentials from env: ODOO_URL, ODOO_DB, ODOO_USER, ODOO_PW.
Exit codes: 0 ok, 2 auth, 3 network, 4 missing env, 5 bad args / unknown project.
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

    models = xmlrpc.client.ServerProxy(f"{url}/xmlrpc/2/object")
    sub = sys.argv[1] if len(sys.argv) > 1 else None

    if sub is None:
        try:
            rows = models.execute_kw(
                db, uid, pw,
                "project.project", "search_read",
                [[["active", "=", True]]],
                {"fields": ["name"]},
            )
        except (xmlrpc.client.Fault, xmlrpc.client.ProtocolError, OSError) as e:
            die(3, f"network: {e}")
        for r in rows:
            name = (r.get("name") or "").strip()
            if name:
                sys.stdout.write(name + "\n")
        return

    if sub != "scaffold" or len(sys.argv) < 3:
        die(5, f"usage: {sys.argv[0]} [scaffold <project-name>]")

    wanted = sys.argv[2].strip()
    try:
        projects = models.execute_kw(
            db, uid, pw,
            "project.project", "search_read",
            [[["active", "=", True], ["name", "ilike", wanted]]],
            {"fields": ["id", "name", "has_helpdesk_team"]},
        )
    except (xmlrpc.client.Fault, xmlrpc.client.ProtocolError, OSError) as e:
        die(3, f"network: {e}")

    matches = [p for p in projects if (p.get("name") or "").strip() == wanted]
    if not matches:
        die(5, f"unknown project: {wanted}")
    project = matches[0]
    helpdesk = bool(project.get("has_helpdesk_team"))

    try:
        if helpdesk:
            recs = models.execute_kw(
                db, uid, pw,
                "helpdesk.ticket", "search_read",
                [[["project_id", "=", project["id"]],
                  ["user_id", "=", uid],
                  ["close_date", "=", False]]],
                {"fields": ["name"]},
            )
        else:
            recs = models.execute_kw(
                db, uid, pw,
                "project.task", "search_read",
                [[["project_id", "=", project["id"]],
                  ["active", "=", True]]],
                {"fields": ["name"]},
            )
    except (xmlrpc.client.Fault, xmlrpc.client.ProtocolError, OSError) as e:
        die(3, f"network: {e}")

    print("ticket" if helpdesk else "task")
    names = sorted(
        {(r.get("name") or "").strip() for r in recs
         if (r.get("name") or "").strip()}
    )
    for n in names:
        print(n)


if __name__ == "__main__":
    main()
