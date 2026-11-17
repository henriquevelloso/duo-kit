#!/bin/bash
# Captures both displays of a booted iPhone Duo simulator.
# Usage: capture_displays.sh <simulator-udid> <label> [output-dir]
# Writes <label>-inner.png and <label>-outer.png. The unlit display comes out dark.
set -euo pipefail
UDID="${1:?simulator UDID}"; LABEL="${2:?label, e.g. 03-open-landscape}"; OUT="${3:-.}"
mkdir -p "$OUT"
# The device's own displays are "Display class: 0". The larger one is the inner display.
DISPLAYS="$(xcrun simctl io "$UDID" enumerate | awk '
  /UUID:/ {uuid=$2}
  /Display class:/ {cls=$3}
  /Default width:/ {w=$3}
  /Default height:/ {if (cls == 0) print w*$3, uuid}' | sort -rn)"
INNER="$(echo "$DISPLAYS" | sed -n 1p | awk '{print $2}')"
OUTER="$(echo "$DISPLAYS" | sed -n 2p | awk '{print $2}')"
if [ -z "$INNER" ] || [ -z "$OUTER" ]; then
  echo "This simulator does not report two displays. Is it an iPhone Duo?" >&2
  exit 1
fi
xcrun simctl io "$UDID" screenshot --display="$INNER" "$OUT/$LABEL-inner.png" >/dev/null 2>&1
xcrun simctl io "$UDID" screenshot --display="$OUTER" "$OUT/$LABEL-outer.png" >/dev/null 2>&1
echo "$OUT/$LABEL-inner.png"
echo "$OUT/$LABEL-outer.png"
