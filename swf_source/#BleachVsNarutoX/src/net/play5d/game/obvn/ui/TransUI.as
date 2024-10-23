/**
 * 已重建完成
 */
package net.play5d.game.obvn.ui {
	import net.play5d.game.obvn.MainGame;
	import net.play5d.game.obvn.ctrl.GameRender;
	import net.play5d.game.obvn.utils.ResUtils;
	
	import flash.display.MovieClip;
	
	/**
	 * 交换场景UI
	 */
	public class TransUI {
		
		public var ui:MovieClip;
		
		private var _renderAnimateGap:int = 0;
		private var _renderAnimateFrame:int = 0;
		
		private var _fadInBack:Function;
		private var _fadOutBack:Function;
		
		private var _rendering:Boolean = true;
		
		public function TransUI() {
			ui = ResUtils.I.createDisplayObject(ResUtils.I.common_ui, "trans_mc");
		}
		
		public function destory():void {
			GameRender.remove(render);
		}
		
		private function startRender():void {
			_renderAnimateGap = Math.ceil(MainGame.I.getFPS() / 30) - 1;
			_renderAnimateFrame = 0;
			_rendering = true;
			
			GameRender.add(render);
		}
		
		private function stopRender():void {
			_rendering = false;
			
			GameRender.remove(render);
		}
		
		private function render():void {
			if (!_rendering) {
				return;
			}
			if (_renderAnimateGap > 0) {
				if (_renderAnimateFrame++ >= _renderAnimateGap) {
					_renderAnimateFrame = 0;
					renderAnimate();
				}
			}
			else {
				renderAnimate();
			}
		}
		
		private function renderAnimate():void {
			if (ui.currentFrameLabel == "stop") {
				if (_fadInBack != null) {
					_fadInBack();
					_fadInBack = null;
					return;
				}
				
				if (_fadOutBack != null) {
					_fadOutBack();
					_fadOutBack = null;
					return;
				}
				
				stopRender();
				return;
			}
			
			ui.nextFrame();
		}
		
		public function fadIn(back:Function = null):void {
			_fadOutBack = null;
			_fadInBack = back;
			ui.gotoAndStop("fadin");
			startRender();
		}
		
		public function fadOut(back:Function = null):void {
			_fadInBack = null;
			_fadOutBack = back;
			ui.gotoAndStop("fadout");
			startRender();
		}
	}
}
