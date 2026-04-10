

*start

[cm  ]
[clearfix]
[start_keyconfig]


[bg storage="black.png" time="100"]

;メニューボタンの表示
@showmenubutton

;メッセージウィンドウの設定
[position layer="message0" left=160 top=500 width=1000 height=200 page=fore visible=true]

;文字が表示される領域を調整
[position layer=message0 page=fore margint="45" marginl="50" marginr="70" marginb="60"]


;メッセージウィンドウの表示
@layopt layer=message0 visible=true

;キャラクターの名前が表示される文字領域
[ptext name="chara_name_area" layer="message0" color="white" size=28 bold=true x=180 y=510]

;上記で定義した領域がキャラクターの名前表示であることを宣言（これがないと#の部分でエラーになります）
[chara_config ptext="chara_name_area"]

;このゲームで登場するキャラクターを宣言
;yuko
[chara_new  name="yuko" storage="chara/yuko/ロリ優子(通常).png" jname="優子"  width = 1920 height 1080]
;キャラクターの表情登録
[chara_face name="yuko" face="normal" storage="chara/yuko/ロリ優子(通常).png"]
[chara_face name="yuko" face="a_normal" storage="chara/yuko/優子(通常).png"]


;tomoyuki
[chara_new  name="tomoyuki"  storage="chara/tomoyuki/normal.png" jname="知行" ]

;scene5[n]

A.[n]

認める　を選んだ場合[n]

;【ＢＧＭ　停止】

;【ＢＧＭ：ゆめうつつ】

そうだ。[n]

優子さんはここにいる。[n]

戻ってきてくれたんだ。[n]

もはや疑いようもない。[n]

#知行
「優子さん……」[n]
#
甘えるように呼ぶと、髪を撫でてくれる。[n]

#知行
「本当に、もうどこにもいかない？」[n]
#
#優子
「はい。ずっと一緒ですからね」[n]
#
#知行
「僕、優子さんのこと、好きなんだよ」[n]
#
#優子
「知っています」[n]
#
#知行
「優子さんは、僕のこと、好き？」[n]
#
#優子
「好きですよ」[n]
#
#知行
「どういう意味で、好き？」[n]
#
#優子
「一人の、男性として」[n]
#
それは、ずっと聞きたいと願っていた言葉で……。[n]

;【SE：布団に倒れこむ】

僕はたまらず、優子さんをベッドの上に押し倒した。[n]

#知行
「……それって、こういうことだよ。いいの？」[n]
#
#優子
「確認なんて、いりませんよ」[n]
#
悪戯っぽい口調に、どうしようもなくそそられる。[n]

#知行
「……優子ちゃん」[n]
#
封じていた呼び名とともに、ぼくは優子ちゃんの肌に触れた。[n]

;【画面暗転】

;【背景：黒】

〈エンド１　まやかしに抱かれて〉[n]
