//諸々の関数の置き換えやバックログジャンプ用の変数定義
(function () {

  tyrano.plugin.kag.tmp.orukred = {
    backlogJump: {
      saveFile: [],//バックログジャンプに使うセーブデータの配列。最大保持数はconfig.tjsのbacklogNumに依存。
      isCanBacklogJumpText: true,//バックログジャンプができるテキストであるかどうか。基本的にtrueで、バックログにのみ表示するテキストでだけfalse
      pushSaveFile(pushData) {	//saveFileへの値追加。
        //データの挿入
        this.saveFile.push(pushData);
        //tyrano.plugin.kag.config.maxBackLogNumで指定した数を超えたら古いものから削除。
        if (tyrano.plugin.kag.config.maxBackLogNum < this.saveFile.length) {
          this.saveFile.shift();
        }

      }
    }
  };
  let _p = tyrano.plugin.kag.tag.p
  let _kag = tyrano.plugin.kag.ftag.master_tag.p.kag
  tyrano.plugin.kag.tag.p = $.extend(true, {}, _p, {
    start: function () {


      //追加箇所start------------------------------------------------
      // this.kag.menu.snapSave("backlogJump", function () { });
      // TYRANO.kag.ftag.startTag("savesnap", { title: "backlogJump" });
      //追加箇所end------------------------------------------------
      var that = this;

      //改ページ
      this.kag.stat.flag_ref_page = true;

      this.kag.stat.is_click_text = false;
      this.kag.ftag.showNextImg();

      if (this.kag.stat.is_skip == true) {
        //スキップ中の場合は、nextorder
        this.kag.ftag.nextOrder();
      } else if (this.kag.stat.is_auto == true) {
        this.kag.stat.is_wait_auto = true;

        var auto_speed = that.kag.config.autoSpeed;
        if (that.kag.config.autoSpeedWithText != "0") {
          var cnt_text = this.kag.stat.current_message_str.length;
          auto_speed = parseInt(auto_speed) + parseInt(that.kag.config.autoSpeedWithText) * cnt_text;
        }

        setTimeout(function () {
          if (that.kag.stat.is_wait_auto == true) {
            //ボイス再生中の場合は、オートで次に行かない。効果音再生終了後に進めるためのフラグを立てる
            if (that.kag.tmp.is_vo_play == true) {
              that.kag.tmp.is_vo_play_wait = true;
            } else {
              that.kag.ftag.nextOrder();
            }
          }
        }, auto_speed);
      }

      if (!this.kag.stat.is_skip) {
        this.kag.waitClick("p");
      }


    },
  });
  tyrano.plugin.kag.ftag.master_tag.p = tyrano.plugin.kag.tag.p
  tyrano.plugin.kag.ftag.master_tag.p.kag = _kag

  tyrano.plugin.kag.tag.pushlog = {
    vital: ["text"],

    pm: {
      text: "",
      join: "false",
    },

    start: function (pm) {
      if (pm.join == "true") {
        this.kag.pushBackLog(pm.text, "join");
      } else {
        //追加箇所start------------------------------------------------
        tyrano.plugin.kag.tmp.orukred.backlogJump.isCanBacklogJumpText = false;
        this.kag.pushBackLog(pm.text, "add");
        tyrano.plugin.kag.tmp.orukred.backlogJump.isCanBacklogJumpText = true;
        //追加箇所end------------------------------------------------
      }

      this.kag.ftag.nextOrder();
    },
  };


  tyrano.plugin.kag.tag.text.pushTextToBackLog = function (chara_name, message_str) {
    // ひとつ前のログに連結させるべきかどうか
    // たとえば[r][font][delay]などのタグを通過したあとは連結が有効になる
    var should_join_log = this.kag.stat.log_join == "true";

    // バックログへの追加
    if ((chara_name != "" && !should_join_log) || (chara_name != "" && this.kag.stat.f_chara_ptext == "true")) {
      // バックログにキャラ名を新しく書き出す場合
      //追加箇所start------------------------------------------------
      const log_str = tyrano.plugin.kag.tmp.orukred.backlogJump.isCanBacklogJumpText ?
        `<b class="backlog_chara_name ${chara_name}">${chara_name}</b>：` + `<span class="backlog_text canBacklogJump ${chara_name}">${message_str}</span>` :
        `<b class="backlog_chara_name ${chara_name}">${chara_name}</b>：` + `<span class="backlog_text ${chara_name}">${message_str}</span>`;
      //追加箇所end------------------------------------------------
      this.kag.pushBackLog(log_str, "add");

      if (this.kag.stat.f_chara_ptext == "true") {
        this.kag.stat.f_chara_ptext = "false";
        this.kag.stat.log_join = "true";
      }
    } else {
      // バックログにキャラ名を新しく書き出す必要がない場合
      // const log_str = `<span class="backlog_text ${chara_name}">${message_str}</span>`;
      //追加箇所start------------------------------------------------
      const log_str = tyrano.plugin.kag.tmp.orukred.backlogJump.isCanBacklogJumpText ?
        `<span class="backlog_text canBacklogJump ${chara_name}">${message_str}</span>` :
        `<span class="backlog_text ${chara_name}">${message_str}</span>`;
      //追加箇所end------------------------------------------------
      const join_type = should_join_log ? "join" : "add";
      this.kag.pushBackLog(log_str, join_type);
    }
  };


  //追加箇所start（optionsへのデフォルト引数を追加）------------------------------------------------
  tyrano.plugin.kag.menu.loadGameData = function (data, options, isDeleteBacklog = true) {
    //追加箇所end------------------------------------------------
    const that = this;

    // ロードを始める前にイベントレイヤを非表示にする
    this.kag.layer.hideEventLayer();

    // ティラノイベント"load-start"を発火
    this.kag.trigger("load-start");

    // 一時リスナをすべて消去
    this.kag.offTempListeners();

    //普通のロードの場合
    if (typeof options == "undefined") {
      options = { bgm_over: "false" };
    } else if (typeof options.bgm_over == "undefined") {
      options["bgm_over"] = "false";
    }


    //追加箇所start------------------------------------------------
    if (isDeleteBacklog) {
      this.kag.variable.tf.system.backlog = [];
      tyrano.plugin.kag.tmp.orukred.backlogJump.saveFile = [];
    }
    //追加箇所end------------------------------------------------

    /**
     * make.ks を通過してもとの場所に戻ってきたときに次のタグに進むかどうかを制御する文字列。
     * 通常はもちろん "no" (進まない) だが、タグを進めるべきケースがいくつかある。
     *
     * 1. オートセーブデータをロードした場合
     * 2. [showmenu] で開いたセーブメニューからセーブしたデータをロードした場合
     * 3. [wait] 中にセーブしたデータを読み込んだ場合
     *
     * 3.は通常ではありえないが、一応考慮。
     */
    var auto_next = "no";
    if (options.auto_next) {
      auto_next = options.auto_next;
    }

    //Live2Dモデルがある場合の後始末
    if (typeof Live2Dcanvas != "undefined") {
      for (let model_id in Live2Dcanvas) {
        if (Live2Dcanvas[model_id]) {
          Live2Dcanvas[model_id].check_delete = 2;
          Live2D.deleteBuffer(Live2Dcanvas[model_id].modelno);
          delete Live2Dcanvas[model_id];
        }
      }
    }

    // BGMを引き継がないタイプのロード(通常のロード)の場合、
    // いま再生されているすべてのBGMとSEを止める
    if (options.bgm_over == "false") {
      // 全BGM停止
      var map_bgm = this.kag.tmp.map_bgm;
      for (let key in map_bgm) {
        this.kag.ftag.startTag("stopbgm", {
          stop: "true",
          buf: key,
        });
      }

      // 全SE停止
      var map_se = this.kag.tmp.map_se;
      for (let key in map_se) {
        if (map_se[key]) {
          this.kag.ftag.startTag("stopse", {
            stop: "true",
            buf: key,
          });
        }
      }
    }

    //
    // レイヤー構造(DOM)の復元
    //

    this.kag.layer.setLayerHtml(data.layer);

    // グラデーションテキストの復元
    $(".gradient-text").restoreGradientText();

    // 一時要素をすべて削除
    $(".temp-element").remove();

    //バックログの初期化
    //awakegame考慮もれ。一旦戻す
    //this.kag.variable.tf.system.backlog = [];

    //
    // ステータスの更新
    //

    this.kag.stat = data.stat;

    // [s] で止まっているセーブデータを読み込んだ場合はロード後次のタグに進めるべきではない
    if (this.kag.stat.is_strong_stop) {
      auto_next = "stop";
    }

    // [wait] で止まっているデータを読み込んだ場合(通常ありえない)はロード後次のタグに進めるべきだ
    if (this.kag.stat.is_wait) {
      auto_next = "yes";
    }

    //タイトルの復元
    this.kag.setTitle(this.kag.stat.title);

    // BGMを引き継がないタイプのロード(通常のロード)の場合、
    // さっきすべてのBGMとSEを止めてしまったから、
    // 現在のステータスに記憶されているBGMとループSEを改めて再生する
    if (options.bgm_over == "false") {
      // BGM
      if (this.kag.stat.current_bgm != "") {
        var mstorage = this.kag.stat.current_bgm;

        var pm = {
          loop: "true",
          storage: mstorage,
          html5: this.kag.stat.current_bgm_html5,
          stop: "true",
          can_ignore: "false",
        };

        //ボリュームが設定されいる場合
        if (this.kag.stat.current_bgm_vol != "") {
          pm["volume"] = this.kag.stat.current_bgm_vol;
        }

        if (this.kag.stat.current_bgm_pause_seek != "") {
          pm["pause"] = "true";
          pm["seek"] = this.kag.stat.current_bgm_pause_seek;
        }

        if (this.kag.stat.current_bgm_base64 != "") {
          pm["base64"] = this.kag.stat.current_bgm_base64;
        }

        this.kag.ftag.startTag("playbgm", pm);


      }

      // ループSE
      for (const key in this.kag.stat.current_se) {
        var pm_obj = this.kag.stat.current_se[key];
        pm_obj.can_ignore = "false";
        pm_obj["stop"] = "true";
        this.kag.ftag.startTag("playbgm", pm_obj);
      }

    }

    //読み込んだCSSがある場合
    $("head").find("._tyrano_cssload_tag").remove();
    if (this.kag.stat.cssload) {
      for (let file in this.kag.stat.cssload) {
        var style =
          '<link class="_tyrano_cssload_tag" rel="stylesheet" href="' +
          $.escapeHTML(file) +
          "?" +
          Math.floor(Math.random() * 10000000) +
          '">';
        const j_style = $(style);
        $("head link:last").after(j_style);
        if (this.kag.config["keyFocusWithHoverStyle"] === "true") {
          j_style.on("load", () => {
            $.copyHoverCSSToFocusCSS(j_style);
          });
        }
      }
    } else {
      this.kag.stat.cssload = {};
    }

    if (!this.kag.stat.current_bgmovie) {
      this.kag.stat.current_bgmovie = {
        storage: "",
        volume: "",
      };
    }

    //カメラ設定を復旧 ///////////////
    if (this.kag.config.useCamera == "true") {
      $(".layer_camera").css({
        "-animation-name": "",
        "-animation-duration": "",
        "-animation-play-state": "",
        "-animation-delay": "",
        "-animation-iteration-count": "",
        "-animation-direction": "",
        "-animation-fill-mode": "",
        "-animation-timing-function": "",
      });

      for (let key in this.kag.stat.current_camera) {
        var a3d_define = {
          frames: {
            "0%": {
              trans: this.kag.stat.current_camera[key],
            },
            "100%": {
              trans: this.kag.stat.current_camera[key],
            },
          },

          config: {
            duration: "5ms",
            state: "running",
            easing: "ease",
          },

          complete: function () {
            //特に処理なし
          },
        };

        //アニメーションの実行
        if (key == "layer_camera") {

          $(".layer_camera").css("-webkit-transform-origin", "center center");
          (function (_a3d_define) {
            setTimeout(function () {
              $(".layer_camera").a3d(a3d_define);
            }, 1);
          })(a3d_define);

        } else {

          $("." + key + "_fore").css("-webkit-transform-origin", "center center");
          (function (_a3d_define) {
            setTimeout(function () {
              $("." + key + "_fore").a3d(_a3d_define);
            }, 1);
          })(a3d_define);

        }
      }
    }
    ///////////カメラここまで

    //どの道動画削除。
    $(".tyrano_base").find("video").remove();
    this.kag.tmp.video_playing = false;

    //背景動画が設定中なら
    if (this.kag.stat.current_bgmovie["storage"] != "") {
      const vstorage = this.kag.stat.current_bgmovie["storage"];
      const volume = this.kag.stat.current_bgmovie["volume"];
      const pm = {
        storage: vstorage,
        volume: volume,
        stop: "true",
      };
      this.kag.tmp.video_playing = false;
      this.kag.ftag.startTag("bgmovie", pm);
    }

    //カメラが設定中なら
    if (this.kag.stat.current_bgcamera != "") {
      this.kag.stat.current_bgcamera["stop"] = "true";
      this.kag.ftag.startTag("bgcamera", this.kag.stat.current_bgcamera);
    }

    //3Dモデルの復元/////////////////////////////////////////////
    var three = data.three;
    if (three.stat.is_load == true) {
      this.kag.stronglyStop();
      var init_pm = three.stat.init_pm;

      this.kag.ftag.startTag("3d_close", {});

      //setTimeout((e)=>{

      init_pm["next"] = "false";
      this.kag.ftag.startTag("3d_init", init_pm);

      var models = three.models;

      var scene_pm = three.stat.scene_pm;
      scene_pm["next"] = "false";

      this.kag.ftag.startTag("3d_scene", scene_pm);

      for (var key in models) {
        const model = models[key];
        const pm = model.pm;

        pm["pos"] = model.pos;
        pm["rot"] = model.rot;
        pm["scale"] = model.scale;
        pm["_load"] = "true";

        var tag = pm._tag;

        if (key == "camera") {
          tag = "3d_camera";
        }

        pm["next"] = "false";

        this.kag.ftag.startTag(tag, pm);
      }

      //ジャイロの復元
      var gyro = three.stat.gyro;
      if (gyro.enable == 1) {
        //復活させる。
        var gyro_pm = gyro.pm;
        gyro_pm["next"] = "false";
        this.kag.ftag.startTag("3d_gyro", gyro_pm);
      }

      if (three.stat.canvas_show) {
        this.kag.tmp.three.j_canvas.show();
      } else {
        this.kag.tmp.three.j_canvas.hide();
      }

      this.kag.tmp.three.stat = three.stat;
      this.kag.tmp.three.evt = three.evt;

      //イベントが再開できるかどうか。

      this.kag.cancelStrongStop();

      //},10);
    }

    /////////////////////////////////////////////

    //カーソルの復元
    this.kag.getTag("cursor").restore();

    //フォーカスの復元
    this.kag.restoreFocusable();

    //クリック待ちグリフの復元
    this.kag.ftag.restoreNextImg();

    //メニューボタンの状態
    if (this.kag.stat.visible_menu_button == true) {
      $(".button_menu").show();
    } else {
      $(".button_menu").hide();
    }

    //イベントの復元
    $(".event-setting-element").each(function () {
      var j_elm = $(this);
      var tag_name = j_elm.attr("data-event-tag");
      var pm = JSON.parse(j_elm.attr("data-event-pm"));
      that.kag.getTag(tag_name).setEvent(j_elm, pm);
    });

    //
    // プロパティの初期化
    //

    // 一時変数(tf)は消す
    // ※ this.kag.tmp に影響はない
    this.kag.clearTmpVariable();

    // ロード直後なのだから、セーブ時の状態がどうであったにせよいまはアニメーションスタック数はゼロであるべき
    // ウェイト状態やトランス待機状態であるはずもない
    this.kag.tmp.num_anim = 0;
    this.kag.stat.is_wait = false;
    this.kag.stat.is_stop = false;

    //
    // make.ksを通過してからもとのシナリオファイル＋タグインデックスに戻る処理
    //

    const next = () => {
      // ティラノイベント"load-beforemaking"を発火
      this.kag.trigger("load-beforemaking");

      // make.ks を挿入する
      const insert = {
        name: "call",
        pm: {
          storage: "make.ks",
          auto_next: auto_next,
        },
        val: "",
      };

      this.kag.ftag.nextOrderWithIndex(data.current_order_index, data.stat.current_scenario, true, insert, "yes");
    };

    // make.ks に行く前にプリロードをする必要があるものはこの配列にぶち込んでいく
    const preload_targets = [];

    // [xanim]用に読み込んだ<svg>の復元
    if (this.kag.stat.hidden_svg_list) {
      const j_hidden_area = this.kag.getHiddenArea();
      for (const item of this.kag.stat.hidden_svg_list) {
        switch (typeof item) {
          case "string": {
            const file_path = item;
            // すでに存在しているならスキップ
            if (document.getElementById(file_path)) {
              // $("#" + item) だとjQueryがセレクタの構文エラーを吐いてくるので pure javascript を使う
              continue;
            }
            // 存在していない！
            preload_targets.push((callback) => {
              $.get(file_path, (xml) => {
                $(xml).find("svg").attr("id", file_path).appendTo(j_hidden_area);
                callback();
              });
            });
            break;
          }
        }
      }
    }

    // [xanim]の無限ループアニメーションの復元
    const restoreXanim = () => {
      // [xanim]の復元対象
      $(".set-xanim-restore").each(function () {
        const j_this = $(this);
        const pm = JSON.parse(j_this.attr("data-event-pm"));
        const initial_css_map = JSON.parse(j_this.attr("data-effect"));
        j_this.css(initial_css_map);
        pm.delay = "0";
        pm.next = "false";
        that.kag.getTag("xanim").start(pm);
      });
    };

    // プリロードが必要ないなら即実行
    if (preload_targets.length === 0) {
      restoreXanim();
      next();
      return;
    }

    // あと何個プリロードする必要があるか
    // プリロードが完了するたびにデクリメント、これが0になったらプリロード完了
    let preload_targets_count_left = preload_targets.length;

    // プリロード1個完了処理
    const complete_preload_one = () => {
      preload_targets_count_left -= 1;
      if (preload_targets_count_left === 0) {
        // console.warn("complete preload!");
        restoreXanim();
        next();
      }
    };

    // プリロード開始
    for (const item of preload_targets) {
      switch (typeof item) {
        case "function":
          item(complete_preload_one);
          break;
        case "string":
          this.kag.preload(item, complete_preload_one);
          break;
      }
    }

    //ジャンプ
    //data.stat.current_scenario;
    //data.current_order_index;
    //必ず、ファイルロード。別シナリオ経由的な
    //this.kag.ftag.startTag("call",{storage:"make.ks"});

    //auto_next 一旦makeを経由するときに、auto_nextを考えておく
    //alert(auto_next);

    //auto_next = "yes";

    //make.ks を廃止したい
    //var insert =undefined;
  };

  //バックログ画面表示
  tyrano.plugin.kag.menu.displayLog = function () {
    var that = this;
    that.kag.unfocus();
    this.kag.setSkip(!1);
    $("<div></div>");
    this.kag.html("backlog", { novel: $.novel }, function (html_str) {
      var j_menu = $(html_str),
        layer_menu = that.kag.layer.getMenuLayer();
        layer_menu.empty();
        layer_menu.append(j_menu);

        that.setMenuCloseEvent(layer_menu);
      that.setHoverEvent(layer_menu);
        that.setMenuScrollEvents(j_menu, { target: ".log_body", move: 60 });

        // スマホのタッチ操作でスクロールできるようにするために touchmove の伝搬を切る
        // (document まで伝搬するとそこのリスナで e.preventDefault() が呼ばれるため)
        j_menu.find(".log_body").on("touchmove", (e) => {
          e.stopPropagation();
        });

        var log_str = "";

        //バックログ全文をarray_logに入れる
        var array_log = that.kag.variable.tf.system.backlog;
        for (var i = 0, j = 0; i < array_log.length; i++) {
          //追加箇所start------------------------------------------------
          let array_log_html = $.parseHTML(array_log[i]);
          log_str += $(array_log_html).hasClass("canBacklogJump") ?
            `<div class="backlogSerialNumber${j++}">${array_log[i]}</div>` :
            `<div>${array_log[i]}</div>`;
          //追加箇所end------------------------------------------------
        }

        layer_menu.find(".log_body").html(log_str);

        layer_menu.find(".log_body").css("font-family", that.kag.config.userFace);

        $.preloadImgCallback(
          layer_menu,
          function () {
            layer_menu.stop(!0, !0).fadeIn(300);
            //一番下固定させる
            layer_menu.find(".log_body").scrollTop(9999999999);
          },
          that,
        );

        $(".button_menu").hide();


        //追加箇所start------------------------------------------------
        //マウスオンの箇所をハイライト
        $(".backlog_text").hover(
          function () {
            $(this).css("background-color", "rgba(0, 0, 255, 0.1)");
          },
          function () {
            $(this).css("background-color", "rgba(255, 255, 255, 0)");
          }
        );

        //マウスクリックでジャンプ
        $(".backlog_text").click((e) => {
          if (tyrano.plugin.kag.tmp.orukred.backlogJump.saveFile.length < 0) {
            console.log("バックログがないにも関わらずバックログジャンプを実行しようとしました。");//ないとは思うけど一応
            return;
          }
          if (confirm("この位置にジャンプしますか？")) {
            //ロード処理
            $('.menu_close').trigger('click');
            const backlogSerialNumber = e.target.parentElement.className.replace("backlogSerialNumber", "");//backlogSerialNumber0を取得
            const isDeleteBacklog = false;
            that.loadGameData($.extend(true, {}, tyrano.plugin.kag.tmp.orukred.backlogJump.saveFile[backlogSerialNumber]), { auto_next: "yes", bgm_over: "false" }, isDeleteBacklog);
            that.kag.setSkip(false);//スキップモード維持されることあったのでそれの防止
          }
        });
        //追加箇所end------------------------------------------------
      },
    );
  };


  //セーブ状態のスナップを保存します。
  tyrano.plugin.kag.menu.snapSave = function (title, call_back, flag_thumb) {
    // ティラノイベント"snapsave-start"を発火
    var that = this;
    this.kag.trigger("snapsave-start");

    //画面のキャプチャも取るよ
    var _current_order_index = that.kag.ftag.current_order_index - 1;
    var _stat = $.extend(true, {}, $.cloneObject(that.kag.stat));

    //3Dオブジェクトが実装されてる場合復元させる。////////////////////

    var three = this.kag.tmp.three;
    var models = three.models;

    var three_save = {};

    three_save.stat = three.stat;
    three_save.evt = three.evt;

    var save_models = {};

    for (var key in models) {
      var model = models[key];
      save_models[key] = model.toSaveObj();
    }

    three_save.models = save_models;

    /////////////////////////////////////////////////////////////

    if (typeof flag_thumb == "undefined") {
      flag_thumb = this.kag.config.configThumbnail;
    }

    if (flag_thumb == "false") {
      //
      // サムネイルデータを作成しない場合
      //
      var img_code = "";
      var data = {};

      data.title = $(title).text();
      data.stat = _stat;
      data.three = three_save;
      data.current_order_index = _current_order_index;
      //１つ前
      data.save_date = that.getDateStr();
      data.img_data = img_code;

      //レイヤ部分のHTMLを取得
      var layer_obj = that.kag.layer.getLayeyHtml();
      data.layer = layer_obj;

      that.snap = $.extend(true, {}, $.cloneObject(data));

      //追加箇所start------------------------------------------------
      if (title === "backlogJump") {
        tyrano.plugin.kag.tmp.orukred.backlogJump.pushSaveFile(that.snap);
      }
      //追加箇所end------------------------------------------------
      if (call_back) {
        call_back();

        // ティラノイベント"snapsave-complete"を発火
        that.kag.trigger("snapsave-complete");
      }
    } else {
      var thumb_scale = this.kag.config.configThumbnailScale || 1;
      if (thumb_scale < 0.01) thumb_scale = 0.01;
      if (thumb_scale > 1) thumb_scale = 1;

      $("#tyrano_base").find(".layer_blend_mode").css("display", "none");

      setTimeout(function () {
        //
        // キャプチャ完了時コールバック
        //
        var completeImage = function (img_code) {
          var data = {};

          data.title = $(title).text();
          data.stat = _stat;
          data.three = three_save;

          data.current_order_index = _current_order_index;
          //１つ前
          data.save_date = that.getDateStr();
          data.img_data = img_code;

          //レイヤ部分のHTMLを取得
          var layer_obj = that.kag.layer.getLayeyHtml();
          data.layer = layer_obj;

          that.snap = $.extend(true, {}, $.cloneObject(data));
          //追加箇所start------------------------------------------------
          if (title === "backlogJump") {
            tyrano.plugin.kag.tmp.orukred.backlogJump.pushSaveFile(that.snap);
          }
          //追加箇所end------------------------------------------------	
          if (call_back) {
            call_back();

            // ティラノイベント"snapsave-complete"を発火
            that.kag.trigger("snapsave-complete");
          }

          that.kag.hideLoadingLog();
        };

        if (that.kag.stat.save_img != "") {
          //
          // サムネイルに使う画像が[save_img]タグで直接指定されている場合
          //

          var img = new Image();
          img.src = _stat.save_img;
          img.onload = function () {
            var canvas = document.createElement("canvas");
            canvas.width = that.kag.config.scWidth * thumb_scale;
            canvas.height = that.kag.config.scHeight * thumb_scale;
            // Draw Image
            var ctx = canvas.getContext("2d");
            ctx.drawImage(img, 0, 0, canvas.width, canvas.height);
            // To Base64
            var img_code = that.createImgCode(canvas);

            completeImage(img_code);
          };
        } else {
          //
          // html2canvas.jsでゲーム画面のキャプチャを実行する場合
          //

          that.kag.showLoadingLog("save");

          //ビデオをキャプチャするための仕組み
          let canvas = document.createElement("canvas"); // declare a canvas element in your html
          let ctx = canvas.getContext("2d");
          let videos = document.querySelectorAll("video");
          let w, h;
          for (let i = 0, len = videos.length; i < len; i++) {
            const v = videos[i];
            //if (!v.src) continue // no video here
            try {
              w = v.videoWidth;
              h = v.videoHeight;

              canvas.style.left = v.style.left;
              canvas.style.top = v.style.top;

              canvas.style.width = v.style.width;
              canvas.style.height = v.style.height;

              canvas.width = w;
              canvas.height = h;

              ctx.fillRect(0, 0, w, h);
              ctx.drawImage(v, 0, 0, w, h);
              v.style.backgroundImage = `url(${canvas.toDataURL()})`; // here is the magic
              v.style.backgroundSize = "cover";
              v.classList.add("tmp_video_canvas");

              ctx.clearRect(0, 0, w, h); // clean the canvas
            } catch (e) {
              continue;
            }
          }

          //canvasがある場合は、オリジナルをクローン。画面サイズによっては、カクつく問題が残る
          var flag_canvas = false;
          var array_canvas = [];
          $("#tyrano_base")
            .find("canvas")
            .each(function (index, element) {
              array_canvas.push(element);
            });
          if (array_canvas.length > 0) {
            flag_canvas = true;
          }

          var tmp_base;

          //canvasがある場合。
          if (flag_canvas) {
            tmp_base = $("#tyrano_base");
          } else {
            tmp_base = $("#tyrano_base").clone();
            tmp_base.addClass("snap_tmp_base");
            $("body").append(tmp_base);
          }

          var tmp_left = tmp_base.css("left");
          var tmp_top = tmp_base.css("top");
          var tmp_trans = tmp_base.css("transform");

          tmp_base.css("left", 0);
          tmp_base.css("top", 0);
          tmp_base.css("transform", "");
          tmp_base.find(".layer_menu").hide();

          var opt = {
            scale: thumb_scale,
            height: that.kag.config.scHeight,
            width: that.kag.config.scWidth,
            logging: that.kag.config["debugMenu.visible"] === "true",
          };

          html2canvas(tmp_base.get(0), opt).then(function (canvas) {
            $("#tyrano_base").find(".layer_blend_mode").css("display", "");
            $("#tyrano_base").find(".tmp_video_canvas").css("backgroundImage", "");

            // キャプチャした画像をDOMに追加してクオリティチェック
            // コメントトグル:  ⌘ + /  または  Ctrl + /
            // $("body").css({
            //     overflow: "scroll",
            // });
            // $(canvas)
            //     .css({
            //         position: "absolute",
            //         top: $.getViewPort().height,
            //     })
            //     .appendTo("body");
            // console.log(canvas)
            var img_code = that.createImgCode(canvas);

            completeImage(img_code);
          });

          tmp_base.hide();

          tmp_base.css("left", tmp_left);
          tmp_base.css("top", tmp_top);
          tmp_base.css("transform", tmp_trans);
          tmp_base.find(".layer_menu").show();
          $("body").find(".snap_tmp_base").remove();

          tmp_base.show();
        }
      }, 20);
    }
  }


}());
