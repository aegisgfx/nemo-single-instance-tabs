#!/bin/bash
# Wrapper script for Nemo: always open in an existing window as new tabs.

set -e

NEMO_BIN="/usr/bin/nemo"

# If no args given, default to current working dir
if [ "$#" -eq 0 ]; then
    TARGETS=("$PWD")
else
    TARGETS=("$@")
fi

# Convert each target to absolute file:// URI
URIS=()
for target in "${TARGETS[@]}"; do
    ABS_PATH=$(realpath "$target")
    URIS+=("file://$ABS_PATH")
done

# Open each as its own tab in the existing window
for uri in "${URIS[@]}"; do
    "$NEMO_BIN" --existing-window -t "$uri"
done

