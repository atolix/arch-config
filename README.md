# Quickshell bar

Hyprland用の小さな上部バー。設定はこのリポジトリ内で管理します。

- 左: フォーカス中のアプリ名
- 中央: 日付と時計（システムのローカルタイム）
- 時計クリック: 日曜始まりのカレンダー。前月・翌月の移動、「今日」で今月に戻る
- 右: CPU / メモリ / 音量 / バッテリー / Wi-Fi・有線接続
- 音量: スクロールで5%ずつ変更、右クリックでミュート、左クリックで音量パネル
- 音量パネル: 0〜100%のスライダー、ミュート切り替え。外側クリックか「閉じる」で終了
- 全モニターに表示。バッテリーがない場合は非表示

## 起動

Arch Linuxの依存パッケージ:

```sh
sudo pacman -S --needed quickshell python networkmanager upower pavucontrol
```

PipeWireとNetworkManagerが動作しているWaylandセッションで起動:

```sh
cd ~/development/quickshell-bar
./run.sh
```

Waybarが動いている場合はバーが2本になります。試用中は別のターミナルで
`pkill -SIGUSR1 waybar` を実行すると表示を切り替えられます。
QuickshellはCtrl+Cで終了。同じコマンドでWaybarを再表示できます。
QMLの変更は保存すると自動反映されます。

## 自動起動へ切り替える場合

`~/.config/hypr/hyprland.conf` の `exec-once = waybar` を以下に置き換えます。

```ini
exec-once = /home/atolix/development/quickshell-bar/run.sh
```

次のログインから有効です。戻すときは `exec-once = waybar` に戻します。
別のユーザー・配置先ではパスを変更してください。

## ファイル

- `shell.qml`: 配置、アプリ名、時計、PipeWire音量、UPowerバッテリー
- `BarText.qml`: 共通のフォント・文字色
- `VolumePopup.qml`: PipeWireと連動する音量スライダー
- `CalendarPopup.qml`: 今日の強調表示と月移動ができるカレンダー
- `scripts/metrics.py`: /procとnmcliから2秒間隔で統計を取得
- `run.sh`: 配置先を基準に起動

ネットワーク情報を取得できない場合は `net: —` を表示します。
フォントはJetBrainsMono、背景は元のWaybarに合わせた半透明の黒です。
CPU/メモリ/ネットワーク取得は全モニターで1つのプロセスを共有します。

参考: [Quickshell公式ガイド](https://quickshell.org/docs/guide/introduction/)
