
//レイヤを追加
$('#tyrano_base').append("<div id='wait_skip_click' style='display:none; position:absolute; z-index:1000000000; width:100%; height:100%;'></div>");

//ウェイトを管理する用の変数を追加
TYRANO.kag.variable.is_wait_plus_skip_click = false;

	//レイヤをクリックした時のイベント
$('#wait_skip_click').click(function(){
	const is_wait = TYRANO.kag.variable.is_wait_plus_skip_click;
	if(is_wait && TYRANO.kag.stat.is_wait){
		$(this).hide();
		TYRANO.kag.cancelWeakStop();
		TYRANO.kag.cancelStrongStop();
		TYRANO.kag.variable.is_wait_plus_skip_click = false;
		TYRANO.kag.stat.is_wait = !1;
		clearTimeout(TYRANO.kag.tmp.wait_id);
		TYRANO.kag.tmp.wait_id = '';
		TYRANO.kag.ftag.nextOrder()
	}else{
		$(this).hide();
	}
});
