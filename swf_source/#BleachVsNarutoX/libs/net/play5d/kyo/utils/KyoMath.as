/**
 * 已重建完成
 */
package net.play5d.kyo.utils {
	import flash.geom.Point;
	
	/**
	 * 数学计算
	 */
	public class KyoMath {
		
		public static function getPointByRadians(point:Point, radious:Number, scale:Number = 1):Point {
			var rp:Point = new Point();
			rp.x = point.x * Math.cos(radious) - point.y * Math.sin(radious) * scale;
			rp.y = point.x * Math.sin(radious) + point.y * Math.cos(radious) * scale;
			
			return rp;
		}
		
		public static function asRadians(degrees:Number):Number {
			return degrees * Math.PI / 180;
		}
	}
}