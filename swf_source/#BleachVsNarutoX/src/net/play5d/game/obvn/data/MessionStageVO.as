/**
 * 已重建完成
 */
package net.play5d.game.obvn.data {
	import net.play5d.kyo.utils.KyoRandom;
	
	/**
	 * 闯关场景值对象
	 */
	public class MessionStageVO {
		
		public var fighters:Array;
		public var assister:String;
		public var map:String;
		public var mession:MessionVO;
		
		public var attackRate:Number = 1;
		public var hpRate:Number = 1;
		
		public function getFighters():Array {
			// 判断XML中配置的游戏模式是单人还是小队
			if (mession.gameMode == 0) {
				var a:Array = [];
				a = a.concat(fighters);
				var addlen:int = 3 - a.length;
				
				if (addlen > 0) {
					for (var i:int = 0; i < addlen; i++) {
						a.push(null);
					}
				}
				return a;
			}
			
			return [KyoRandom.getRandomInArray(fighters)];
		}
	}
}
