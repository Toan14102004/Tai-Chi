#!/usr/bin/env python3
"""
Cached Figma REST API client.

Every network response is written to .figma-cache/ and re-read from there on
later runs, so a node or an exported image is fetched exactly once. This exists
because the Figma account on this project sits on a Starter plan with a
Viewer/Collaborator seat, whose REST quota is small and shared across every
project using the same personal access token -- once it is spent, it stays
spent for over a day.

Token resolution, first hit wins:
  1. $FIGMA_API_KEY
  2. the figma-api MCP server entry for this repo in ~/.claude.json
No token is ever stored in this repo.

Usage:
  Tools/figma.py fetch <figma-url | fileKey> [nodeId] [--depth N] [--force]
  Tools/figma.py tree  <figma-url | fileKey> [nodeId] [--max-depth N]
  Tools/figma.py find  <figma-url | fileKey> <name-substring>
  Tools/figma.py node  <figma-url | fileKey> <nodeId>
  Tools/figma.py images <figma-url | fileKey> --ids <id,id> [--format png] [--scale 2] [--force]
  Tools/figma.py status
"""

import argparse
import json
import os
import re
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CACHE = os.path.join(ROOT, ".figma-cache")
API = "https://api.figma.com/v1"


# --------------------------------------------------------------------------
# token / target parsing
# --------------------------------------------------------------------------

def read_token():
    tok = os.environ.get("FIGMA_API_KEY")
    if tok:
        return tok.strip()

    cfg = os.path.expanduser("~/.claude.json")
    if not os.path.exists(cfg):
        die("No FIGMA_API_KEY and no ~/.claude.json to read it from.")

    with open(cfg) as fh:
        data = json.load(fh)

    entry = data.get("projects", {}).get(ROOT, {})
    for name, server in entry.get("mcpServers", {}).items():
        if "figma" not in name.lower():
            continue
        tok = server.get("env", {}).get("FIGMA_API_KEY")
        if tok:
            return tok.strip()
        for arg in server.get("args", []):
            if arg.startswith("--figma-api-key="):
                return arg.split("=", 1)[1].strip()

    die("Could not find a Figma token. Set FIGMA_API_KEY, or configure the "
        "figma-api MCP server for this repo.")


def parse_target(value):
    """Accept a full Figma URL or a bare file key. Returns (fileKey, nodeId|None)."""
    if not value.startswith("http"):
        return value, None

    parsed = urllib.parse.urlparse(value)
    m = re.search(r"/(?:design|file)/([a-zA-Z0-9]+)", parsed.path)
    if not m:
        die("Could not read a file key out of that URL.")
    node = urllib.parse.parse_qs(parsed.query).get("node-id", [None])[0]
    return m.group(1), node


def normalize_node(node_id):
    """Figma URLs write 2256-7960; the REST API wants 2256:7960."""
    if node_id is None:
        return None
    return node_id.replace("-", ":")


def die(msg):
    sys.stderr.write("error: %s\n" % msg)
    sys.exit(1)


# --------------------------------------------------------------------------
# cache
# --------------------------------------------------------------------------

def cache_path(file_key, node_id, depth):
    safe = (node_id or "FILE").replace(":", "_")
    if depth:
        safe += "__d%s" % depth
    return os.path.join(CACHE, "nodes", file_key, safe + ".json")


def load_cache(path):
    if not os.path.exists(path):
        return None
    with open(path) as fh:
        return json.load(fh)


def save_cache(path, url, payload):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w") as fh:
        json.dump({"_cache": {"fetched_at": time.time(), "url": url},
                   "data": payload}, fh)


def age_of(entry):
    secs = time.time() - entry["_cache"]["fetched_at"]
    if secs < 3600:
        return "%d min ago" % (secs / 60)
    if secs < 86400:
        return "%d hours ago" % (secs / 3600)
    return "%d days ago" % (secs / 86400)


# --------------------------------------------------------------------------
# network
# --------------------------------------------------------------------------

def request(url):
    req = urllib.request.Request(url, headers={"X-Figma-Token": read_token()})
    try:
        with urllib.request.urlopen(req, timeout=60) as resp:
            return json.load(resp)
    except urllib.error.HTTPError as err:
        body = err.read().decode("utf-8", "replace")[:500]
        if err.code == 429:
            retry = err.headers.get("Retry-After")
            extra = ""
            if retry and retry.isdigit():
                extra = " (~%.1f hours)" % (int(retry) / 3600.0)
            sys.stderr.write(
                "Figma rate limit (429). Retry-After: %s%s\n"
                "Nothing was consumed by this run beyond the rejected call. "
                "Do NOT retry in a loop -- export the frame as PNG from the "
                "Figma UI instead, or use a token from a Full/Dev seat.\n"
                % (retry or "unknown", extra))
            sys.exit(2)
        if err.code in (401, 403):
            sys.stderr.write(
                "Figma rejected the token (%d). It may be revoked, or lack "
                "file_content:read scope, or not have access to this file.\n%s\n"
                % (err.code, body))
            sys.exit(3)
        die("HTTP %d from Figma: %s" % (err.code, body))
    except urllib.error.URLError as err:
        die("Network error talking to Figma: %s" % err)


