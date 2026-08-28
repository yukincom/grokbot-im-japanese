#!/bin/sh

# User-local installer. It never uses sudo and never writes outside $HOME.
set -u

app_id=ibus-toggle-enja
app_name='英字 ↔ 日本語'

pause_if_requested() {
    if [ "${IBUS_TOGGLE_PAUSE:-0}" = 1 ]; then
        printf '\n%s' 'Enterキーを押すと閉じます: '
        IFS= read -r _pause_answer || true
    fi
}

fail() {
    printf 'ERROR: %s\n' "$1" >&2
    pause_if_requested
    exit 1
}

warn() {
    printf 'WARNING: %s\n' "$1" >&2
}

script_dir=$(CDPATH= cd -P "$(dirname "$0")" 2>/dev/null && pwd) \
    || fail 'インストーラーの場所を取得できませんでした。'

source_script=$script_dir/src/ibus-toggle-enja
source_icon=$script_dir/assets/ibus-toggle-enja.png

[ -f "$source_script" ] || fail "必要なファイルがありません: $source_script"
[ -f "$source_icon" ] || fail "必要なファイルがありません: $source_icon"

data_home=${XDG_DATA_HOME:-$HOME/.local/share}
config_home=${XDG_CONFIG_HOME:-$HOME/.config}
bin_dir=$HOME/.local/bin
applications_dir=$data_home/applications
icons_dir=$data_home/icons

bin_file=$bin_dir/$app_id
desktop_file=$applications_dir/$app_id.desktop
icon_file=$icons_dir/$app_id.png

mkdir -p "$bin_dir" "$applications_dir" "$icons_dir" \
    || fail 'インストール先ディレクトリを作成できませんでした。'

cp "$source_script" "$bin_file" \
    || fail '切り替えスクリプトをコピーできませんでした。'
cp "$source_icon" "$icon_file" \
    || fail 'アイコンをコピーできませんでした。'
chmod 0755 "$bin_file" \
    || fail '切り替えスクリプトへ実行権限を付けられませんでした。'
chmod 0644 "$icon_file" \
    || fail 'アイコンの権限を設定できませんでした。'

{
    printf '%s\n' '[Desktop Entry]'
    printf '%s\n' 'Version=1.0'
    printf '%s\n' 'Type=Application'
    printf 'Name=%s\n' "$app_name"
    printf '%s\n' 'Name[en]=English ↔ Japanese'
    printf '%s\n' 'Comment=IBusのUS英字入力とMozcひらがな入力を切り替えます'
    printf '%s\n' 'Comment[en]=Toggle IBus between US English and Mozc Hiragana'
    printf '%s\n' 'Exec=sh -c "exec \"$HOME/.local/bin/ibus-toggle-enja\""'
    printf 'Icon=%s\n' "$icon_file"
    printf '%s\n' 'Terminal=false'
    printf '%s\n' 'StartupNotify=false'
    printf '%s\n' 'Categories=Utility;'
} > "$desktop_file" || fail 'アプリケーションランチャーを作成できませんでした。'
chmod 0755 "$desktop_file" \
    || fail 'アプリケーションランチャーへ実行権限を付けられませんでした。'

if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$applications_dir" >/dev/null 2>&1 || true
fi

process_is_running() {
    wanted_process=$1
    for comm_file in /proc/[0-9]*/comm; do
        [ -r "$comm_file" ] || continue
        IFS= read -r running_process < "$comm_file" || continue
        [ "$running_process" = "$wanted_process" ] && return 0
    done
    return 1
}

plank_count=0
plank_root=$config_home/plank

if [ -d "$plank_root" ]; then
    for launchers_dir in "$plank_root"/*/launchers; do
        [ -d "$launchers_dir" ] || continue
        {
            printf '%s\n' '[PlankDockItemPreferences]'
            printf 'Launcher=file://%s\n' "$desktop_file"
        } > "$launchers_dir/$app_id.dockitem" || continue
        plank_count=$((plank_count + 1))
    done
fi

if [ "$plank_count" -eq 0 ] && process_is_running plank; then
    launchers_dir=$plank_root/dock1/launchers
    if mkdir -p "$launchers_dir"; then
        {
            printf '%s\n' '[PlankDockItemPreferences]'
            printf 'Launcher=file://%s\n' "$desktop_file"
        } > "$launchers_dir/$app_id.dockitem" \
            && plank_count=1
    fi
fi

desktop_copy=''
if process_is_running xfdesktop; then
    desktop_dir=''
    if command -v xdg-user-dir >/dev/null 2>&1; then
        desktop_dir=$(xdg-user-dir DESKTOP 2>/dev/null || true)
    fi
    if [ -z "$desktop_dir" ]; then
        if [ -d "$HOME/Desktop" ]; then
            desktop_dir=$HOME/Desktop
        elif [ -d "$HOME/デスクトップ" ]; then
            desktop_dir=$HOME/デスクトップ
        fi
    fi

    if [ -n "$desktop_dir" ] && [ -d "$desktop_dir" ]; then
        desktop_copy=$desktop_dir/$app_id.desktop
        if cp "$desktop_file" "$desktop_copy" && chmod 0755 "$desktop_copy"; then
            if command -v gio >/dev/null 2>&1 && command -v sha256sum >/dev/null 2>&1; then
                checksum=$(sha256sum "$desktop_copy" 2>/dev/null || true)
                checksum=${checksum%% *}
                if [ -n "$checksum" ]; then
                    gio set "$desktop_copy" metadata::xfce-exe-checksum "$checksum" \
                        >/dev/null 2>&1 || true
                fi
            fi
        else
            desktop_copy=''
            warn 'デスクトップへのランチャー作成に失敗しました。'
        fi
    fi
fi

printf '\n%s\n' 'IBus EN/JA Toggle をインストールしました。'
printf '  本体: %s\n' "$bin_file"
printf '  アプリ: %s\n' "$desktop_file"
printf '  アイコン: %s\n' "$icon_file"

if [ "$plank_count" -gt 0 ]; then
    printf '  Plank: %s 個のドックへ追加しました。\n' "$plank_count"
fi
if [ -n "$desktop_copy" ]; then
    printf '  デスクトップ: %s\n' "$desktop_copy"
fi

if ! command -v ibus >/dev/null 2>&1; then
    warn 'ibus コマンドが見つかりません。IBusをインストールしてから使用してください。'
elif available_engines=$(ibus list-engine 2>/dev/null); then
    case $available_engines in
        *mozc-on*) : ;;
        *) warn 'mozc-on が見つかりません。ひらがな固定対応の新しいMozcが必要です。' ;;
    esac
fi

printf '%s\n' 'ボタンを押すたびに US英字 ↔ Mozcひらがな が切り替わります。'
pause_if_requested
exit 0
