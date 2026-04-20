
[cm]

@clearstack
@bg storage ="title.jpg" time=100
@wait time = 200

*start 
[playbgm storage="iwashiro_mikaduki_jelly.mp3"]
[glink x=70 y=580 width=250 color="btn_07_black" text="はじめから" target="gamestart" keyfocus="1"]
[glink x=370 y=580 width="250" color="btn_07_black" text="つづきから" role="load" keyfocus="2"]
[glink x=670 y=580 width=250 role="sleepgame" color="btn_07_black" text="設定" storage="config.ks" keyfocus="3"]
[glink x=970 y=580 width=250 storage="cg.ks" text="エンドリスト" color="btn_07_black" keyfocus=4]

[s]

*gamestart
;一番最初のシナリオファイルへジャンプする
@jump storage="output1.ks"



