/**
 * 已重建完成
 */
package net.play5d.game.obvn.data {
	
	/**
	 * 人物角色模型集合
	 */
	public class FighterModel {
		
		private static var _i:FighterModel;
		
		private var _fighterObj:Object;
		
		public static function get I():FighterModel {
			_i ||= new FighterModel();
			
			return _i;
		}
		
		public function getAllFighters():Object {
			return _fighterObj;
		}
		
		public function getFighters(comicType:int = -1, condition:Function = null):Vector.<FighterVO> {
			var vec:Vector.<FighterVO> = new Vector.<FighterVO>();
			
			for each(var i:FighterVO in _fighterObj) {
				if (condition && !condition(i)) {
					continue;
				}
				
				if (comicType == -1 || i.comicType == comicType) {
					vec.push(i);
				}
			}
			
			return vec;
		}
		
		public function getFighter(id:String, clone:Boolean = false):FighterVO {
			return _fighterObj[id];
		}
		
		public function initByXML(xml:XML):void {
			_fighterObj = {};
			
			for each(var i:XML in xml.fighter) {
				var fv:FighterVO = new FighterVO();
				fv.initByXML(i);
				
				_fighterObj[fv.id] = fv;
			}
		}
	}
}
