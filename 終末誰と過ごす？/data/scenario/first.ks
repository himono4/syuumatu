;一番最初に呼び出されるファイル

[title name="tyrano_V6_test"]

[stop_keyconfig]


;ティラノスクリプトが標準で用意している便利なライブラリ群
;コンフィグ、CG、回想モードを使う場合は必須
@call storage="tyrano.ks"

;ゲームで必ず必要な初期化処理はこのファイルに記述するのがオススメ

;マクロを呼ぶ
[call storage="macro.ks" ]


;メッセージボックスは非表示
@layopt layer="message" visible=false

;最初は右下のメニューボタンを非表示にする
[hidemenubutton]


;以下プラグイン

;デバッグ支援プラグイン
;[plugin name=tsex]

;[button_kr] 吉里吉里式の連結画像でボタンホバーとマウスダウンを可能にする
[plugin name="button_kr"]

;wait機能拡張プラグイン
[plugin name="wait_plus"]

;カメラ機能拡張
[plugin name="tempura_camera2"]

;ボイス再生拡張
[plugin name="voiceplay_ex"]

;バックログジャンププラグイン読込
;[plugin name="tyrano-backlog-jump"]

[if exp="sf.minato_t==null"]
[eval exp="sf.minato_t=1"]
[endif]

[if exp="sf.rituki_t==null"]
[eval exp="sf.rituki_t=1"]
[endif]

[if exp="sf.hiro_t==null"]
[eval exp="sf.hiro_t=1"]
[endif]



;タイトル画面へ移動
@jump storage="title.ks"

[s]


