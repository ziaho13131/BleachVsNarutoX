/**
 * 已重建完成
 */
package net.play5d.game.obvn.data {
	import flash.geom.Point;
	
	/**
	 * 选择角色列表值对象
	 */
	public class SelectCharListItemVO {
		
		public var x:int;
		public var y:int;
		public var fighterID:String;
		public var offset:Point;
		
		public function SelectCharListItemVO(x:int, y:int, fighterID:String, offset:Point = null) {
			this.x = x;
			this.y = y;
			this.fighterID = fighterID;
			this.offset = offset;
		}
	}
}
