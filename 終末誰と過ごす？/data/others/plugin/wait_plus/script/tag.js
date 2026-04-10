(function(){

	const wait_plus = {
		vital: [],
		pm: {
			time: '',
			time2: '100',
			click: 'true',
			skip: 'true'
		},
		start: function(pm){
			const that = this;
			this.kag.weaklyStop();
			this.kag.stronglyStop();
			this.kag.stat.is_wait = !0;
			('0'==pm.time2) && (pm.time2 = '10');
			if('true'==pm.click){
				this.kag.variable.is_wait_plus_skip_click = true;
				$('#wait_skip_click').show();
			}
			const time = (this.kag.stat.is_skip && 'true'==pm.skip) ? parseInt(pm.time2) : parseInt(pm.time);
			this.kag.tmp.wait_id = setTimeout(function(){
				$('#wait_skip_click').hide();
				that.kag.cancelWeakStop();
				that.kag.cancelStrongStop();
				that.kag.variable.is_wait_plus_skip_click = false;
				that.kag.stat.is_wait = !1;
				that.kag.ftag.nextOrder();
			},time);
		}
	};
	TYRANO.kag.ftag.master_tag.wait_plus = object(wait_plus);
	TYRANO.kag.ftag.master_tag.wait_plus.kag = TYRANO.kag;

})();
