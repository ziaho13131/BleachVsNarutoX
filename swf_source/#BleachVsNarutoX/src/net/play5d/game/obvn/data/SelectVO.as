/**
 * 已重建完成
 */
package net.play5d.game.obvn.data {
	
	/**
	 * 选择值对象
	 */
	public class SelectVO {
		
		public var fighter1:String;
		public var fighter2:String;
		public var fighter3:String;
		
		public var fuzhu:String;
		
		public function getSelectFighters():Array {
			var a:Array = [];
			
			if (fighter1) {
				a.push(fighter1);
			}
			if (fighter2) {
				a.push(fighter2);
			}
			if (fighter3) {
				a.push(fighter3);
			}
			
			return a;
		}
		
		public function isSelected(id:String):Boolean {
			return fighter1 == id || fighter2 == id || fighter3 == id;
		}
		
		public function toString():String {
			return JSON.stringify({
				select: {
					fighter1: fighter1,
					fighter2: fighter2,
					fighter3: fighter3,
					fuzhu   : fuzhu
				}
			});
		}
	}
}
