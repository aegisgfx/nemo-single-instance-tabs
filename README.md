# Nemo Single-Instance Tabs Wrapper

A small wrapper script for Linux Mint / Cinnamon to ensure Nemo opens folders
in **tabs of an existing window** rather than spawning new windows.

---

## Features

- Opens each folder in a **new tab** of the existing Nemo window.
- Defaults to the current working directory if no path is provided.
- Works around Nemo builds that don’t support `--new-tab` or D-Bus methods.

---

## Installation

1. Save the script somewhere, e.g.:

mkdir -p ~/.local/bin

cp nemo_wrapper.sh ~/.local/bin/

chmod +x ~/.local/bin/nemo_wrapper.sh

##  Replace system-wide Nemo command (optional):

sudo ln -sf ~/.local/bin/nemo_wrapper.sh /usr/local/bin/nemo
