/**
 * 已重建完成
 */
package net.play5d.game.obvn.ctrl {
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	import net.play5d.game.obvn.Debugger;
	import net.play5d.game.obvn.data.AssisterModel;
	import net.play5d.game.obvn.data.FighterModel;
	import net.play5d.game.obvn.data.FighterVO;
	import net.play5d.game.obvn.data.MapModel;
	import net.play5d.game.obvn.data.MapVO;
	import net.play5d.game.obvn.fighter.Assister;
	import net.play5d.game.obvn.fighter.FighterMain;
	import net.play5d.game.obvn.map.MapMain;
	
	/**
	 * 游戏加载器
	 */
	public class GameLoader {
		
		private static var _loaderCache:Vector.<Loader> = new Vector.<Loader>();
		
		public static function loadFighter(
			fighterId:String,
			back:Function, fail:Function = null, process:Function = null,
			customBackParam:Object = null):void 
		{
			var fv:FighterVO = FighterModel.I.getFighter(fighterId, true);
			if (!fv) {
				trace("GameLoader.loadFighter :: Fighter ID not exist: " + fighterId);
				
				if (fail != null) {
					fail("Fighter ID error!");
				}
				
				return;
			}
			loadSWF(fv.fileUrl, loadComplete, fail, process);
			
			function loadComplete(content:DisplayObject):void {
				var fighter:FighterMain = new FighterMain(content as MovieClip);
				fighter.data = fv;
				
				if (back != null) {
					if (customBackParam) {
						back(fighter, customBackParam);
					}
					else {
						back(fighter);
					}
					
					back = null;
				}
			}
		}
		
		public static function loadAssister(
			fighterId:String,
			back:Function, fail:Function = null, process:Function = null,
			customBackParam:Object = null):void 
		{
			var fv:FighterVO = AssisterModel.I.getAssister(fighterId, true);
			if (!fv) {
				trace("GameLoader.loadAssister :: Assist ID no exist:" + fighterId);
				
				if (fail != null) {
					fail("Assist ID error!");
				}
				return;
			}
			loadSWF(fv.fileUrl, loadComplete, fail, process);
			
			function loadComplete(content:DisplayObject):void {
				var fighter:Assister = new Assister(content as MovieClip);
				fighter.data = fv;
				
				if (back != null) {
					if (customBackParam) {
						back(fighter, customBackParam);
					}
					else {
						back(fighter);
					}
					back = null;
				}
			}
		}
		
		public static function loadMap(
			mapId:String,
			back:Function, fail:Function = null, process:Function = null,
			customBackParam:Object = null):void 
		{
			var mv:MapVO = MapModel.I.getMap(mapId);
			if (!mv) {
				trace("GameLoader.loadMap :: Map ID no exist:" + mapId);
				
				if (fail != null) {
					fail("Map ID error!");
				}
				return;
			}
			loadSWF(mv.fileUrl, loadComplete, fail, process);
			
			function loadComplete(content:DisplayObject):void {
				var map:MapMain = new MapMain(content as Sprite);
				map.data = mv;
				
				if (back != null) {
					if (customBackParam) {
						back(map, customBackParam);
					}
					else {
						back(map);
					}
					back = null;
				}
			}
		}
		
		public static function dispose():void {
			while (_loaderCache.length > 0) {
				var l:Loader = _loaderCache.shift();
				
				try {
					l.unloadAndStop(true);
				}
				catch (e:Error) {
					trace("GameLoader.dispose :: " + e);
					l.unload();
				}
			}
		}
		
		private static function loadSWF(url:String, back:Function, fail:Function = null, process:Function = null):void {
			AssetManager.I.loadSWF(url, loadComplete, loadIOError, process);
			
			function loadComplete(l:Loader):void {
				if (back != null) {
					back(l.content);
					back = null;
				}
				
				_loaderCache.push(l);
			}
			function loadIOError():void {
				Debugger.log("GameLoader.loadSWF :: Can't find file:" + url);
				
				if (fail != null) {
					fail("Error loading scenario file!");
				}
			}
		}
	}
}
