*macro_original
;※独自マクロ集

;メッセージを全画面に切り替え
[macro name="message_s"]
[position layer="message0" left=20 top=40 width=1200 height=660 page=fore visible=true ]
;名前部分のメッセージレイヤ削除
[free name="chara_name_area" layer="message0"]
[endmacro]

;メッセージをセンタリング（終わり方がわからん）
[macro name="text_center"]
[iscript]
$('.message_inner').css('text-align', 'center');
[endscript]
[endmacro]

[macro name="n"]
[p]
[endmacro]

[macro name="w"]
[l]
[endmacro]


[return]