def get_nodes(file_key, node_id, depth=None, force=False, quiet=False):
    """Cached read of /v1/files/:key/nodes (or the whole file when node_id is None)."""
    node_id = normalize_node(node_id)
    path = cache_path(file_key, node_id, depth)

    if not force:
        cached = load_cache(path)
        if cached:
            if not quiet:
                sys.stderr.write("cache hit (%s) %s\n" % (age_of(cached), path))
            return cached["data"]

    if node_id:
        url = "%s/files/%s/nodes?ids=%s" % (API, file_key, urllib.parse.quote(node_id))
    else:
        url = "%s/files/%s" % (API, file_key)
    if depth:
        url += ("&" if "?" in url else "?") + "depth=%d" % depth

    payload = request(url)
    save_cache(path, url, payload)
    if not quiet:
        sys.stderr.write("fetched and cached -> %s\n" % path)
    return payload


def documents(payload):
    """Yield (nodeId, documentNode) for either response shape."""
    if "nodes" in payload:
        for nid, wrapper in payload["nodes"].items():
            if wrapper and wrapper.get("document"):
                yield nid, wrapper["document"]
    elif "document" in payload:
        yield "0:0", payload["document"]


# --------------------------------------------------------------------------
# inspection (keeps huge JSON out of the caller's context)
# --------------------------------------------------------------------------

def box_of(node):
    box = node.get("absoluteBoundingBox") or {}
    if "width" not in box:
        return ""
    return "  %gx%g" % (round(box["width"], 1), round(box["height"], 1))


def print_tree(node, max_depth, depth=0, limit=40):
    label = "%s%s (%s)%s" % ("  " * depth, node.get("name", "?"),
                             node.get("type", "?"), box_of(node))
    if node.get("type") == "TEXT" and node.get("characters"):
        text = node["characters"].replace("\n", " ")[:48]
        label += '  "%s"' % text
    print(label)

    if depth >= max_depth:
        kids = node.get("children") or []
        if kids:
            print("%s  ... %d more children (raise --max-depth)" % ("  " * depth, len(kids)))
        return

    for child in (node.get("children") or [])[:limit]:
        print_tree(child, max_depth, depth + 1, limit)


def walk(node, path=""):
    here = path + "/" + node.get("name", "?")
    yield here, node
    for child in node.get("children") or []:
        for item in walk(child, here):
            yield item


def describe(node):
    print("id:    %s" % node.get("id"))
    print("name:  %s" % node.get("name"))
    print("type:  %s" % node.get("type"))

    box = node.get("absoluteBoundingBox")
    if box:
        print("frame: x=%g y=%g w=%g h=%g" % (box.get("x", 0), box.get("y", 0),
                                              box.get("width", 0), box.get("height", 0)))

    if node.get("layoutMode"):
        print("layout: %s  gap=%s  padding=%s/%s/%s/%s" % (
            node["layoutMode"], node.get("itemSpacing", 0),
            node.get("paddingTop", 0), node.get("paddingRight", 0),
            node.get("paddingBottom", 0), node.get("paddingLeft", 0)))

    radius = node.get("cornerRadius", node.get("rectangleCornerRadii"))
    if radius is not None:
        print("radius: %s" % radius)

    for kind in ("fills", "strokes"):
        for paint in node.get(kind) or []:
            if paint.get("visible") is False:
                continue
            if paint.get("type") == "SOLID":
                color = paint.get("color", {})
                rgba = tuple(int(round(color.get(c, 0) * 255)) for c in ("r", "g", "b"))
                alpha = paint.get("opacity", color.get("a", 1))
                print("%s: #%02X%02X%02X  alpha=%g" % (kind[:-1], rgba[0], rgba[1], rgba[2], alpha))
            else:
                print("%s: %s" % (kind[:-1], paint.get("type")))

    if node.get("strokeWeight") is not None:
        print("strokeWeight: %s" % node["strokeWeight"])

    style = node.get("style") or {}
    if style:
        print("font:  %s %s  size=%s  lineHeight=%s  spacing=%s" % (
            style.get("fontFamily"), style.get("fontWeight"),
            style.get("fontSize"), style.get("lineHeightPx"),
            style.get("letterSpacing")))

    if node.get("characters"):
        print('text:  "%s"' % node["characters"])

    for effect in node.get("effects") or []:
        if effect.get("visible") is False:
            continue
        print("effect: %s radius=%s offset=%s" % (
            effect.get("type"), effect.get("radius"), effect.get("offset")))


# --------------------------------------------------------------------------
# commands
# --------------------------------------------------------------------------

def cmd_fetch(args):
    file_key, url_node = parse_target(args.target)
    node_id = args.node or url_node
    payload = get_nodes(file_key, node_id, args.depth, args.force)

    for nid, doc in documents(payload):
        print("\n%s  %s (%s)%s" % (nid, doc.get("name"), doc.get("type"), box_of(doc)))
        print_tree(doc, max_depth=1)
    print("\nInspect further with: tree / find / node")


