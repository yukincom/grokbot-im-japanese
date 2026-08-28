#!/bin/sh

# Remove only files installed by this project from the current user account.
set -u

app_id=ibus-toggle-enja

pause_if_requested() {
    if [ "${IBUS_TOGGLE_PAUSE:-0}" = 1 ]; then
        printf '\n%s' 'Enterキーを押すと閉じます: '
        IFS= read -r _pause_answer || true
    fi
}

data_home=${XDG_DATA_HOME:-$HOME/.local/share}
config_home=${XDG_CONFIG_HOME:-$HOME/.config}

bin_file=$HOME/.local/bin/$app_id
runtime_dir=$HOME/.local/libexec/grokbot-ime
runtime_file=$runtime_dir/runtime
desktop_file=$data_home/applications/$app_id.desktop
icon_file=$data_home/icons/$app_id.png
chrome_id=grokbot-ime-chrome
chrome_bin_file=$HOME/.local/bin/$chrome_id
chrome_desktop_file=$data_home/applications/$chrome_id.desktop

rm -f "$bin_file" "$chrome_bin_file" "$runtime_file" \
    "$desktop_file" "$chrome_desktop_file" "$icon_file"
for legacy_id in grokbot-ime-toggle ime-toggle; do
    rm -f "$HOME/.local/bin/$legacy_id" \
        "$data_home/applications/$legacy_id.desktop" \
        "$data_home/icons/$legacy_id.png"
done
rm -f "$HOME/bin/ime-toggle"
rmdir "$runtime_dir" 2>/dev/null || true

plank_root=$config_home/plank
if [ -d "$plank_root" ]; then
    for dock_dir in "$plank_root"/*; do
        [ -d "$dock_dir/launchers" ] || continue
        rm -f "$dock_dir/launchers/$app_id.dockitem" \
            "$dock_dir/launchers/$chrome_id.dockitem" \
            "$dock_dir/launchers/grokbot-ime-toggle.dockitem" \
            "$dock_dir/launchers/ime-toggle.dockitem"
    done
fi

for desktop_dir in "$HOME/Desktop" "$HOME/デスクトップ"; do
    [ -d "$desktop_dir" ] || continue
    rm -f "$desktop_dir/$app_id.desktop" "$desktop_dir/$chrome_id.desktop"
done

printf '%s\n' "GrokBot! I'M JAPANESE!! を現在のユーザーから削除しました。"
pause_if_requested
exit 0
