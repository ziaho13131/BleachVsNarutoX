/**
 * 已重建完成
 */
package net.play5d.game.obvn.ui {
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	
	import net.play5d.game.obvn.data.FighterVO;
	
	/**
	 * 胜利 UI
	 */
	public class WinUI {
		
		private var _ui:MovieClip;
		private var _team:int;
		
		public function WinUI(ui:MovieClip, team:int) {
			_ui = ui;
			_team = team;
		}
		
		public function get ui():DisplayObject {
			return _ui;
		}
		
		public function show(fighter:FighterVO, wins:int):void {
			if (!fighter) {
				return;
			}
			
			var playmc:MovieClip;
			switch (wins) {
				case 1:
					playmc = _team == 1 ? _ui.w1 : _ui.w2;
					break;
				case 2:
					playmc = _team == 1 ? _ui.w2 : _ui.w1;
			}
			
			if (!playmc) {
				return;
			}
			
			switch (fighter.comicType) {
				case 0:
					playmc.gotoAndPlay("in_bleach");
					break;
				case 1:
					playmc.gotoAndPlay("in_naruto");
			}
		}
	}
}
