/**
 * 已重建完成
 */
package net.play5d.kyo.stage {
	import flash.display.DisplayObject;
	
	/**
	 * 场景接口
	 */
	public interface IStage {
		
		function get display():DisplayObject;
		
		function build():void;
		
		function afterBuild():void;
		
		function destory(back:Function = null):void;
	}
}
