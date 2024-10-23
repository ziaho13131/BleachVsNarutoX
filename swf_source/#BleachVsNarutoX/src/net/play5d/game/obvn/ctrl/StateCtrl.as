/**
 * 已重建完成
 */
package net.play5d.game.obvn.ctrl {
	import flash.display.Sprite;
	
	import net.play5d.game.obvn.MainGame;
	import net.play5d.game.obvn.ui.QuickTransUI;
	import net.play5d.game.obvn.ui.TransUI;
	
	/**
	 * 场景状态控制器
	 */
	public class StateCtrl {
		
		private static var _i:StateCtrl;
		
		public var transEnabled:Boolean = true;
		private var _transUI:TransUI;
		private var _quickTransUI:QuickTransUI;
		private var _transContainer:Sprite;
		
		public function StateCtrl() {
			_transContainer = MainGame.I.root;
		}
		
		public static function get I():StateCtrl {
			_i ||= new StateCtrl();
			
			return _i;
		}
		
		private function addTransUI():void {
			if (!_transUI) {
				_transUI = new TransUI();
			}
			
			_transContainer.addChild(_transUI.ui);
		}
		
		private function removeTrainsUI():void {
			try {
				_transContainer.removeChild(_transUI.ui);
			}
			catch (e:Error) {
			}
		}
		
		public function transIn(back:Function = null, removeAfterComplete:Boolean = false):void {
			if (!transEnabled) {
				if (back != null) {
					back();
				}
				return;
			}
			
			addTransUI();
			
			var backFunc:Function = removeAfterComplete ? removeSelf : back;
			_transUI.fadIn(backFunc);
			
			function removeSelf():void {
				if (back != null) {
					back();
				}
				removeTrainsUI();
			}
		}
		
		public function transOut(back:Function = null, removeAfterComplete:Boolean = true):void {
			if (!transEnabled) {
				if (back != null) {
					back();
				}
				
				return;
			}
			
			addTransUI();
			
			var backFunc:Function = removeAfterComplete ? removeSelf : back;
			_transUI.fadOut(backFunc);
			
			function removeSelf():void {
				if (back != null) {
					back();
				}
				removeTrainsUI();
			}
		}
		
		public function quickTrans(back:Function = null):void {
			if (!_transContainer) {
				if (back != null) {
					back();
				}
				
				return;
			}
			if (!_quickTransUI) {
				_quickTransUI = new QuickTransUI();
			}
			
			_transContainer.addChild(_quickTransUI);
			_quickTransUI.fadInAndOut(transCom);
			
			function transCom():void {
				try {
					_transContainer.removeChild(_quickTransUI);
				}
				catch (e:Error) {
				}
				if (back != null) {
					back();
				}
			}
		}
		
		public function clearTrans():void {
			removeTrainsUI();
		}
	}
}
