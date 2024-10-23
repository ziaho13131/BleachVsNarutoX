/**
 * 已重建完成
 */
package net.play5d.game.obvn.interfaces {
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	import net.play5d.game.obvn.data.ConfigVO;
	
	/**
	 * 游戏接口
	 */
	public interface IGameInterface {
		
		
		function initTitleUI(ui:DisplayObject):void;
		
//		function moreGames():void;
//		function showRank():void;
//		function submitScore(param1:int):void;
		
		function saveGame(data:Object):void;
		function loadGame():Object;
		
		function getGameInput(player:String):Vector.<IGameInput>;
		function getGameMenu():Array;
		function getSettingMenu():Array;
		
		function updateInputConfig():Boolean;
//		function getConfigExtend():IExtendConfig;
		
		function afterBuildGame():void;
		
		function applyConfig(config:ConfigVO):void;
		function getCreadits(creditsInfo:String):Sprite;
	}
}