def cmd_tree(args):
    file_key, url_node = parse_target(args.target)
    node_id = args.node or url_node
    payload = get_nodes(file_key, node_id, args.depth, False)
    for _, doc in documents(payload):
        print_tree(doc, max_depth=args.max_depth)


def cmd_find(args):
    file_key, url_node = parse_target(args.target)
    payload = get_nodes(file_key, args.node or url_node, args.depth, False)
    needle = args.needle.lower()
    hits = 0
    for _, doc in documents(payload):
        for path, node in walk(doc):
            if needle in node.get("name", "").lower():
                print("%s  %s (%s)%s" % (node.get("id"), path, node.get("type"), box_of(node)))
                hits += 1
    if not hits:
        print("no node name contains %r" % args.needle)


def cmd_node(args):
    file_key, url_node = parse_target(args.target)
    payload = get_nodes(file_key, args.node or url_node, args.depth, False)
    wanted = normalize_node(args.wanted)
    for _, doc in documents(payload):
        for _, node in walk(doc):
            if node.get("id") == wanted:
                describe(node)
                return
    die("node %s is not inside the cached subtree -- fetch its own subtree, or "
        "re-fetch the parent with a larger --depth" % wanted)


def cmd_images(args):
    file_key, url_node = parse_target(args.target)
    ids = [normalize_node(i.strip()) for i in args.ids.split(",") if i.strip()]
    if not ids:
        die("--ids is required")

    out_dir = os.path.join(CACHE, "images", file_key)
    os.makedirs(out_dir, exist_ok=True)

    pending = []
    for nid in ids:
        dest = os.path.join(out_dir, "%s@%gx.%s" % (nid.replace(":", "_"), args.scale, args.format))
        if os.path.exists(dest) and not args.force:
            print("cached  %s" % dest)
        else:
            pending.append((nid, dest))

    if not pending:
        return

    url = "%s/images/%s?ids=%s&format=%s&scale=%g" % (
        API, file_key, urllib.parse.quote(",".join(n for n, _ in pending)),
        args.format, args.scale)
    payload = request(url)

    if payload.get("err"):
        die("Figma could not render those nodes: %s" % payload["err"])

    for nid, dest in pending:
        src = (payload.get("images") or {}).get(nid)
        if not src:
            sys.stderr.write("no render returned for %s\n" % nid)
            continue
        urllib.request.urlretrieve(src, dest)
        print("saved   %s" % dest)


def cmd_status(_args):
    if not os.path.isdir(CACHE):
        print("cache is empty (%s does not exist yet)" % CACHE)
        return

    total = 0
    for base, _dirs, files in os.walk(CACHE):
        for name in sorted(files):
            full = os.path.join(base, name)
            size = os.path.getsize(full)
            total += size
            rel = os.path.relpath(full, ROOT)
            if name.endswith(".json"):
                try:
                    with open(full) as fh:
                        entry = json.load(fh)
                    print("%-64s %7.1f KB  %s" % (rel, size / 1024.0, age_of(entry)))
                    continue
                except (ValueError, KeyError):
                    pass
            print("%-64s %7.1f KB" % (rel, size / 1024.0))
    print("\ntotal: %.1f KB" % (total / 1024.0))


def main():
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = parser.add_subparsers(dest="command")

    def shared(p, node_default=True):
        p.add_argument("target", help="Figma URL or file key")
        if node_default:
            p.add_argument("node", nargs="?", help="node id (defaults to the URL's node-id)")
        p.add_argument("--depth", type=int, help="limit subtree depth when fetching")

    p = sub.add_parser("fetch", help="fetch a node subtree into the cache")
    shared(p)
    p.add_argument("--force", action="store_true", help="bypass the cache and re-fetch")
    p.set_defaults(func=cmd_fetch)

    p = sub.add_parser("tree", help="print the node tree from cache")
    shared(p)
    p.add_argument("--max-depth", type=int, default=3)
    p.set_defaults(func=cmd_tree)

    p = sub.add_parser("find", help="find cached nodes by name")
    shared(p, node_default=False)
    p.add_argument("needle")
    p.add_argument("--node", help="node id (defaults to the URL's node-id)")
    p.set_defaults(func=cmd_find)

    p = sub.add_parser("node", help="print one cached node's visual spec")
    shared(p, node_default=False)
    p.add_argument("wanted", help="node id to describe")
    p.add_argument("--node", help="subtree to look inside (defaults to the URL's node-id)")
    p.set_defaults(func=cmd_node)

    p = sub.add_parser("images", help="render nodes to PNG/SVG, cached on disk")
    p.add_argument("target")
    p.add_argument("--ids", required=True, help="comma-separated node ids")
    p.add_argument("--format", default="png", choices=["png", "svg", "jpg", "pdf"])
    p.add_argument("--scale", type=float, default=2)
    p.add_argument("--force", action="store_true")
    p.set_defaults(func=cmd_images)

    p = sub.add_parser("status", help="list what the cache holds")
    p.set_defaults(func=cmd_status)

    args = parser.parse_args()
    if not args.command:
        parser.print_help()
        sys.exit(1)
    args.func(args)


if __name__ == "__main__":
    main()
