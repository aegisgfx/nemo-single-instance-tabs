#!/bin/bash
# Installer for Nemo Single-Instance Tabs.
#
#   sudo ./install.sh              install, or update an existing install
#   sudo ./install.sh --uninstall  remove the wrapper, restore stock nemo
#        ./install.sh --check      report whether the installed copy is current
#   sudo ./install.sh --force      replace a /usr/local/bin/nemo we don't own

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
SRC="$SCRIPT_DIR/nemo_wrapper.sh"
TARGET=/usr/local/bin/nemo
REAL_NEMO=/usr/bin/nemo

ACTION=install
FORCE=0

die() {
    printf 'error: %s\n' "$*" >&2
    exit 1
}

info() {
    printf '  %s\n' "$*"
}

usage() {
    sed -n '2,8p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

# Home directory of the user who invoked sudo, so we can point at their legacy
# ~/.local/bin copy rather than root's.
if [ -n "${SUDO_USER:-}" ]; then
    USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6 || true)
else
    USER_HOME=$HOME
fi

for arg in "$@"; do
    case "$arg" in
        -u|--uninstall) ACTION=uninstall ;;
        -c|--check)     ACTION=check ;;
        -f|--force)     FORCE=1 ;;
        -h|--help)      usage; exit 0 ;;
        *)              die "unknown argument: $arg (try --help)" ;;
    esac
done

need_root() {
    [ "$(id -u)" -eq 0 ] || die "needs root: sudo $0 $1"
}

is_ours() {
    [ -f "$1" ] && cmp -s "$1" "$SRC"
}

do_install() {
    need_root
    [ -f "$SRC" ] || die "cannot find $SRC"
    [ -x "$REAL_NEMO" ] || die "$REAL_NEMO not found - is Nemo installed?"

    if [ -L "$TARGET" ]; then
        info "removing old symlink $TARGET -> $(readlink "$TARGET")"
        rm -f "$TARGET"
    elif [ -e "$TARGET" ]; then
        if is_ours "$TARGET"; then
            info "updating existing install of $TARGET"
        elif [ "$FORCE" -eq 1 ]; then
            info "replacing $TARGET (--force)"
        else
            die "$TARGET exists and was not installed from this repo; re-run with --force"
        fi
    fi

    install -m 0755 -o root -g root -- "$SRC" "$TARGET"
    info "installed $TARGET"

    version=$("$TARGET" --version 2>&1 || true)
    [ -n "$version" ] || die "$TARGET did not run - it failed the smoke test"
    info "smoke test ok: $version"

    resolved=$(command -v nemo || true)
    if [ "$resolved" != "$TARGET" ]; then
        printf 'warning: "nemo" resolves to %s, not %s\n' "${resolved:-nothing}" "$TARGET" >&2
        printf '         /usr/local/bin must come before /usr/bin in PATH\n' >&2
    else
        info "\"nemo\" now resolves to $TARGET"
    fi

    if [ -n "$USER_HOME" ] && [ -e "$USER_HOME/.local/bin/nemo_wrapper.sh" ]; then
        printf '\nnote: %s still exists from an older install.\n' \
            "$USER_HOME/.local/bin/nemo_wrapper.sh"
        printf '      It is no longer used; delete it with:\n'
        printf '      rm ~/.local/bin/nemo_wrapper.sh\n'
    fi

    printf '\nDone. Undo with: sudo %s --uninstall\n' "$0"
}

do_uninstall() {
    need_root "--uninstall"

    if [ -L "$TARGET" ]; then
        info "removing symlink $TARGET -> $(readlink "$TARGET")"
        rm -f "$TARGET"
    elif [ -e "$TARGET" ]; then
        if ! is_ours "$TARGET" && [ "$FORCE" -ne 1 ]; then
            die "$TARGET was not installed from this repo; re-run with --force to remove it"
        fi
        rm -f "$TARGET"
        info "removed $TARGET"
    else
        info "$TARGET is not installed"
    fi

    if [ -n "$USER_HOME" ] && [ -e "$USER_HOME/.local/bin/nemo_wrapper.sh" ]; then
        printf '\nnote: %s still exists from an older install.\n' \
            "$USER_HOME/.local/bin/nemo_wrapper.sh"
        printf '      Delete it with: rm ~/.local/bin/nemo_wrapper.sh\n'
    fi

    resolved=$(command -v nemo || true)
    info "stock nemo: ${resolved:-NOT FOUND}"
}

do_check() {
    if [ -L "$TARGET" ]; then
        printf 'symlink: %s -> %s (legacy install, re-run ./install.sh)\n' \
            "$TARGET" "$(readlink "$TARGET")"
        exit 1
    elif is_ours "$TARGET"; then
        printf 'ok: %s matches this repo\n' "$TARGET"
        exit 0
    elif [ -e "$TARGET" ]; then
        printf 'stale: %s exists but differs from %s\n' "$TARGET" "$SRC"
        exit 1
    else
        printf 'missing: %s is not installed\n' "$TARGET"
        exit 1
    fi
}

case "$ACTION" in
    install)   do_install ;;
    uninstall) do_uninstall ;;
    check)     do_check ;;
esac
