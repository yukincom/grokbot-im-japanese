#!/bin/sh

# Installed files stay under $HOME. Missing Debian packages may be repaired with sudo.
set -u

app_id=ibus-toggle-enja
app_name="GrokBot! I'M JAPANESE!!"

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
source_runtime=$script_dir/src/grokbot-ime-runtime
source_chrome=$script_dir/src/grokbot-ime-chrome
source_icon=$script_dir/assets/ibus-toggle-enja.png

[ -f "$source_script" ] || fail "必要なファイルがありません: $source_script"
[ -f "$source_runtime" ] || fail "必要なファイルがありません: $source_runtime"
[ -f "$source_chrome" ] || fail "必要なファイルがありません: $source_chrome"
[ -f "$source_icon" ] || fail "必要なファイルがありません: $source_icon"

data_home=${XDG_DATA_HOME:-$HOME/.local/share}
config_home=${XDG_CONFIG_HOME:-$HOME/.config}
bin_dir=$HOME/.local/bin
libexec_dir=$HOME/.local/libexec/grokbot-ime
applications_dir=$data_home/applications
icons_dir=$data_home/icons

bin_file=$bin_dir/$app_id
desktop_file=$applications_dir/$app_id.desktop
icon_file=$icons_dir/$app_id.png
runtime_file=$libexec_dir/runtime
chrome_id=grokbot-ime-chrome
chrome_bin_file=$bin_dir/$chrome_id
chrome_desktop_file=$applications_dir/$chrome_id.desktop

mkdir -p "$bin_dir" "$libexec_dir" "$applications_dir" "$icons_dir" \
    || fail 'インストール先ディレクトリを作成できませんでした。'

cp "$source_script" "$bin_file" \
    || fail '切り替えスクリプトをコピーできませんでした。'
cp "$source_runtime" "$runtime_file" \
    || fail '自己修復ランタイムをコピーできませんでした。'
cp "$source_chrome" "$chrome_bin_file" \
    || fail '日本語対応Chromeランチャーをコピーできませんでした。'
cp "$source_icon" "$icon_file" \
    || fail 'アイコンをコピーできませんでした。'
chmod 0755 "$bin_file" "$runtime_file" "$chrome_bin_file" \
    || fail '実行ファイルへ実行権限を付けられませんでした。'
chmod 0644 "$icon_file" \
    || fail 'アイコンの権限を設定できませんでした。'

{
    printf '%s\n' '[Desktop Entry]'
    printf '%s\n' 'Version=1.0'
    printf '%s\n' 'Type=Application'
    printf 'Name=%s\n' "$app_name"
    printf '%s\n' "Comment=WHERE'S MY IME!? US英字入力とMozcひらがな入力を切り替えます"
    printf '%s\n' "Comment[en]=WHERE'S MY IME!? Toggle US English and Mozc Hiragana"
    printf '%s\n' 'Exec=sh -c "exec \"$HOME/.local/bin/ibus-toggle-enja\""'
    printf 'Icon=%s\n' "$icon_file"
    printf '%s\n' 'Terminal=false'
    printf '%s\n' 'StartupNotify=false'
    printf '%s\n' 'Categories=Utility;'
} > "$desktop_file" || fail 'アプリケーションランチャーを作成できませんでした。'
chmod 0755 "$desktop_file" \
    || fail 'アプリケーションランチャーへ実行権限を付けられませんでした。'

{
    printf '%s\n' '[Desktop Entry]'
    printf '%s\n' 'Version=1.0'
    printf '%s\n' 'Type=Application'
    printf '%s\n' 'Name=Chrome + Japanese IME'
    printf '%s\n' 'Name[ja]=Chrome＋日本語入力（自己修復）'
    printf '%s\n' 'Comment=Start a private D-Bus/IBus session and open Chrome'
    printf '%s\n' 'Comment[ja]=IBusを必要なら復旧し、日本語入力が届く専用Chromeを開きます'
    printf '%s\n' 'Exec=sh -c "exec \"$HOME/.local/bin/grokbot-ime-chrome\""'
    printf 'Icon=%s\n' "$icon_file"
    printf '%s\n' 'Terminal=false'
    printf '%s\n' 'StartupNotify=false'
    printf '%s\n' 'StartupWMClass=grokbot-ime-chrome'
    printf '%s\n' 'Categories=Network;WebBrowser;Utility;'
} > "$chrome_desktop_file" || fail '日本語対応Chromeのランチャーを作成できませんでした。'
chmod 0755 "$chrome_desktop_file" \
    || fail '日本語対応Chromeランチャーへ実行権限を付けられませんでした。'

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
        {
            printf '%s\n' '[PlankDockItemPreferences]'
            printf 'Launcher=file://%s\n' "$chrome_desktop_file"
        } > "$launchers_dir/$chrome_id.dockitem" || continue
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
        {
            printf '%s\n' '[PlankDockItemPreferences]'
            printf 'Launcher=file://%s\n' "$chrome_desktop_file"
        } > "$launchers_dir/$chrome_id.dockitem" || true
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

printf '\n%s\n' "GrokBot! I'M JAPANESE!! をインストールしました。"
printf '  本体: %s\n' "$bin_file"
printf '  自己修復: %s\n' "$runtime_file"
printf '  Chrome: %s\n' "$chrome_desktop_file"
printf '  アプリ: %s\n' "$desktop_file"
printf '  アイコン: %s\n' "$icon_file"

if [ "$plank_count" -gt 0 ]; then
    printf '  Plank: %s 個のドックへ追加しました。\n' "$plank_count"
fi
if [ -n "$desktop_copy" ]; then
    printf '  デスクトップ: %s\n' "$desktop_copy"
fi

if [ "${GROKBOT_IME_SKIP_RUNTIME_CHECK:-0}" != 1 ]; then
    printf '%s\n' 'IBus/Mozcと専用セッションを確認しています…'
    if ! "$runtime_file" ensure; then
        warn "自動復旧に失敗しました。ログ: ${XDG_STATE_HOME:-$HOME/.local/state}/grokbot-ime/runtime.log"
    fi
fi

printf '%s\n' 'ボタンを押すたびに US英字 ↔ Mozcひらがな が切り替わります。'
printf '%s\n' 'Chromeでは「Chrome＋日本語入力（自己修復）」を使用してください。'
pause_if_requested
exit 0
