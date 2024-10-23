/**
 * 已重建完成
 */
package net.play5d.game.obvn.ui {
	import flash.display.DisplayObject;
	import flash.events.DataEvent;
	
	import net.play5d.game.obvn.GameConfig;
	import net.play5d.game.obvn.MainGame;
	import net.play5d.game.obvn.data.GameData;
	import net.play5d.game.obvn.data.GameRunFighterGroup;
	import net.play5d.game.obvn.ui.dialog.AlertUI;
	import net.play5d.game.obvn.ui.dialog.ConfirmUI;
	import net.play5d.game.obvn.ui.fight.FightUI;
	import net.play5d.game.obvn.interfaces.IGameUI;
	
	/**
	 * 游戏UI
	 */
	public class GameUI {
		
		public static var I:GameUI;
		public static var BITMAP_UI:Boolean = true;
		public static var SHOW_CN_TEXT:Boolean = true;
		
		private static var _confirmUI:ConfirmUI;
		private static var _alertUI:AlertUI;
		
		private var _ui:IGameUI;
		private var _renderAnimateGap:int;
		private var _renderAnimateFrame:int = 0;
		
		public function GameUI() {
			I = this;
			_renderAnimateGap = Math.ceil(GameConfig.FPS_GAME / 30) - 1;
		}
		
		public static function showingDialog():Boolean {
			return _confirmUI != null || _alertUI != null;
		}
		
		public static function confirm(
			enMsg:String = null, cnMsg:String = null,
			yes:Function = null, no:Function = null):void 
		{
			closeConfrim();
			_confirmUI = new ConfirmUI();
			_confirmUI.setMsg(enMsg, cnMsg);
			_confirmUI.yesBack = yesClose;
			_confirmUI.noBack = noClose;
			
			MainGame.I.stage.dispatchEvent(new DataEvent("5d_message", false, false, JSON.stringify(["show_confrim"])));
			MainGame.I.root.addChild(_confirmUI);
			
			function yesClose():void {
				if (yes != null) {
					yes();
				}
				
				closeConfrim();
				MainGame.I.stage.dispatchEvent(new DataEvent(
					"5d_message",
					false,
					false,
					JSON.stringify(["close_confrim", true])
				));
			}
			function noClose():void {
				if (no != null) {
					no();
				}
				
				closeConfrim();
				MainGame.I.stage.dispatchEvent(new DataEvent(
					"5d_message",
					false,
					false,
					JSON.stringify(["close_confrim", false])
				));
			}
		}
		
		public static function alert(enMsg:String = null, cnMsg:String = null, close:Function = null):void {
			closeAlert();
			_alertUI = new AlertUI();
			_alertUI.setMsg(enMsg, cnMsg);
			_alertUI.closeBack = closeBack;
			
			MainGame.I.root.addChild(_alertUI);
			MainGame.I.stage.dispatchEvent(new DataEvent("5d_message", false, false, JSON.stringify(["show_alert"])));
			
			function closeBack():void {
				if (close != null) {
					close();
				}
				closeAlert();
				MainGame.I.stage.dispatchEvent(new DataEvent(
					"5d_message",
					false,
					false,
					JSON.stringify(["close_alert"])
				));
			}
		}
		
		public static function closeAlert():void {
			if (_alertUI) {
				try {
					MainGame.I.root.removeChild(_alertUI);
				}
				catch (e:Error) {
				}
				
				_alertUI.destory();
				_alertUI = null;
			}
		}
		
		public static function closeConfrim():void {
			if (_confirmUI) {
				try {
					MainGame.I.root.removeChild(_confirmUI);
				}
				catch (e:Error) {
				}
				
				_confirmUI.destory();
				_confirmUI = null;
			}
		}
		
		public function getUI():IGameUI {
			return _ui;
		}
		
		public function getUIDisplay():DisplayObject {
			return _ui.getUI();
		}
		
		public function initFight(p1:GameRunFighterGroup, p2:GameRunFighterGroup):void {
			var volume:Number = GameData.I.config.soundVolume;
			if (_ui) {
				if (!(_ui is FightUI)) {
					_ui.destory();
					_ui = new FightUI();
					_ui.setVolume(volume);
				}
			}
			else {
				_ui = new FightUI();
				_ui.setVolume(volume);
			}
			
			(_ui as FightUI).initlize(p1, p2);
		}
		
		public function render():void {
			if (!_ui) {
				return;
			}
			
			_ui.render();
			if (isRenderAnimate()) {
				renderAnimate();
			}
		}
		
		private function renderAnimate():void {
			if (_ui) {
				_ui.renderAnimate();
			}
		}
		
		private function isRenderAnimate():Boolean {
			if (_renderAnimateGap > 0) {
				if (_renderAnimateFrame++ >= _renderAnimateGap) {
					_renderAnimateFrame = 0;
					
					return true;
				}
				
				return false;
			}
			
			return true;
		}
		
		public function fadIn():void {
			if (_ui) {
				var volume:Number = GameData.I.config.soundVolume;
				
				_ui.fadIn();
				_ui.setVolume(volume);
			}
		}
		
		public function fadOut():void {
			if (_ui) {
				_ui.fadIn();
			}
		}
		
		public function destory():void {
			if (_ui) {
				_ui.destory();
			}
		}
	}
}
