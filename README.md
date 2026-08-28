# GrokBot! I'M JAPANESE!!

> **WHERE'S MY IME!?**

GrokBotの最小Linux環境に、IBusの **US英字 ↔ Mozcひらがな** を切り替えるボタンを追加します。

## インストール

1. `Code` → `Download ZIP` でダウンロードして展開
2. `Install.desktop` をダブルクリック
3. 警告が出たら `Mark As Secure And Launch`

起動できない場合は、展開したフォルダー内で実行してください。

```sh
sh install.sh
```

`sudo` は不要です。通常のXFCEと、`Xfwm4 + Plank` だけの最小環境に対応します。

## 使い方

追加された **GrokBot! I'M JAPANESE!!** ボタンを押すたびに切り替わります。

- 英字: `xkb:us::eng`
- 日本語: `mozc-on`

IBusと、`mozc-on`を提供するMozcが必要です。

## アンインストール

`Uninstall.desktop` をダブルクリックするか、次を実行します。

```sh
sh uninstall.sh
```

## License

[MIT License](LICENSE)
