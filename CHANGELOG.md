# Changelog

## 2.0.0 - 2026-08-28

- GrokBotのOS再生成でIBus/Mozcが消えた場合のDebian自己修復を追加
- 永続ホーム領域に専用DBus・IBusセッションを再生成するランタイムを追加
- IBus環境を確実に継承する「Chrome＋日本語入力（自己修復）」を追加
- `mozc-on`を優先し、利用できない場合は`mozc-jp`へフォールバック
- Plankへ切り替えボタンと専用Chromeを自動追加

## 1.0.0 - 2026-08-28

- `xkb:us::eng` と `mozc-on` の双方向切り替えを追加
- 通常のアプリケーションメニュー、xfdesktop、Plankへの自動登録に対応
- ロックされたPlankへ `.dockitem` を直接登録する方式に対応
- SVGを表示できない最小Plank環境向けにPNGアイコンを同梱
- ダブルクリック用インストーラーとアンインストーラーを追加
- 隔離HOMEと偽IBusを使う統合テストを追加
