/**
 * 已重建完成
 */
package net.play5d.game.obvn.map {
	
	/**
	 * 地板值对象
	 */
	public class FloorVO {
		
		public var y:Number = 0;			// 高度
		public var xFrom:Number = 0;		// 起始宽度
		public var xTo:Number = 0;			// 结束宽度
		
		public function toString():String {
			return "FloorVO :: {xFrom:" + xFrom + ",xTo:" + xTo + ",y:" + y + "}";
		}
		
		/**
		 * 碰撞检测
		 */
		public function hitTest(X:Number, Y:Number, SPEED:Number):Boolean {
			return Y > y - SPEED && Y < y + SPEED && X > xFrom && X < xTo;
		}
	}
}
