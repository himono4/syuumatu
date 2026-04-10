【ボイス再生機能拡張プラグイン】


■できること
・ボイス連動アニメーション
再生中の音声の音量に応じて口パク等のアニメーションを行います。
キャラクター差分パーツ機能と一緒に使います。
複数パーツの同時アニメーションには対応していません。

・ボイス再生中のBGM音量変更
ボイス再生中のBGM音量を変更できます。

・ボイスリピートボタン表示
ゲーム画面にボイスをリピート再生するボタンを表示します。

・バックログボイスリピートボタン表示
バックログ画面でボイスをリピート再生するボタンを表示します。

・ボイスファイル連番をゼロ埋め
ボイス自動再生用のボイスファイルの連番部分を「0001」のようにゼロ埋めで指定できるようにします。


■使い方
このテキストが入っているフォルダごと「data/others/plugin」フォルダに置きます。
それからfirst.ksとかに以下のように記述してください。
記述した時点から後述のタグが使用可能になります。

[plugin name=voiceplay_ex]
指定可能属性
len：ボイスファイル名の連番桁数を指定（「voice_0001.mp3」なら「4」を指定）

記述例）
[plugin name=voiceplay_ex len=4]

それから、make.ksに以下のタグを記述してください。
[voiceplay_ex_restore]


■使用可能タグ
vlanim_set：アニメーション定義開始
属性：
name（必須）：アニメーションさせるキャラクター名を指定します。
part（必須）：アニメーションさせるパーツ名を指定します。
id（必須）  ：アニメーションさせるパーツIDを指定します。

vlanim_frame：各フレーム定義
属性：
storage（必須）：パーツ画像のパスを指定します。画像はfgimageフォルダ下に配置します。
vol（必須）    ：パーツ画像を切り替える音量の下限値を数値で指定します。

vlanim_set_end：アニメーション定義終了
属性：
なし

vlanim_config：アニメーション設定
属性：
speed       ：画像を切り替える速度を指定します。単位はミリ秒です。初期値は50です。
bgm_volume  ：ボイス再生中にBGM音量を変更する場合は音量を指定します。

vrepeat_config：ボイスリピートボタン設定
属性：
graphic     ：再生ボタンの画像を指定します。画像はimageフォルダ下に配置します。
x（必須）   ：再生ボタンの横位置を指定します。単位はピクセルです。
y（必須）   ：再生ボタンの縦位置を指定します。単位はピクセルです。

vrepeat：ボイスリピートボタン表示
属性：
name    ：発言者のnameを指定します。無指定の場合、現在の発言者となります。また、現在の発言者（[chara_ptext]に指定された名前）が空白の場合はボイスを再生しません。
num     ：ボイスのnumberを指定します。無指定の場合、直前のnumberとなります。
graphic ：再生ボタンの画像を個別に指定します。画像はimageフォルダ下に配置します。無指定の場合、vrepeat_configで指定したものになります。
x       ：再生ボタンの横位置を個別に指定します。単位はピクセルです。無指定の場合、vrepeat_configで指定したものになります。
y       ：再生ボタンの縦位置を個別に指定します。単位はピクセルです。無指定の場合、vrepeat_configで指定したものになります。

vrepeat_delete：ボイスリピートボタン消去
属性：
なし

logrepeat_config：バックログのボイスリピートボタン設定
属性：
img：ボイスを再生するボタンの画像パスを指定します。画像はimageフォルダ下に配置します。
element（必須）：ボイスを再生するボタンを配置する要素を指定します。cssのセレクタ記法が使用できます。
insert：elementで指定した要素のどこにボタンを追加するかを指定します。before（要素の前）, after（要素の後）, intobefore（要素の中の先頭）, intoafter（要素の中の最後尾）, self（要素自体）のいずれかを指定

voiceplay_ex_restore：make.ks記述用
属性：
なし


■使用例
;キャラクター定義
[chara_new name=akane storage="chara/akane/body/body.png" jname="あかね"]
[chara_layer name=akane part=brow id=normal storage="chara/akane/brow/futsu.png"]
（中略）
;アニメーション定義
[vlanim_set name=akane part=mouth id=normal]
[vlanim_frame vol=5 storage="chara/akane/mouth/futsu_toji.png"]
[vlanim_frame vol=40 storage="chara/akane/mouth/futsu_aki.png"]
[vlanim_set_end]

