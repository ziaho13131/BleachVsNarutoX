/**
 * 已重建完成
 */
package net.play5d.game.obvn.utils {
	import net.play5d.game.obvn.interfaces.ILogger;
	
	/**
	 * 游戏日志记录
	 */
	public class GameLogger {
		
		private static var _logger:ILogger;
		
//		public static function setLoger(v:ILogger):void {
//			_logger = v;
//		}
		
		public static function log(v:String):void {
			if (_logger) {
				_logger.log(v);
				return;
			}
			
			trace(v);
		}
	}
}
