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
fake_runtime=$repo_dir/tests/fakes/runtime

mkdir -p "$fake_config/plank/dock1/launchers" "$fake_home/.local/bin" \
    "$fake_data/applications" "$fake_data/icons" "$fake_home/bin"
printf '%s\n' 'xkb:us::eng' > "$fake_state"
for legacy_id in grokbot-ime-toggle ime-toggle; do
    : > "$fake_home/.local/bin/$legacy_id"
    : > "$fake_data/applications/$legacy_id.desktop"
    : > "$fake_data/icons/$legacy_id.png"
    : > "$fake_config/plank/dock1/launchers/$legacy_id.dockitem"
done
: > "$fake_home/bin/ime-toggle"

HOME=$fake_home \
XDG_CONFIG_HOME=$fake_config \
XDG_DATA_HOME=$fake_data \
PATH=$fake_path \
IBUS_FAKE_STATE=$fake_state \
GROKBOT_IME_SKIP_RUNTIME_CHECK=1 \
sh "$repo_dir/install.sh"

test -x "$fake_home/.local/bin/ibus-toggle-enja"
test -x "$fake_home/.local/bin/grokbot-ime-chrome"
test -x "$fake_home/.local/libexec/grokbot-ime/runtime"
test -x "$fake_data/applications/ibus-toggle-enja.desktop"
test -x "$fake_data/applications/grokbot-ime-chrome.desktop"
test -f "$fake_data/icons/ibus-toggle-enja.png"
test -f "$fake_config/plank/dock1/launchers/ibus-toggle-enja.dockitem"
test -f "$fake_config/plank/dock1/launchers/grokbot-ime-chrome.dockitem"
test ! -e "$fake_home/.local/bin/grokbot-ime-toggle"
test ! -e "$fake_data/applications/grokbot-ime-toggle.desktop"
test ! -e "$fake_config/plank/dock1/launchers/grokbot-ime-toggle.dockitem"
test ! -e "$fake_data/applications/ime-toggle.desktop"
test ! -e "$fake_config/plank/dock1/launchers/ime-toggle.dockitem"
test ! -e "$fake_home/bin/ime-toggle"

grep -Fq "Icon=$fake_data/icons/ibus-toggle-enja.png" \
    "$fake_data/applications/ibus-toggle-enja.desktop"
grep -Fq "Launcher=file://$fake_data/applications/ibus-toggle-enja.desktop" \
    "$fake_config/plank/dock1/launchers/ibus-toggle-enja.dockitem"
grep -Fq "Launcher=file://$fake_data/applications/grokbot-ime-chrome.desktop" \
    "$fake_config/plank/dock1/launchers/grokbot-ime-chrome.dockitem"
grep -Fq 'Icon=google-chrome' "$fake_data/applications/grokbot-ime-chrome.desktop"

HOME=$fake_home \
PATH=$fake_path \
IBUS_FAKE_STATE=$fake_state \
IBUS_FAKE_SWITCH_EXIT=1 \
GROKBOT_IME_RUNTIME=$fake_runtime \
sh "$fake_home/.local/bin/ibus-toggle-enja"
test "$(sed -n '1p' "$fake_state")" = 'mozc-on'

HOME=$fake_home \
PATH=$fake_path \
IBUS_FAKE_STATE=$fake_state \
GROKBOT_IME_RUNTIME=$fake_runtime \
sh "$fake_home/.local/bin/ibus-toggle-enja"
test "$(sed -n '1p' "$fake_state")" = 'xkb:us::eng'

fake_cache=$fake_home/.cache
fake_session=$fake_cache/grokbot-ime/session.env
browser_state=$test_root/browser-state
mkdir -p "$(dirname "$fake_session")"
{
    printf '%s\n' 'DBUS_SESSION_BUS_ADDRESS=unix:path=/tmp/test-dbus'
    printf '%s\n' 'IBUS_ADDRESS=unix:path=/tmp/test-ibus'
    printf '%s\n' 'GROKBOT_JAPANESE_ENGINE=mozc-on'
} > "$fake_session"

HOME=$fake_home \
XDG_CACHE_HOME=$fake_cache \
XDG_DATA_HOME=$fake_data \
GROKBOT_IME_RUNTIME=$fake_runtime \
GROKBOT_IME_BROWSER=$repo_dir/tests/fakes/browser \
GROKBOT_BROWSER_STATE=$browser_state \
sh "$fake_home/.local/bin/grokbot-ime-chrome" http://127.0.0.1:8080/test

grep -Fq 'GTK_IM_MODULE=ibus' "$browser_state"
grep -Fq 'QT_IM_MODULE=ibus' "$browser_state"
grep -Fq 'XMODIFIERS=@im=ibus' "$browser_state"
grep -Fq 'DBUS_SESSION_BUS_ADDRESS=unix:path=/tmp/test-dbus' "$browser_state"
grep -Fq 'ARG=--class=grokbot-ime-chrome' "$browser_state"
grep -Fq 'ARG=http://127.0.0.1:8080/test' "$browser_state"

runtime_home=$test_root/runtime-home
runtime_cache=$runtime_home/cache
runtime_state=$runtime_home/state
runtime_ibus_state=$runtime_home/ibus-state
runtime_ready=$runtime_home/ibus-ready
mkdir -p "$runtime_home"
printf '%s\n' 'xkb:us::eng' > "$runtime_ibus_state"

HOME=$runtime_home \
XDG_CACHE_HOME=$runtime_cache \
XDG_STATE_HOME=$runtime_state \
PATH=$fake_path \
IBUS_FAKE_STATE=$runtime_ibus_state \
IBUS_FAKE_READY_FILE=$runtime_ready \
GROKBOT_IME_MOZC_BINARY=$repo_dir/tests/fakes/mozc-binary \
GROKBOT_IME_DISABLE_REPAIR=1 \
sh "$repo_dir/src/grokbot-ime-runtime" ensure

grep -Fq 'DBUS_SESSION_BUS_ADDRESS=unix:path=/tmp/fake-dbus' \
    "$runtime_cache/grokbot-ime/session.env"
grep -Fq 'IBUS_ADDRESS=unix:path=/tmp/fake-ibus' \
    "$runtime_cache/grokbot-ime/session.env"
grep -Fq 'GROKBOT_JAPANESE_ENGINE=mozc-on' \
    "$runtime_cache/grokbot-ime/session.env"

HOME=$fake_home \
XDG_CONFIG_HOME=$fake_config \
XDG_DATA_HOME=$fake_data \
sh "$repo_dir/uninstall.sh"

test ! -e "$fake_home/.local/bin/ibus-toggle-enja"
test ! -e "$fake_home/.local/bin/grokbot-ime-chrome"
test ! -e "$fake_home/.local/libexec/grokbot-ime/runtime"
test ! -e "$fake_data/applications/ibus-toggle-enja.desktop"
test ! -e "$fake_data/applications/grokbot-ime-chrome.desktop"
test ! -e "$fake_data/icons/ibus-toggle-enja.png"
test ! -e "$fake_config/plank/dock1/launchers/ibus-toggle-enja.dockitem"
test ! -e "$fake_config/plank/dock1/launchers/grokbot-ime-chrome.dockitem"

printf '%s\n' 'All tests passed.'
