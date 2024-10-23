/**
 * 已重建完成
 */
package net.play5d.game.obvn.interfaces {
	import flash.display.DisplayObject;
	
	/**
	 * 游戏UI接口
	 */
	public interface IGameUI {
		
		function setVolume(v:Number):void;
		
		function destory():void;
		
		function fadIn(param1:Boolean = true):void;
		function fadOut(param1:Boolean = true):void;
		
		function getUI():DisplayObject;
		
		function render():void;
		function renderAnimate():void;
		
		function showHits(hits:int, id:int):void;
		function hideHits(id:int):void;
		
		function showStart(finishBack:Function = null, params:Object = null):void;
		function showEnd(finishBack:Function = null, params:Object = null):void;
		
		function clearStartAndEnd():void;
		
		function pause():void;
		function resume():void;
	}
}
