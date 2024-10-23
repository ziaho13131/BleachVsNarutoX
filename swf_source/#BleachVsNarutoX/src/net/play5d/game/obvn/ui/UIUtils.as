/**
 * 已重建完成
 */
package net.play5d.game.obvn.ui {
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import net.play5d.kyo.utils.KyoUtils;
	
	/**
	 * UI 工具
	 */
	public class UIUtils {
		
		public static var formatTextFunction:Function;
		
		public static var DEFAULT_FONT:String = "SimHei";			// 默认字体
		public static var LOCK_FONT:String = null;					// 锁定字体
		
		
		/**
		 * 格式化文本
		 */
		public static function formatText(text:TextField, textFormatParam:Object = null):void {
			if (textFormatParam) {
				var tf:TextFormat = new TextFormat();
				tf.font = DEFAULT_FONT;
				
				KyoUtils.setValueByObject(tf, textFormatParam);
				if (LOCK_FONT) {
					tf.font = LOCK_FONT;
				}
				
				text.defaultTextFormat = tf;
			}
			
			if (formatTextFunction != null) {
				formatTextFunction(text);
			}
		}
	}
}
