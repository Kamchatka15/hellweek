#!/usr/bin/env python3
"""studio_sync — serve the Rojo tree as JSON so Studio can pull it over MCP.

Why this exists: `rojo serve` + the Studio plugin is the normal workflow, but the
plugin's Connect button is an editor-UI click, and Studio MCP's simulated input only
reaches play mode. That makes an unattended playtest impossible. This serves the same
tree the Rojo project describes, flattened, so one execute_luau call can rebuild it in
the DataModel with no human in the loop.

It is a TEST harness, not a replacement for Rojo. Disk stays the source of truth and
`rojo build` is still what CI checks (skills/rojo-map.md).

  python3 tools/studio_sync.py [port]     # default 34873, serves /tree
"""

import json
import pathlib
import sys
from http.server import BaseHTTPRequestHandler, HTTPServer

ROOT = pathlib.Path(__file__).resolve().parent.parent
PROJECT = ROOT / "default.project.json"

SCRIPT_KINDS = {
    "init.luau": "ModuleScript",
    "init.server.luau": "Script",
    "init.client.luau": "LocalScript",
}


def mounts(node, path):
    """Walk default.project.json and yield (datamodel path, disk path) pairs."""
    if isinstance(node, dict):
        if "$path" in node:
            yield path, ROOT / node["$path"]
        for key, value in node.items():
            if not key.startswith("$"):
                yield from mounts(value, path + [key])


def walk(disk: pathlib.Path, path, out):
    """Flatten a directory into parent-first node records, mirroring Rojo's rules."""
    kind, source = "Folder", None
    for name, cls in SCRIPT_KINDS.items():
        init = disk / name
        if init.is_file():
            kind, source = cls, init.read_text()
            break
    out.append({"path": path, "class": kind, "source": source})

    for child in sorted(disk.iterdir()):
        if child.name.startswith(".") or child.name in SCRIPT_KINDS:
            continue
        if child.is_dir():
            walk(child, path + [child.name], out)
        elif child.suffix == ".luau":
            out.append(
                {
                    "path": path + [child.stem],
                    "class": "ModuleScript",
                    "source": child.read_text(),
                }
            )


def build_tree():
    project = json.loads(PROJECT.read_text())
    out = []
    for path, disk in mounts(project["tree"], []):
        if disk.is_dir():
            walk(disk, path, out)
    return out


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        payload = json.dumps(build_tree()).encode()  # rebuilt per request: always fresh
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def log_message(self, *_args):
        pass


if __name__ == "__main__":
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 34873
    nodes = build_tree()
    print(f"studio_sync: {len(nodes)} nodes, {sum(len(n['source'] or '') for n in nodes)} bytes")
    HTTPServer(("127.0.0.1", port), Handler).serve_forever()
