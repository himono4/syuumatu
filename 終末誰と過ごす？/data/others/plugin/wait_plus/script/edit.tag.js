
TYRANO.kag.key_mouse.next = function(){
	if (this.util.canClick()) {
		this.util.clearSkipAndAuto();
		$(".layer_event_click").trigger("click");
		return !0
	}
	if(this.kag.variable.is_wait_plus_skip_click && this.kag.stat.is_wait){
		$('#wait_skip_click').hide();
		this.kag.cancelStrongStop();
		this.kag.cancelWeakStop();
		this.kag.variable.is_wait_plus_skip_click = false;
		this.kag.stat.is_wait = !1;
		clearTimeout(this.kag.tmp.wait_id);
		this.kag.tmp.wait_id = '';
		this.kag.ftag.nextOrder()
	}
	return !1
};
