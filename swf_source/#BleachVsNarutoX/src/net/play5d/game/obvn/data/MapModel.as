/**
 * 已重建完成
 */
package net.play5d.game.obvn.data {
	
	/**
	 * 地图模型值对象
	 */
	public class MapModel {
		
		private static var _i:MapModel;
		
		private var _mapObj:Object;
		private var _mapArray:Array;
		
		public static function get I():MapModel {
			_i ||= new MapModel();
			
			return _i;
		}
		
		public function getMap(id:String):MapVO {
			return _mapObj[id];
		}
		
		public function getAllMaps():Array {
			return _mapArray;
		}
		
		public function initByXML(xml:XML):void {
			_mapObj = {};
			_mapArray = [];
			
			for each (var i:XML in xml.map) {
				var mv:MapVO = new MapVO();
				mv.initByXML(i);
				
				_mapObj[mv.id] = mv;
				_mapArray.push(mv);
			}
		}
	}
}
