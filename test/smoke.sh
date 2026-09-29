#!/usr/bin/env bash
# smoke.sh — guards the two bugs that shipped in 1.1.1 and made the plugin unusable.
# No framework, no network, no Codex quota: run it before every release.
#
#   bash test/smoke.sh
#
# Exit 0 all passed, 1 otherwise.

set -uo pipefail
BIN="$(cd "$(dirname "$0")/../bin" && pwd)"
FAIL=0

ok()   { printf '  ok   %s\n' "$1"; }
bad()  { printf '  FAIL %s\n' "$1"; FAIL=1; }
check(){ if eval "$2"; then ok "$1"; else bad "$1"; fi; }

echo "syntax"
for f in "$BIN"/codex-imagegen "$BIN"/codex-run "$BIN"/codex-models; do
  check "$(basename "$f") parses" "bash -n '$f' 2>/dev/null"
done

# Regression 1 — `codex login status` writes to stderr. A check that pipes it with
# 2>/dev/null greps an empty string and always reports "not logged in", which made
# every command fail for every user. Exit status is the reliable signal.
echo
echo "login precondition"
check "does not grep a stderr-only message through 2>/dev/null" \
  "! grep -q \"login status 2>/dev/null | grep\" '$BIN'/codex-imagegen '$BIN'/codex-run"

if command -v codex >/dev/null 2>&1; then
  EMPTY="$(mktemp -d)"
  # A logged-out CODEX_HOME must be rejected. Guards the inverse bug: `grep -i
  # 'logged in'` also matches "Not logged in", waving a logged-out user through.
  # Capture first: under `pipefail`, `wrapper | grep` would inherit the wrapper's
  # intentional exit 1 and report a false failure.
  OUT="$(CODEX_HOME="$EMPTY" "$BIN/codex-imagegen" "x" "$EMPTY/o.png" 2>&1)"
  if printf '%s' "$OUT" | grep -q 'not logged in'; then
    ok "logged-out CODEX_HOME is rejected"
  else
    bad "logged-out CODEX_HOME was NOT rejected"
  fi
  rm -rf "$EMPTY"
else
  echo "  skip codex CLI not installed"
fi

# Regression 2 — codex's `-i/--image <FILE>...` is variadic, so a bare trailing prompt
# is parsed as one more image filename. Codex then blocks reading the prompt from
# stdin and exits 1. The `--` separator is load-bearing; do not remove it.
echo
echo "prompt separator"
check "codex-imagegen passes the instruction after --" \
  "grep -q 'CMD+=(-- \"\\\$INSTRUCTION\")' '$BIN/codex-imagegen'"
check "codex-run passes the task after --" \
  "grep -q 'CMD+=(-- \"\\\$TASK\")' '$BIN/codex-run'"

# 1.2.0 — the wrappers must default to the newest catalog model, not a
# hard-coded slug that goes stale the next time OpenAI ships a model.
echo
echo "latest model"
check "codex-imagegen defaults to latest" "grep -q 'MODEL=\"\${CODEX_BRIDGE_MODEL:-latest}\"' '$BIN/codex-imagegen'"
check "codex-run defaults to latest" "grep -q 'MODEL=\"\${CODEX_BRIDGE_MODEL:-latest}\"' '$BIN/codex-run'"
check "no hard-coded gpt-5 model in wrappers" "! grep -q 'gpt-5' '$BIN/codex-imagegen' '$BIN/codex-run'"
if command -v codex >/dev/null 2>&1 && codex login status >/dev/null 2>&1; then
  LATEST="$("$BIN/codex-models" --latest 2>/dev/null)"
  if [ -n "$LATEST" ]; then ok "codex-models --latest resolves ($LATEST)"; else bad "codex-models --latest resolved nothing"; fi
else
  echo "  skip codex not installed or not logged in"
fi

echo
if [ "$FAIL" -eq 0 ]; then echo "all passed"; else echo "FAILURES"; fi
exit "$FAIL"
