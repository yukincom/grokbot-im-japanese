# GrokBot! I'M JAPANESE!!

> **WHERE'S MY IME!?**

GrokBotの最小Linux環境に、IBusの **US英字 ↔ Mozcひらがな** を切り替えるボタンと、日本語入力が届く専用Chromeを追加します。

## インストール

1. `Code` → `Download ZIP` でダウンロードして展開
2. `Install.desktop` をダブルクリック
3. 警告が出たら `Mark As Secure And Launch`

起動できない場合は、展開したフォルダー内で実行してください。

```sh
sh install.sh
```

通常のXFCEと、`Xfwm4 + Plank` だけの最小環境に対応します。

GrokBotのOS更新でIBusが消えた場合は、次回起動時に `sudo apt-get` で必要パッケージを自動復旧します。インストール先と設定は `$HOME` 以下に残るため、OS部分だけ交換されても再インストールは不要です。

## 使い方

追加された **GrokBot! I'M JAPANESE!!** ボタンを押すたびに切り替わります。

- 英字: `xkb:us::eng`
- 日本語: `mozc-on`

IBusと、`mozc-on`を提供するMozcが必要です。

Chromeでは、追加される **Chrome＋日本語入力（自己修復）** を使用してください。GrokBot標準Chromeとは別プロファイルで起動し、DBus・IBus・Chromeへ同じ入力環境を渡します。引数なしで起動すると `http://127.0.0.1:8080` を開きます。

## OS更新後

基本的には何もしなくて構いません。切り替えボタンまたは専用Chromeを押すと、以下を自動実行します。

1. `ibus`、Mozc、DBusが存在するか確認
2. 消えていた場合だけDebianパッケージを復旧
3. 専用DBus・IBusセッションを再生成
4. Chromeへ `GTK_IM_MODULE=ibus` などを渡して起動

復旧ログは `~/.local/state/grokbot-ime/runtime.log` に保存されます。自動復旧にはGrokBot環境のパスワードなし `sudo` が必要です。

## アンインストール

`Uninstall.desktop` をダブルクリックするか、次を実行します。

```sh
sh uninstall.sh
```

IBusなどのシステムパッケージは削除しません。

## License

[MIT License](LICENSE)
