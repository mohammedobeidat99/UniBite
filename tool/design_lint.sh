#!/usr/bin/env bash
# UniBite Design System Linter
# Enforces zero raw color literals, zero stock Colors.* outside design_system/

set -e

echo "=== UniBite Design Linter ==="

FAILURES=0

# Check for stock Colors.* usage outside design_system and tests
echo "1. Checking for raw Colors.* usage outside design_system..."
RAW_COLORS=$(grep -rn "Colors\." lib/ | grep -v "lib/core/design_system/" | grep -v "Colors.transparent" || true)
if [ -n "$RAW_COLORS" ]; then
  echo "[FAIL] Found unauthorized Colors.* usage:"
  echo "$RAW_COLORS"
  FAILURES=$((FAILURES + 1))
else
  echo "[PASS] No unauthorized stock Colors.* found."
fi

# Check for raw Color(0x...) hex literals outside design_system
echo "2. Checking for raw Color(0x...) hex literals outside design_system..."
RAW_HEX=$(grep -rn "Color(0x" lib/ | grep -v "lib/core/design_system/" || true)
if [ -n "$RAW_HEX" ]; then
  echo "[FAIL] Found unauthorized raw Color(0x...) literals:"
  echo "$RAW_HEX"
  FAILURES=$((FAILURES + 1))
else
  echo "[PASS] No raw hex Color literals found."
fi

# Check for LinearProgressIndicator usage (strict circular requirement)
echo "3. Checking for LinearProgressIndicator (must be circular AppLoader)..."
LINEAR_LOADERS=$(grep -rn "LinearProgressIndicator" lib/ || true)
if [ -n "$LINEAR_LOADERS" ]; then
  echo "[FAIL] Found LinearProgressIndicator usage (only circular AppLoader permitted):"
  echo "$LINEAR_LOADERS"
  FAILURES=$((FAILURES + 1))
else
  echo "[PASS] All progress indicators adhere to circular standard."
fi

if [ "$FAILURES" -gt 0 ]; then
  echo "=== Design lint FAILED with $FAILURES issues ==="
  exit 1
fi

echo "=== Design lint PASSED (100% token compliant) ==="
exit 0
