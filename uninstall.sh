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
desktop_file=$data_home/applications/$app_id.desktop
icon_file=$data_home/icons/$app_id.png

rm -f "$bin_file" "$desktop_file" "$icon_file"

plank_root=$config_home/plank
if [ -d "$plank_root" ]; then
    for dock_dir in "$plank_root"/*; do
        [ -d "$dock_dir/launchers" ] || continue
        rm -f "$dock_dir/launchers/$app_id.dockitem"
    done
fi

for desktop_dir in "$HOME/Desktop" "$HOME/デスクトップ"; do
    [ -d "$desktop_dir" ] || continue
    rm -f "$desktop_dir/$app_id.desktop"
done

printf '%s\n' "GrokBot! I'M JAPANESE!! を現在のユーザーから削除しました。"
pause_if_requested
exit 0
