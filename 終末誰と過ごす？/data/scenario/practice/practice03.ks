;スクリプト講座の練習ファイルを一部抜粋


;復習
適当に背景を表示してください。[p]

;4-1
この文章にルビを振ってください。[p]

;4-2
文字の大きさを変える。[p]

;4-3
文字のデフォルトの大きさを変える。[l][r]
どっかのタイミングで36pxに戻してください。[p]

;4-4 名前ウィンドウを表示
「僕の名前は太郎だよ。ボイスはないよ」[p]

;4-5
;名前ウィンドウを表示したあと文字をインデント
「僕の名前は太郎だよ。indentタグを置くと[r]
文字がインデントされるよ。」[p]


;4-5
別のシナリオに飛んでみる。[p]

;*ジャンプ練習にジャンプするタグを置く

*ジャンプ練習終わり

;4-7-1
選択肢を表示します。[l][r]
赤、青、緑、好きな色はどれ？[p]

;ここに選択肢を表示


;4-7-2
;ラベルを置く
赤を選びました。太陽や血、情熱や怒りなどを連想します。[l][r]
"*選択肢後"にジャンプしてください。[p]

;4-7-3
;ラベルを置く
緑を選びました。森林や山、安らぎや生命力を連想します。[l][r]
"*選択肢後"にジャンプしてください。[p]

;4-7-4
;ラベルを置く
青を選びました。空や海、静寂や知性を連想します。[l][r]
"*選択肢後"にジャンプしてください。[p]

*選択肢後
選択肢の処理が終わりました。[p]

;練習終わり、以下サンプル
[iscript]
var flg01=false;
var flg02=false;
var flg03=false;
var flg04=false;
var flg05=false;
var flg06=false;

var dislike=0;
[endscript]

ルート分岐サンプルです。[p]
あなたが落としたのは何？[p]
[選択肢 text01="金の斧" target01="*金の斧" text02="銀の斧" target02="*銀の斧" text03="木の斧" target03="*木の斧"]

*金の斧
[eval exp="f.flg01=true"]
[jump target="*選択肢2"]

*銀の斧
[eval exp="f.flg02=true"]
[jump target="*選択肢2"]

*木の斧
[eval exp="f.flg03=true"]
[jump target="*選択肢2"]

*選択肢2
もう一つ、あなたが落としたのは何？[p]
[選択肢 text01="金の延べ棒" target01="*金の延べ棒" text02="銀の硬貨" target02="*銀の硬貨" text03="何も落としてない" target03="*何も落としてない"]


*金の延べ棒
[eval exp="f.flg04=true"]
[jump target="*結果"]

*銀の硬貨
[eval exp="f.flg05=true"]
[jump target="*結果"]

*何も落としてない
[eval exp="f.flg06=true"]
[jump target="*結果"]

*結果
回答をまとめます。[p]
[if exp="f.flg01==true"]
あなたは金の斧を落としたんですね。[p]
[eval exp="f.dislike += 2"]
[endif]
[if exp="f.flg02==true"]
あなたは銀の斧を落としたんですね。[p]
[eval exp="f.dislike += 1"]
[endif]
[if exp="f.flg03==true"]
あなたは木の斧を落としたんですね。[p]
[endif]

[if exp="f.flg04==true"]
金の延べ棒も落としたんですね。[p]
[eval exp="f.dislike += 2"]
[endif]

[if exp="f.flg05==true"]
銀の硬貨も落としたんですね。[p]
[eval exp="f.dislike += 1"]
[endif]

[if exp="f.flg06==true"]
他には何も落としていないんですね。[p]
[endif]

………。[p]

[if exp="f.dislike > 2"]
嘘はよくないですよ……？[p]
[elsif exp="f.dislike > 1"]
……まあ、いいでしょう。変に疑うのも良くありませんし。[p]
[else]
素晴らしい。謙虚な方ですね。[p]
[endif]

それでは。[p]


[白]
お疲れさまでした、タイトルに戻ります。[p]


[黒フレーム終わり]
[背景読込DX storage=sky visible=false]
[fadeoutbgm time=2000]
[jump storage=00.ks]


*ジャンプ練習
このメッセージが出たということは、無事飛べたみたいだね。[p]
じゃあ、戻るよ。[p]
[jump target="*ジャンプ練習終わり"]
