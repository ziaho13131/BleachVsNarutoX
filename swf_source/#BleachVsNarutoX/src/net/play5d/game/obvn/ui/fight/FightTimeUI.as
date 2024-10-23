/**
 * 已重建完成
 */
package net.play5d.game.obvn.ui.fight {
	import flash.display.DisplayObject;
	
	import net.play5d.game.obvn.ctrl.game_ctrler.GameCtrler;
	import net.play5d.game.obvn.utils.ResUtils;
	import net.play5d.kyo.display.MCNumber;
	
	import flash.display.MovieClip;
	
	/**
	 * 战斗时间UI类
	 */
	public class FightTimeUI {
		
		
		private var _ui:MovieClip;
		private var _numMc:MCNumber;
		
		private var _renderTime:Boolean;
		
		public function FightTimeUI(ui:MovieClip) {
			var timeTxtCls:Class = null;
			
			_ui = ui;
			
			var time:int = GameCtrler.I.gameRunData.gameTimeMax;
			
			if (time == -1) {
				_renderTime = false;
				_ui.wuxian.visible = true;
			}
			else {
				_renderTime = true;
				timeTxtCls = ResUtils.I.getItemClass(ResUtils.I.fight, "time_txtmc");
				
				_numMc = new MCNumber(timeTxtCls, 0, 1, 20, 2);
				_numMc.x = -22;
				_numMc.y = -15;
				
				_ui.addChild(_numMc);
				_ui.wuxian.visible = false;
				
				_numMc.number = time;
			}
		}
		
		public function get timeUI():DisplayObject {
			return _numMc;
		}
		
		public function render():void {
			if (!_renderTime) {
				return;
			}
			
			var time:int = GameCtrler.I.gameRunData.gameTime;
			_numMc.number = time;
		}
	}
}
