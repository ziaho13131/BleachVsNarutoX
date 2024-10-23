/**
 * 已重建完成
 */
package net.play5d.kyo.utils {
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * 设置帧延迟
	 */
	public function setFrameOut(fun:Function, frame:int, mc:DisplayObject = null):void {
		var ii:int = 0;
		var mx:int = frame;
		
		var _mc:DisplayObject = mc;
		_mc ||= new Sprite();
		_mc.addEventListener(Event.ENTER_FRAME, onEnterframe);
		
		function onEnterframe(e:Event):void {
			if (++ii > mx) {
				fun();
				_mc.removeEventListener(Event.ENTER_FRAME, onEnterframe);
				_mc = null;
			}
		}
	}
}
