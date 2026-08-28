#!/bin/sh

set -eu

repo_dir=$(CDPATH= cd -P "$(dirname "$0")/.." && pwd)
test_root=$(mktemp -d)
trap 'rm -rf "$test_root"' EXIT HUP INT TERM

fake_home=$test_root/home
fake_config=$fake_home/.config
fake_data=$fake_home/.local/share
fake_state=$test_root/ibus-state
fake_path=$repo_dir/tests/fakes:$PATH

mkdir -p "$fake_config/plank/dock1/launchers"
printf '%s\n' 'xkb:us::eng' > "$fake_state"

HOME=$fake_home \
XDG_CONFIG_HOME=$fake_config \
XDG_DATA_HOME=$fake_data \
PATH=$fake_path \
IBUS_FAKE_STATE=$fake_state \
sh "$repo_dir/install.sh"

test -x "$fake_home/.local/bin/ibus-toggle-enja"
test -x "$fake_data/applications/ibus-toggle-enja.desktop"
test -f "$fake_data/icons/ibus-toggle-enja.png"
test -f "$fake_config/plank/dock1/launchers/ibus-toggle-enja.dockitem"

grep -Fq "Icon=$fake_data/icons/ibus-toggle-enja.png" \
    "$fake_data/applications/ibus-toggle-enja.desktop"
grep -Fq "Launcher=file://$fake_data/applications/ibus-toggle-enja.desktop" \
    "$fake_config/plank/dock1/launchers/ibus-toggle-enja.dockitem"

HOME=$fake_home \
PATH=$fake_path \
IBUS_FAKE_STATE=$fake_state \
sh "$fake_home/.local/bin/ibus-toggle-enja"
test "$(sed -n '1p' "$fake_state")" = 'mozc-on'

HOME=$fake_home \
PATH=$fake_path \
IBUS_FAKE_STATE=$fake_state \
sh "$fake_home/.local/bin/ibus-toggle-enja"
test "$(sed -n '1p' "$fake_state")" = 'xkb:us::eng'

HOME=$fake_home \
XDG_CONFIG_HOME=$fake_config \
XDG_DATA_HOME=$fake_data \
sh "$repo_dir/uninstall.sh"

test ! -e "$fake_home/.local/bin/ibus-toggle-enja"
test ! -e "$fake_data/applications/ibus-toggle-enja.desktop"
test ! -e "$fake_data/icons/ibus-toggle-enja.png"
test ! -e "$fake_config/plank/dock1/launchers/ibus-toggle-enja.dockitem"

printf '%s\n' 'All tests passed.'
