/**
 * 已重建完成
 */
package net.play5d.game.obvn.interfaces {
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	import net.play5d.game.obvn.data.ConfigVO;
	import net.play5d.game.obvn.input.GameKeyInput;
	
	public class GameInterfaceManager implements IGameInterface {
		
		
		public function initTitleUI(ui:DisplayObject):void {}
		
//		public function moreGames():void {
//			WebUtils.getURL("http://www.5dplay.net");
//		}
		
//		public function submitScore(score:int):void {}
		
//		public function showRank():void {}
		
		public function saveGame(data:Object):void {}
		
		public function loadGame():Object {
			return null;
		}
		
//		public function getFighterCtrl(player:int):IFighterActionCtrl {
//			return null;
//		}
		
		public function getGameMenu():Array {
			return null;
		}
		
		public function getSettingMenu():Array {
			return null;
		}
		
		public function getGameInput(type:String):Vector.<IGameInput> {
			var vec:Vector.<IGameInput> = new Vector.<IGameInput>();
			vec.push(new GameKeyInput());
			return vec;
		}
		
//		public function getConfigExtend():IExtendConfig {
//			return null;
//		}
		
		public function afterBuildGame():void {}
		
		public function updateInputConfig():Boolean {
			return false;
		}
		
		public function applyConfig(config:ConfigVO):void {}
		
		public function getCreadits(creditsInfo:String):Sprite {
			return null;
		}
	}
}
