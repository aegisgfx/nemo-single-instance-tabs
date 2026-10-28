# Nemo Single-Instance Tabs

Turns every `nemo` launch into a tab in the existing window instead of a new
window. Written for Linux Mint / Cinnamon, tested on Nemo 6.6.3.

Nemo has no preference for "open launches in the same window", so this installs
a small wrapper as `/usr/local/bin/nemo`, where it shadows `/usr/bin/nemo` and
re-invokes the real binary with the documented `--existing-window -t` flags.

## What it does

- `nemo ~/Downloads` opens `~/Downloads` as a tab in the current window.
- `nemo /usr /etc` opens both, as two tabs, from a single call.
- `nemo` with no arguments opens the **current working directory** as a tab.
- URIs such as `computer:///`, `trash:///` and `file:///…` pass straight through.
- Folder icons on the desktop open as tabs as well, including the special Home
  and Trash icons.
- Options are untouched: `nemo --help`, `--version`, `--quit`, `-n`, `--geometry`
  and `--fix-cache` all behave exactly as before.

The last point matters. Options starting with `-` are forwarded verbatim, so
`sudo nemo --fix-cache` and `nemo --quit` still do the right thing rather than
being guessed at as file paths.

## What it does not do

It only affects launches that go through `exec` of `nemo` via `PATH`: the app
menu, the dock, desktop icons, `xdg-open`, and terminal invocations.

It cannot affect folder opens handled *inside* an already-running Nemo process.
The main example is `org.freedesktop.FileManager1.ShowFolders`, which is what
"open containing folder" in another application calls. That decision is made
below the wrapper, inside Nemo, so only a patch to Nemo itself would reach it.

## Requirements

- Nemo with `/usr/bin/nemo` and the `--existing-window` and `-t` options.
- `bash`.
- Root for install, because it writes to `/usr/local/bin`.

Tested on Nemo 6.6.3 under Cinnamon (Linux Mint). The app menu, the dock,
terminal invocations, and desktop icons — Home, Trash and ordinary folders —
were all verified to open as tabs in the existing window.

## Install

```sh
git clone https://github.com/aegisgfx/nemo-single-instance-tabs.git
cd nemo-single-instance-tabs
sudo ./install.sh
```

The installer removes an old `/usr/local/bin/nemo` symlink if present, copies
the wrapper into place, and runs `nemo --version` as a smoke test. If
`/usr/local/bin/nemo` already exists as a file that was not installed from this
repo, it refuses unless you pass `--force`.

## Verify

```sh
command -v nemo        # should print /usr/local/bin/nemo
nemo --version         # should print the Nemo version, not open a window
nemo /tmp              # should appear as a tab, not a new window
```

## Update

```sh
git pull
sudo ./install.sh
```

`./install.sh --check` reports whether the installed copy matches the repo, so
you can spot drift without root.

## Uninstall

```sh
sudo ./install.sh --uninstall
```

This removes `/usr/local/bin/nemo` and leaves `/usr/bin/nemo` untouched, so no
`dpkg-divert` or package surgery is involved.

**Manual recovery,** if anything ever goes wrong:

```sh
sudo rm /usr/local/bin/nemo
```

Nemo is back to stock immediately. That is the entire rollback.

## Notes

- This is system-wide: every user and root gets the wrapper, not just you.
- The wrapper is a *copy*, not a symlink into your home directory. Editing this
  repo does nothing until you re-run `sudo ./install.sh`, which means a broken
  edit can never leave you without a file manager.
- If you install via `dpkg-divert` instead, the wrapper must point at
  `/usr/bin/nemo.distrib` (the diverted name), not `/usr/bin/nemo`, or it will
  `exec` itself forever. This repo does not use `dpkg-divert`.
- If `~/.local/bin` precedes `/usr/local/bin` in your `PATH` and contains a file
  named `nemo`, that one wins over this wrapper. The installer warns if `nemo`
  does not resolve to `/usr/local/bin/nemo`.

## License

See [LICENSE](LICENSE).
