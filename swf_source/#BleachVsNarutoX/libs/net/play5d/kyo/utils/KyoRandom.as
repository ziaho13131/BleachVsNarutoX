/**
 * 已重建完成
 */
package net.play5d.kyo.utils {
	
	/**
	 * 随机数据
	 */
	public class KyoRandom {
		
		public static function getRandomInArray(array:Object, deleteSelect:Boolean = false):* {
			if (array == null || array.length < 1) {
				return null;
			}
			var r:int = Math.random() * array.length << 0;
			var item:* = array[r];
			if (deleteSelect) {
				array.splice(r, 1);
			}
			
			return item;
		}
		
		public static function arraySortRandom(array:Array):void {
			array.sort(taxis);
			
			function taxis(element1:*, element2:*):int {
				var num:Number = Math.random();
				if (num < 0.5) {
					return -1;
				}
				return 1;
			}
		}
	}
}
