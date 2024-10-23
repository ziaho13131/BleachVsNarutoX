/**
 * 已重建完成
 */
package net.play5d.game.obvn.fighter.utils {
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	
	/**
	 * 影片剪辑区域缓存器
	 */
	public class McAreaCacher {
		
		private var _idCache:Object = {};
		private var _frameCache:Object = {};
		
		public var name:String;
		
		public function McAreaCacher(name:String) {
			this.name = name;
		}
		
		public function destory():void {
			_idCache = null;
			_frameCache = null;
		}
		
		public function areaFrameDefined(frame:int):Boolean {
			return _frameCache[frame] !== undefined;
		}
		
		public function getAreaByFrame(frame:int):Object {
			return _frameCache[frame];
		}
		
		public function cacheAreaByFrame(frame:int, area:Object):void {
			_frameCache[frame] = area;
		}
		
		public function getAreaByDisplay(display:DisplayObject):Object {
			var cacheid:String = getDisplayCacheId(display);
			if (_idCache[cacheid]) {
				return _idCache[cacheid];
			}
			
			return null;
		}
		
		public function cacheAreaByDisplay(display:DisplayObject, area:Rectangle, customParam:Object = null):Object {
			var cacheid:String = getDisplayCacheId(display);
			var displayName:String = display.name;
			
			var cacheObj:Object = {};
			cacheObj.name = displayName;
			cacheObj.area = area;
			
			if (customParam) {
				for (var i:String in customParam) {
					cacheObj[i] = customParam[i];
				}
			}
			
			_idCache[cacheid] = cacheObj;
			return cacheObj;
		}
		
		private static function getDisplayCacheId(d:DisplayObject):String {
			return d.name + "_" + d.x + "," + d.y + "," + d.width + "," + d.height + "," + d.rotation;
		}
	}
}
