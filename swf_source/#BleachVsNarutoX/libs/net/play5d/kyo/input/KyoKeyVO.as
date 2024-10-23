/**
 * 已重建完成
 */
package net.play5d.kyo.input {
	
	/**
	 * 按键值对象
	 */
	public class KyoKeyVO {
		
		public var name:String;				// 名字
		public var code:int;				// 代码
		
//		public var isDown:Boolean;			// 是否按下
		
		public function KyoKeyVO(name:String, code:int) {
			this.name = name;
			this.code = code;
		}
		
		public function toString():String {
			return name;
		}
		
		public function clone():KyoKeyVO {
			return new KyoKeyVO(name, code);
		}
	}
}
