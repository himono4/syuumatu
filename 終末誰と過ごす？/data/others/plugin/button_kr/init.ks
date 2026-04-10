[iscript]
tyrano.plugin.kag.tag.button_kr = {
    pm: {
        graphic: "", storage: null, target: null, ext: "", name: "",
        x: "", y: "", width: "", height: "", fix: "false", savesnap: "false",
        folder: "image", exp: "", prevar: "", visible: "true", hint: "",
        clickse: "", enterse: "", leavese: "", downse: "",/* clickimg: "", enterimg: "",*/
        auto_next: "yes", role: ""
    },
    start: function(pm) {
        var that = this;
        var target_layer = null;
        if (pm.role !== "") pm.fix = "true";
        if (pm.fix == "false") {
            target_layer = this.kag.layer.getFreeLayer();
            target_layer.css("z-index", 999999);
        }
        else target_layer = this.kag.layer.getLayer("fix");
        var storage_url = "";
        if ($.isHTTP(pm.graphic)) storage_url = pm.graphic;
        else storage_url = "./data/" + pm.folder + "/" + pm.graphic;

        //ボタンのオブジェクト
        var j_button = $("<img />");
        j_button.attr("src", storage_url);
        j_button.css({
            "position": "relative",
            "cursor": "pointer",
            "z-index": 99999999,
        });
        if (pm.visible == "true") j_button.show();
        else j_button.hide();
        //通常、マウスエンター、マウスダウンの三つ分を考慮して、横幅を三倍にする
        if (pm.width !== "") j_button.css("width", parseInt(pm.width) * 3 + "px");
        if (pm.height !== "") j_button.css("height", pm.height + "px");
        //ヒント
        if (pm.hint !== "") j_button.attr({ "title": pm.hint, "alt": pm.hint });

        //ボタン画像の不要部分を隠すためのdiv（レイヤ）
        var $cover = $("<div></div>").css({
            position: "absolute",
            overflow: "hidden",
        });
        //画像のサイズを取得するためのオブジェクト
        var img = new Image();
        //画像ロード出来次第、処理再開
        img.onload = function(){
            //x位置調整
            if (pm.x === "") $cover.css("left", that.kag.stat.locate.x + "px");
            else $cover.css("left", pm.x + "px");
            //y位置調整
            if (pm.y === "") $cover.css("top", that.kag.stat.locate.y + "px");
            else $cover.css("top", pm.y + "px");
            //fixレイヤ判定
            if (pm.fix != "false") $cover.addClass("fixlayer");
            //横幅設定
            if (pm.width !== "") $cover.css("width", pm.width + "px");
            else if(pm.height !== "") $cover.css("width", parseInt(pm.height) / this.height * 3 * this.width + "px");
            else $cover.css("width", parseInt(this.width / 3) + "px");//画像サイズの1/3にする（通常、マウスエンター/ダウン分）
            //縦幅設定
            if (pm.height !== "") $cover.css("height", pm.height + "px");
            else if(pm.width !== "") $cover.css("height", parseInt(pm.width) / this.width * 3 * this.height + "px");
            else $cover.css("height", parseInt(this.height) + "px");
            //nameパラメータのクラスを与える
            $.setName(j_button, pm.name);
            //ボタンにイベントエレメント設定する
            that.kag.event.addEventElement({ "tag": "button", "j_target": j_button, "pm": pm });
            //ボタンにホバー・マウスダウン・クリックのイベントを追加する
            that.setEvent($cover, j_button, pm);
            //画面上にボタンを挿入する
            $cover.append(j_button);
            target_layer.append($cover);
            if (pm.fix == "false") target_layer.show();
            //次へ
            that.kag.ftag.nextOrder();
        };
        img.src = storage_url;
    },
    setEvent: function($cover, j_button, pm) {
        var that = TYRANO;
        (function() {
            var _target = pm.target;
            var _storage = pm.storage;
            var _pm = pm;
            var preexp = that.kag.embScript(pm.preexp);
            var button_clicked = false;
            //マウス関連イベント
            j_button.on({
                mouseenter: function() {
                    //SE鳴らす
                    if (_pm.enterse !== ""){
                        that.kag.ftag.startTag("playse", { "storage": _pm.enterse, "stop": true });
                    }
                    //enter画像（三連の右端）に変更する
                    $(this).css("left", parseInt($(this).width() * -2  / 3) + "px");
                },
                mouseleave: function() {
                    if (_pm.leavese !== ""){
                        that.kag.ftag.startTag("playse", {
                            "storage": _pm.leavese,
                            "stop": true
                        });
                    }
                    //通常画像に戻す
                    $(this).css("left", "0");
                },
                "mousedown": function() {
                    //SE鳴らす
                    if (_pm.downse !== ""){
                        that.kag.ftag.startTag("playse", { "storage": _pm.downse, "stop": true });
                    }
                    //enter画像（三連の中央）に変更する
                    $(this).css("left", parseInt($(this).width() * -1  / 3) + "px");
                },
                "click": function(event) {
                    if (_pm.clickse !== ""){
                        that.kag.ftag.startTag("playse", { "storage": _pm.clickse, "stop": true });
                    }
                    if (button_clicked === true && _pm.fix == "false") return false;
                    if (that.kag.stat.is_strong_stop !== true && _pm.fix == "false") return false;
                    button_clicked = true;
                    if (_pm.exp !== "") that.kag.embScript(_pm.exp, preexp);
                    if (_pm.savesnap == "true") {
                        if (that.kag.stat.is_stop === true) return false;
                        that.kag.menu.snapSave(that.kag.stat.current_message_str);
                    }
                    if (that.kag.layer.layer_event.css("display") == "none" &&
                        that.kag.stat.is_strong_stop !== true) return false;
                    if (_pm.role !== "") {
                        that.kag.stat.is_skip = false;
                        if (_pm.role != "auto") that.kag.ftag.startTag("autostop", {});
                        if (_pm.role == "save" || _pm.role == "menu" || _pm.role == "quicksave" || _pm.role == "sleepgame"){
                            if (that.kag.stat.is_adding_text === true || that.kag.stat.is_wait === true) return false;
                        }
                        switch (_pm.role) {
                            case "save":
                                that.kag.menu.displaySave();
                                break;
                            case "load":
                                that.kag.menu.displayLoad();
                                break;
                            case "window":
                                that.kag.layer.hideMessageLayers();
                                break;
                            case "title":
                                $.confirm($.lang("go_title"),
                                    function() { location.reload(); }, function() { return false; }
                                );
                                break;
                            case "menu":
                                that.kag.menu.showMenu();
                                break;
                            case "skip":
                                that.kag.ftag.startTag("skipstart", {});
                                break;
                            case "backlog":
                                that.kag.menu.displayLog();
                                break;
                            case "fullscreen":
                                that.kag.menu.screenFull();
                                break;
                            case "quicksave":
                                that.kag.menu.setQuickSave();
                                break;
                            case "quickload":
                                that.kag.menu.loadQuickSave();
                                break;
                            case "auto":
                                if (that.kag.stat.is_auto === true) that.kag.ftag.startTag("autostop", {});
                                else that.kag.ftag.startTag("autostart", {});
                                break;
                            case "sleepgame":
                                if (that.kag.tmp.sleep_game !== null) return false;
                                that.kag.tmp.sleep_game = {};
                                that.kag.ftag.startTag("sleepgame", _pm);
                                break;
                        }
                        event.stopPropagation();
                        return false;
                    }
                    that.kag.layer.showEventLayer();
                    if (_pm.role === "" && _pm.fix == "true") {
                        var stack_pm = that.kag.getStack("call");
                        if (stack_pm === null) {
                            if (that.kag.stat.is_strong_stop === true) _pm.auto_next = "stop";
                            else;
                            that.kag.ftag.startTag("call", _pm);
                        }
                        else {
                            that.kag.log("call\u30b9\u30bf\u30c3\u30af\u304c\u6b8b\u3063\u3066\u3044\u308b\u5834\u5408\u3001fix\u30dc\u30bf\u30f3\u306f\u53cd\u5fdc\u3057\u307e\u305b\u3093");
                            that.kag.log(stack_pm);
                            return false;
                        }
                    } else that.kag.ftag.startTag("jump", _pm);
                    if (that.kag.stat.skip_link ==
                        "true") event.stopPropagation();
                    else that.kag.stat.is_skip = false;
                }
            });
        })();
    }
};

TYRANO.kag.ftag.master_tag.button_kr = object(tyrano.plugin.kag.tag.button_kr);
TYRANO.kag.ftag.master_tag.button_kr.kag = TYRANO.kag;

[endscript]
[return]