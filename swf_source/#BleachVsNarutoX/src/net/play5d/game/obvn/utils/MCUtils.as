/**
 * 已重建完成
 */
package net.play5d.game.obvn.utils {
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.FrameLabel;
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	
	import net.play5d.game.obvn.interfaces.IGameSprite;
	
	/**
	 * 影片剪辑工具
	 */
	public class MCUtils {
		
		public static function hasFrameLabel(mc:MovieClip, label:String):Boolean {
			var labels:Array = mc.currentLabels;
			for each(var i:FrameLabel in labels) {
				if (i.name == label) {
					return true;
				}
			}
			return false;
		}
		
		/**
		 * 停止所有影片剪辑
		 */
		public static function stopAllMovieClips(sp:DisplayObjectContainer):void {
			for (var i:int = 0; i < sp.numChildren; i++) {
				var d:DisplayObject = sp.getChildAt(i);
				if (d && d is MovieClip) {
					var mc:MovieClip = d as MovieClip;
					if (!mc) {
						continue;
					}
					
					mc.stop();
					stopAllMovieClips(mc);
				}
			}
		}
		
		/**
		 * 更改颜色
		 */
		public static function changeColor(sp:IGameSprite, ct:ColorTransform = null):void {
			if (!sp) {
				return;
			}
			
			if (ct == null) {
				ct = new ColorTransform();
				ct.greenOffset = -85;
			}
			
			sp.colorTransform = ct;
		}
	}
}