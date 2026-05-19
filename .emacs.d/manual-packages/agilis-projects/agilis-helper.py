#!/usr/bin/env python3
"""Agilis Odoo XML-RPC helper for the agilis-projects Emacs package.

Subcommands:
    projects                       TSV: name\tid\thas_helpdesk_team
    tasks <project-id>             one task name per line
    tickets <project-id> <uid>     one ticket name per line
    uid                            authenticated user id

Env: ODOO_URL, ODOO_DB, ODOO_USER, ODOO_PW.
Exit: 0 ok, 2 auth, 3 network, 4 missing env, 5 bad usage.
"""
import os
import sys
import xmlrpc.client


def die(code: int, msg: str) -> None:
    print(msg, file=sys.stderr)
    sys.exit(code)


def env_or_die() -> tuple[str, str, str, str]:
    required = ("ODOO_URL", "ODOO_DB", "ODOO_USER", "ODOO_PW")
    missing = [k for k in required if not os.environ.get(k)]
    if missing:
        die(4, f"missing env: {', '.join(missing)}")
    return (
        os.environ["ODOO_URL"].rstrip("/"),
        os.environ["ODOO_DB"],
        os.environ["ODOO_USER"],
        os.environ["ODOO_PW"],
    )


def authenticate(url: str, db: str, user: str, pw: str) -> int:
    try:
        common = xmlrpc.client.ServerProxy(f"{url}/xmlrpc/2/common")
        uid = common.authenticate(db, user, pw, {})
    except (xmlrpc.client.Fault, xmlrpc.client.ProtocolError, OSError) as e:
        die(3, f"network: {e}")
    if not uid:
        die(2, "auth failed")
    return uid


def call(url: str, db: str, uid: int, pw: str, model: str, method: str,
         args: list, kwargs: dict):
    try:
        models = xmlrpc.client.ServerProxy(f"{url}/xmlrpc/2/object")
        return models.execute_kw(db, uid, pw, model, method, args, kwargs)
    except (xmlrpc.client.Fault, xmlrpc.client.ProtocolError, OSError) as e:
        die(3, f"network: {e}")


def cmd_projects(url, db, uid, pw):
    rows = call(url, db, uid, pw, "project.project", "search_read",
                [[["active", "=", True]]],
                {"fields": ["name", "id", "has_helpdesk_team"],
                 "order": "name asc"})
    out = sys.stdout
    for r in rows:
        name = (r.get("name") or "").strip()
        if not name:
            continue
        flag = "1" if r.get("has_helpdesk_team") else "0"
        out.write(f"{name}\t{r['id']}\t{flag}\n")


def cmd_tasks(url, db, uid, pw, project_id: int):
    rows = call(url, db, uid, pw, "project.task", "search_read",
                [[["project_id", "=", project_id],
                  ["active", "=", True]]],
                {"fields": ["name"], "order": "name asc"})
    out = sys.stdout
    for r in rows:
        name = (r.get("name") or "").strip()
        if name:
            out.write(name + "\n")


def cmd_tickets(url, db, uid, pw, project_id: int, target_uid: int):
    rows = call(url, db, uid, pw, "helpdesk.ticket", "search_read",
                [[["project_id", "=", project_id],
                  ["user_id", "=", target_uid],
                  ["close_date", "=", False]]],
                {"fields": ["name"], "order": "name asc"})
    out = sys.stdout
    for r in rows:
        name = (r.get("name") or "").strip()
        if name:
            out.write(name + "\n")


def parse_int(s: str, label: str) -> int:
    try:
        return int(s)
    except ValueError:
        die(5, f"bad {label}: {s!r}")


def main() -> None:
    if len(sys.argv) < 2:
        die(5, "usage: agilis-helper.py <projects|tasks|tickets|uid> [args]")
    sub = sys.argv[1]
    url, db, user, pw = env_or_die()
    uid = authenticate(url, db, user, pw)

    if sub == "projects":
        if len(sys.argv) != 2:
            die(5, "usage: projects")
        cmd_projects(url, db, uid, pw)
    elif sub == "tasks":
        if len(sys.argv) != 3:
            die(5, "usage: tasks <project-id>")
        cmd_tasks(url, db, uid, pw, parse_int(sys.argv[2], "project-id"))
    elif sub == "tickets":
        if len(sys.argv) != 4:
            die(5, "usage: tickets <project-id> <user-id>")
        cmd_tickets(url, db, uid, pw,
                    parse_int(sys.argv[2], "project-id"),
                    parse_int(sys.argv[3], "user-id"))
    elif sub == "uid":
        if len(sys.argv) != 2:
            die(5, "usage: uid")
        sys.stdout.write(f"{uid}\n")
    else:
        die(5, f"unknown subcommand: {sub}")


if __name__ == "__main__":
    main()
