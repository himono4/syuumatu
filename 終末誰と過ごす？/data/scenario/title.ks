
[cm]

@clearstack
@bg storage ="title.jpg" time=100
@wait time = 200

*start 

[button x=150 y=580 graphic="title/button_start.png" enterimg="title/button_start2.png"  target="gamestart" keyfocus="1"]
[button x=450 y=580 graphic="title/button_load.png" enterimg="title/button_load2.png" role="load" keyfocus="2"]
[button x=750 y=580 graphic="title/button_config.png" enterimg="title/button_config2.png" role="sleepgame" storage="config.ks" keyfocus="5"]

[s]

*gamestart
;一番最初のシナリオファイルへジャンプする
@jump storage="output1.ks"



