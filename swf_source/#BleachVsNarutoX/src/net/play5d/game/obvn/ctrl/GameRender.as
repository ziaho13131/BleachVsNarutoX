/**
 * 已重建完成
 */
package net.play5d.game.obvn.ctrl {
	import flash.display.Stage;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	/**
	 * 游戏渲染
	 */
	public class GameRender {
		
		private static var _funcs:Dictionary = new Dictionary();
		public static var isRender:Boolean = true;
		
		public static function initlize(stage:Stage):void {
			stage.addEventListener(Event.ENTER_FRAME, render);
		}
		
		public static function add(func:Function, owner:* = null):void {
			if (!owner) {
				owner = "anyone";
			}
			if (_funcs[owner] && _funcs[owner].indexOf(func) != -1) {
				return;
			}
			
			_funcs[owner] ||= new Vector.<Function>();
			_funcs[owner].push(func);
		}
		
		public static function remove(func:Function, owner:* = null):void {
			if (!owner) {
				owner = "anyone";
			}
			if (!_funcs[owner]) {
				return;
			}
			
			var id:int = _funcs[owner].indexOf(func);
			if (id != -1) {
				_funcs[owner].splice(id, 1);
			}
		}
		
		private static function render(e:Event):void {
			if (!isRender) {
				return;
			}
			
			for each (var v:Vector.<Function> in _funcs) {
				for each (var func:Function in v) {
					func();
				}
			}
		}
	}
}
