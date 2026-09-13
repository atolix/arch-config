# Quickshell bar

Hyprland用の小さな上部バー。設定はこのリポジトリ内で管理します。

- 左: 電源メニュー、フォーカス中のアプリ名
- 中央: 日付と時計（システムのローカルタイム）
- 時計クリック: 日曜始まりの英語カレンダー。前月・翌月の移動、「Today」で今月に戻る
- 左端の電源アイコン: Lock / Suspend / Reboot / Shutdown
- 右: 音量 / バッテリー / Wi-Fi・有線接続
- 音量: スクロールで5%ずつ変更、右クリックでミュート、左クリックで音量パネル
- バーの音量は状態に応じたスピーカーアイコン。隣の電球は明るさに応じて周囲の光線が連続的に伸縮。クリックで明るさOSDを表示
- 音量アイコンは0%で波なし、低（1〜33%）で波1本、中（34〜66%）で2本、高（67〜100%）で3本。ミュート時は×印を表示
- バッテリーはアイコン左に残量パーセントを表示。内部ゲージは残量に応じて連続的に増減し、外枠とゲージは角丸。30%以下は黄、15%以下は赤、充電中は緑
- Wi-Fiは接続中のSSIDを表示。有線接続時は`eth: connected`、切断時は`net: offline`
- 明るさキー操作は即時反映。それ以外の変更も約2秒間隔で取得
- 音量パネル: 0〜100%のスライダー、Mute / Unmute切り替え。外側クリックか「Close」で終了
- 全モニターに表示。バッテリーがない場合は非表示
- 音量・明るさキー: 画面下中央に英語OSDを1.8秒表示。連打で表示時間を延長

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

## 音量・明るさOSD

`brightnessctl`と`wpctl`（wireplumber）が必要です。
Hyprlandの既存の音量・明るさキー設定を以下の1行に置き換えます。
この環境では設定済みです。

```ini
source = /home/atolix/development/quickshell-bar/hyprland-osd.conf
```

音量は2%刻み（上限100%）、明るさは10%刻み（最小値1）。
ミュートキーにも対応します。Quickshell停止中も音量・明るさの操作は機能します。
OSDは全モニターに表示し、フォーカスやクリックを奪いません。
スライダー操作ではOSDを出さず、ハードウェアキーから呼び出します。
配置先を変更した場合は、このsource行と`hyprland-osd.conf`内のパスを変更してください。

値を変えずに表示を試すには:

```sh
./scripts/osd-control.py volume show
./scripts/osd-control.py brightness show
```

## 自動起動

`~/.config/hypr/hyprland.conf` は以下の設定へ切り替え済みです。

```ini
exec-once = /home/atolix/development/quickshell-bar/run.sh --no-duplicate --daemonize
```

次のログインからQuickshellが自動起動します。戻すときは `exec-once = waybar` に戻します。
別のユーザー・配置先ではパスを変更してください。

## ファイル

- `shell.qml`: 配置、アプリ名、時計、PipeWire音量、UPowerバッテリー
- `BarText.qml`: 共通のフォント・文字色
- `BrightnessIcon.qml`: 明るさに合わせて光線が伸縮する電球アイコン
- `VolumeIcon.qml`: 音量に合わせて0〜3本の波を描くスピーカーアイコン
- `BatteryIcon.qml`: 角丸の残量ゲージと充電状態を描くバッテリーアイコン
- `VolumePopup.qml`: PipeWireと連動する音量スライダー
- `CalendarPopup.qml`: 今日の強調表示と月移動ができるカレンダー
- `PowerPopup.qml`: ロック・サスペンド・再起動・シャットダウンのメニュー
- `Osd.qml`: 音量・明るさの一時表示
- `hyprland-osd.conf`: OSDと連動するハードウェアキー設定
- `scripts/osd-control.py`: 音量・明るさを操作してOSDへ通知
- `scripts/metrics.py`: /procとnmcliから2秒間隔で統計を取得
- `run.sh`: 配置先を基準に起動

ネットワーク情報を取得できない場合は `net: —` を表示します。
フォントはJetBrainsMono、背景は元のWaybarに合わせた半透明の黒です。
明るさ/ネットワーク取得は全モニターで1つのプロセスを共有します。

参考: [Quickshell公式ガイド](https://quickshell.org/docs/guide/introduction/)
