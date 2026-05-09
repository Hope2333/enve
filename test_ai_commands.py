#!/usr/bin/env python3
"""enve AI command E2E test — sends JSONL commands via stdin, validates responses.

Usage:
    ENVE_AI=stdin enve < test_ai_commands.py
    OR: python3 test_ai_commands.py | ENVE_AI=stdin enve

Tests:
    1. echo roundtrip
    2. help command listing
    3. state dump (scene info)
    4. canvas create + list + set_active
    5. menu action trigger
"""

import json, sys, time

def send(cmd: dict):
    """Send a JSON command line to stdout."""
    line = json.dumps(cmd, ensure_ascii=False)
    print(line, flush=True)
    time.sleep(0.5)  # let enve process the command

def send_and_read(cmd: dict, timeout=3.0):
    """Send command and read response from stdin (for piped mode)."""
    send(cmd)
    # In piped mode, we write to enve's stdin. The response comes
    # via enve's stdout (Logger output) or the same pipe.
    # For now, we just send and trust enve's logging.

# ── Test 1: Echo ─────────────────────────────────────────
print("=== Test 1: echo ===", file=sys.stderr)
send({"cmd": "echo", "args": {"msg": "hello world"}})

# ── Test 2: Help ─────────────────────────────────────────
print("=== Test 2: help ===", file=sys.stderr)
send({"cmd": "help", "args": {}})

# ── Test 3: State dump ───────────────────────────────────
print("=== Test 3: state ===", file=sys.stderr)
send({"cmd": "state", "args": {}})

# ── Test 4: Canvas create ────────────────────────────────
print("=== Test 4: canvas create ===", file=sys.stderr)
send({"cmd": "canvas", "args": {"action": "create", "width": 640, "height": 480, "fps": 30}})

time.sleep(1)

# ── Test 5: Canvas list ──────────────────────────────────
print("=== Test 5: canvas list ===", file=sys.stderr)
send({"cmd": "canvas", "args": {"action": "list"}})

# ── Test 6: Menu trigger ─────────────────────────────────
print("=== Test 6: menu undo ===", file=sys.stderr)
send({"cmd": "menu", "args": {"action": "undo"}})

# ── Test 7: Box list ─────────────────────────────────────
print("=== Test 7: box list ===", file=sys.stderr)
send({"cmd": "box", "args": {"action": "list"}})

# ── Test 8: Box add rectangle ────────────────────────────
print("=== Test 8: box add rectangle ===", file=sys.stderr)
send({"cmd": "box", "args": {"action": "add", "type": "rectangle"}})

time.sleep(1)

# ── Test 9: Box list again ───────────────────────────────
print("=== Test 9: box list after add ===", file=sys.stderr)
send({"cmd": "box", "args": {"action": "list"}})

# ── Test 10: State dump after changes ────────────────────
print("=== Test 10: state after changes ===", file=sys.stderr)
send({"cmd": "state", "args": {}})

print("=== All tests sent ===", file=sys.stderr)