;ボイス再生開始
[voconfig name=akane sebuf=1 vostorage="voice_{number}.mp3"]
[vostart]

;ボイスリピートボタン設定
[vrepeat_config graphic="button_voice.png" x=400 y=500]

#akane
;発言開始直前にリピートボタン表示
[vrepeat]
なにかのセリフ

;改ページのタイミングでリピートボタン消去
[p]
[vrepeat_delete]


■使うときのコツ
・発言者をボイス再生バッファで判定しているので、ボイス再生バッファはキャラクターごとに分けてください。
・アニメーション定義するときは、4コマのアニメであれば音量設定は以下のように指定するといい感じになります。
1コマ目（閉じ）     音量：5
2コマ目（半開1）    音量：10
3コマ目（半開2）    音量：20
4コマ目（開き）     音量：40
閉じ画像の音量を0に指定すると、ほぼボイスなし（だけどごく小さい音が出ている）のときに口が半開きになってしまうことがあるので、最下限音量は5くらいを指定するとちょうどいいです。
全体的に音量指定は少し小さいかな？くらいの値を入れてもそれほど違和感はないと思います。

・[vrepeat]タグは発言するキャラ名の後に記述します。

・[logrepeat_config]タグのelement属性には、ボイス再生ボタンを表示する前または後の要素をセレクタ記法で指定します。
　セレクタ記法については「css セレクタ 書き方」とかでググってください。
　例えば以下のようなDOM構成の場合↓
<b class="backlog_chara_name キャラ名">キャラ名</b>：
<span class="backlog_text キャラ名">セリフ</span>

①このように記述すると↓
[logrepeat_config img="button/voice.png" element=".backlog_chara_name" insert="after"]

①こうなります↓
<b class="backlog_chara_name キャラ名">キャラ名</b>
<img src="./data/image/button/voice.png" class="backlog_chara_name backlog_repeat">：
<span class="backlog_text キャラ名">セリフ</span>

②このように記述すると↓
[logrepeat_config img="button/voice.png" element=".backlog_chara_name" insert="intoafter"]

②こうなります↓
<b class="backlog_chara_name キャラ名">キャラ名
<img src="./data/image/button/voice.png" class="backlog_chara_name backlog_repeat"></b>：
<span class="backlog_text キャラ名">セリフ</span>

③このように記述すると↓
[logrepeat_config img="button/voice.png" element=".backlog_chara_name" insert="self"]

③こうなります↓
<b class="backlog_chara_name キャラ名">キャラ名</b>：
<span class="backlog_text キャラ名">セリフ</span>
※insert="self"を指定した場合、element属性で指定した要素自身がリピートボタンの役割を持ちます。


■ライセンス
このプラグインはMITライセンスです。
©2023 さくた@skt_tyrano
原文：https://opensource.org/licenses/mit-license.php
和訳：https://licenses.opensource.jp/MIT/MIT.html


■注意事項
開発中の仮公開版となります。
このプラグインを使用したことで生じたあらゆる問題について、製作者は責任を負いません。
不具合報告等は歓迎しております。制作者Twitterまでどうぞ。


■製作者
さくた（@skt_tyrano）
https://skskpnt.app


■更新履歴
2024/04/30  ver.0.3.4α公開
・バックログ画面でのボイスリピートで、バックログを開いた時点のvostorageを参照する不具合を修正

2023/06/04  ver.0.3.3α公開
・バックログ画面にボイスリピートボタンが表示されない不具合を修正

2023/03/12  ver.0.3.2α公開
・[playbgm]タグにsprite_timeを指定した場合に進行不能になる不具合を修正

2022/12/08  ver.0.3.1α公開
・諸々バグ修正

2022/10/30  ver.0.3.0α公開
・v520対応、v514以前との互換性なし
・logrepeatタグ廃止
・logrepeat_configタグ追加
・stopbgm関連バグ修正

2022/05/22  ver.0.2.0α公開
・音量設定が0の場合でも口パクするように修正
・ボイス再生中のBGM音量を変更できる機能を追加

2022/02/11  ver.0.1.2α公開
・ロード時にループ効果音が再生されない不具合を修正

2021/12/04  ver.0.1.1α公開
・アニメーションしないパーツを指定していた場合にアニメーションが動かないよう修正

2021/01/15  ver.0.1α公開
・仮公開