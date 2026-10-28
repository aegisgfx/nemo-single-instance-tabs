#!/bin/bash
# Nemo Single-Instance Tabs.
#
# Installed as /usr/local/bin/nemo so that it shadows /usr/bin/nemo and every
# launch of "nemo" lands in a tab of the existing window.
#
# Nemo has no preference for "always open launches in the same window", so the
# only thing this does is re-invoke the real binary with the documented
# --existing-window -t flags.

REAL_NEMO=/usr/bin/nemo

if [ ! -x "$REAL_NEMO" ]; then
    echo "nemo-tabs: $REAL_NEMO is missing or not executable" >&2
    exit 127
fi

# Options are none of our business. --help, --version, --quit, --fix-cache,
# --geometry, -n, --no-desktop … all get forwarded with the command line intact.
for arg in "$@"; do
    case "$arg" in
        -*) exec "$REAL_NEMO" "$@" ;;
    esac
done

# No operands: keep the historical behaviour of using the caller's directory.
[ "$#" -eq 0 ] && set -- "$PWD"

# Nemo accepts plain paths and URIs alike, so pass operands through untouched.
# No file:// rewriting: that avoids realpath() following symlinks and avoids
# %-encoding damage to paths containing '%'.
exec "$REAL_NEMO" --existing-window -t "$@"
