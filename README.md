# IBus EN/JA Toggle

LinuxのIBus入力を、ボタン1つで次の2つに切り替える小さなランチャーです。

- 英字入力: `xkb:us::eng`
- 日本語入力: `mozc-on`（Mozcひらがな固定モード）

通常のXFCEデスクトップに加えて、`Xfwm4 + Plank` だけで構成された最小リモート環境にも対応します。

## かんたんインストール

1. GitHubの `Code` → `Download ZIP` でダウンロードし、ZIPを展開します。
2. `Install.desktop` をダブルクリックします。
3. 警告画面が出たら `Mark As Secure And Launch`（安全なファイルとしてマークして起動）を選びます。

Linuxのセキュリティ仕様により、ダウンロード直後のランチャーには最初の1回だけ確認が出ます。

`Install.desktop` が起動できない環境では、展開したフォルダー内で次を実行します。実行権限の追加は不要です。

```sh
sh install.sh
```

インストーラーは自動的に次を行います。

- ユーザー用アプリケーションメニューへ登録
- `xfdesktop` が動作中ならデスクトップへ登録
- Plankが設定済みなら、ロック中のPlankにもランチャーを直接登録
- PNGアイコンを絶対パスで設定（最小Plank環境の透明アイコン対策）

`sudo`、管理者権限、ネット接続は使いません。

## 使い方

追加された「英字 ↔ 日本語」ボタンを押します。ウィンドウは表示せず、切り替え後すぐ終了します。

現在の状態は次で確認できます。

```sh
ibus engine
```

ボタンを押すたびに `xkb:us::eng` と `mozc-on` が入れ替われば正常です。

## 必要条件

- IBusが起動していること
- `xkb:us::eng` がIBusへ登録されていること
- `mozc-on` がIBusへ登録されていること

`mozc-jp` は選択できてもMozc内部が直接入力のままになる環境があります。本ツールは、毎回ひらがなモードになる `mozc-on` を使用します。`mozc-on` の固定入力モードはMozc 2.28.4950以降で利用できます。

参考: [Mozc公式ドキュメント — Fixed composition mode per engine](https://github.com/google/mozc/blob/master/docs/configurations.md#fixed-composition-mode-per-engine)

確認コマンド:

```sh
ibus list-engine
ibus engine xkb:us::eng
ibus engine mozc-on
```

## インストール先

すべて現在のユーザーのホームディレクトリ内です。

```text
~/.local/bin/ibus-toggle-enja
~/.local/share/applications/ibus-toggle-enja.desktop
~/.local/share/icons/ibus-toggle-enja.png
~/.config/plank/*/launchers/ibus-toggle-enja.dockitem  # Plank使用時のみ
~/Desktop/ibus-toggle-enja.desktop                     # xfdesktop使用時のみ
```

## アンインストール

`Uninstall.desktop` をダブルクリックするか、次を実行します。

```sh
sh uninstall.sh
```

このプロジェクトが作成した上記ファイルだけを削除します。

## トラブルシューティング

### ボタンを押しても何も表示されない

正常な仕様です。入力を切り替えて即終了するため、ウィンドウは開きません。文字を入力するか `ibus engine` で確認してください。

### エンジンは切り替わるが日本語を入力できない

`ibus engine` の表示が `mozc-jp` ではなく `mozc-on` になっているか確認してください。`mozc-on` が存在しない場合はMozcの更新が必要です。

### Plankへドラッグできない

Plankがランチャー変更をロックしていても、インストーラーが `~/.config/plank/*/launchers/` へ直接登録します。セッションによっては表示更新に少し時間がかかります。

### デスクトップ上で右クリックできない

`Xvfb + x11vnc + Xfwm4 + Plank` のようなリモート環境では、通常のXFCEデスクトップ機能がありません。Plankへ自動登録されたボタンを使ってください。

## 開発・テスト

```sh
sh tests/test.sh
```

テストでは一時的なHOMEと偽のIBusを使い、インストール、英字→日本語、日本語→英字、アンインストールを確認します。実際のユーザー設定は変更しません。

## License

[MIT License](LICENSE)
