/**
 * 已重建完成
 */
package net.play5d.game.obvn.interfaces {
	import flash.display.DisplayObject;
	import flash.events.IEventDispatcher;
	
	/**
	 * 内部设置UI接口
	 */
	public interface IInnerSetUI extends IEventDispatcher {
		
		function fadIn():void;
		function fadOut():void;
		
		function getUI():DisplayObject;
		
		function destory():void;
	}
}
