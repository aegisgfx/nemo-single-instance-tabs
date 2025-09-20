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

URIS=()
for target in "${TARGETS[@]}"; do
    case "$target" in
        computer://*|computer|computer:)
            URIS+=("computer:///")
            ;;
        network://*|network|network:)
            URIS+=("network:///")
            ;;
        trash://*|trash|trash:)
            URIS+=("trash:///")
            ;;
        *)
            # Normal filesystem path → convert to absolute file:// URI
            ABS_PATH=$(realpath "$target")
            URIS+=("file://$ABS_PATH")
            ;;
    esac
done

# Open each as its own tab in the existing window
for uri in "${URIS[@]}"; do
    "$NEMO_BIN" --existing-window -t "$uri"
done

