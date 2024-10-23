/**
 * 已重建完成
 */
package net.play5d.game.obvn.ui.select {
	import net.play5d.game.obvn.GameConfig;
	import net.play5d.game.obvn.data.GameData;
	import net.play5d.game.obvn.data.SelectVO;
	import net.play5d.game.obvn.input.GameInputType;
	import net.play5d.game.obvn.utils.ResUtils;
	
	/**
	 * 选择UI工厂
	 */
	public class SelectUIFactory {
		
		public static function createSelecter(playerType:int = 1):SelecterItemUI {
			var ui:SelecterItemUI = new SelecterItemUI(playerType);
			
			ui.inputType = 
				playerType == 1 ? 
				GameInputType.P1 : 
				GameInputType.P2
			;
			ui.selectVO = 
				playerType == 1 ? 
				GameData.I.p1Select :
				GameData.I.p2Select
			;
			
			var groupClassName:String = 
				playerType == 1 ? 
				"selected_item_p1_mc" : 
				"selected_item_p2_mc"
			;
			
			var groupClass:Class = ResUtils.I.getItemClass(ResUtils.I.select, groupClassName);
			var group:SelectedFighterGroup = new SelectedFighterGroup(groupClass);
			group.x = 
				playerType == 1 ? 
				10 : 
				GameConfig.GAME_SIZE.x - 265
			;
			group.y = GameConfig.GAME_SIZE.y - 80;
			group.addFighter(null);
			
			ui.group = group;
			return ui;
		}
	}
}
