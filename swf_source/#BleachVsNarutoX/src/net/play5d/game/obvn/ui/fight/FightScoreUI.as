/**
 * 已重建完成
 */
package net.play5d.game.obvn.ui.fight {
	import net.play5d.game.obvn.utils.ResUtils;
	import net.play5d.kyo.display.MCNumber;
	
	import flash.display.MovieClip;
	
	/**
	 * 战斗得分UI类
	 */
	public class FightScoreUI {
		
		
		private var _ui:MovieClip;
		private var _nummc:MCNumber;
		
		public function FightScoreUI(ui:MovieClip) {
			_ui = ui;
			
			var txtCls:Class = ResUtils.I.getItemClass(ResUtils.I.fight, "txtmc_score");
			_nummc = new MCNumber(txtCls, 0, 1, 10, 10);
			
			_ui.ct.addChild(_nummc);
		}
		
		public function setScore(v:int):void {
			_nummc.number = v;
		}
	}
}
