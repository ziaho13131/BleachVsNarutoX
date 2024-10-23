/**
 * 已重建完成
 */
package net.play5d.game.obvn.data {
	import net.play5d.game.obvn.Debugger;
	import net.play5d.game.obvn.ctrl.AssetManager;
	import net.play5d.game.obvn.interfaces.GameInterface;
	
	/**
	 * 游戏数据
	 */
	public class GameData {
		
		private static var _i:GameData;
		
		public var config:ConfigVO = new ConfigVO();
		public var p1Select:SelectVO;
		public var p2Select:SelectVO;
		public var selectMap:String;
		public var score:int = 0;
		public var winnerId:String;
		
		public var isFristRun:Boolean = true;
		
		private const SAVE_ID:String = "bvn3.01";
		
		public static function get I():GameData {
			_i ||= new GameData();
			
			return _i;
		}
		
		public function loadConfig(back:Function, fail:Function = null):void {
			AssetManager.I.loadXML("assets/config/fighter.xml", loadFighterBack, loadFighterFail);
			
			function loadFighterBack(data:XML):void {
				FighterModel.I.initByXML(data);
				AssetManager.I.loadXML("assets/config/assistant.xml", loadAssetsBack, loadAssisterFail);
			}
			function loadAssetsBack(data:XML):void {
				AssisterModel.I.initByXML(data);
				AssetManager.I.loadXML("assets/config/select.xml", loadSelectBack, loadSelectFail);
			}
			function loadSelectBack(data:XML):void {
				config.select_config.setByXML(data);
				AssetManager.I.loadXML("assets/config/map.xml", loadMapBack, loadMapFail);
			}
			function loadMapBack(data:XML):void {
				MapModel.I.initByXML(data);
				AssetManager.I.loadXML("assets/config/mission.xml", loadMessionBack, loadMessionFail);
			}
			function loadMessionBack(data:String):void {
				MessionModel.I.initByXML(new XML(data));
				back();
			}
			
			
			function loadFighterFail():void {
				Debugger.log("Error reading fighter data!");
				if (fail != null) {
					fail("Error reading fighter data!");
				}
			}
			function loadAssisterFail():void {
				Debugger.log("Error reading assistant data!");
				if (fail != null) {
					fail("Error reading assistant data!");
				}
			}
			function loadSelectFail():void {
				Debugger.log("Error reading select stage data!");
				if (fail != null) {
					fail("Error reading select stage data!");
				}
			}
			function loadMapFail():void {
				Debugger.log("Error reading map data!");
				if (fail != null) {
					fail("Error reading map data!");
				}
			}
			function loadMessionFail():void {
				Debugger.log("Error reading mession data!");
				if (fail != null) {
					fail("Error reading map data!");
				}
			}
		}
		
		public function saveData():void {
			var o:Object = {};
			
			o.id = SAVE_ID;
			o.config = config.toSaveObj();
			
			GameInterface.instance.saveGame(o);
		}
		
		public function loadData():void {
			var o:Object = GameInterface.instance.loadGame();
			
			if (!o || o.id != SAVE_ID) {
				return;
			}
			
			config.readSaveObj(o.config);
		}
		
//		public function loadSelect(url:String):void {
//			AssetManager.I.loadXML(url, function (data:XML):void {
//				setSelectData(data);
//			}, function ():void {
//				trace("GameData.loadSelect :: Error!");
//			});
//		}
		
//		public function setSelectData(xml:XML):void {
//			config.select_config.setByXML(xml);
//		}
	}
}
