/**
 * 已重建完成
 */
package net.play5d.game.obvn.ui.select {
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	
	import net.play5d.game.obvn.ctrl.AssetManager;
	import net.play5d.game.obvn.data.FighterVO;
	import net.play5d.game.obvn.data.SelectCharListItemVO;
	import net.play5d.game.obvn.utils.ResUtils;
	
	/**
	 * 选择角色节点
	 */
	public class SelectFighterItem extends EventDispatcher {
		
		public var selectData:SelectCharListItemVO;
		public var fighterData:FighterVO;
		public var ui:MovieClip = ResUtils.I.createDisplayObject(ResUtils.I.select, "slt_item_mc");
//		public var position:Point = new Point();
		
//		private var faceSize:Point = new Point(50, 50);
		private var _listeners:Object = {};
		
		public function SelectFighterItem(fighterData:FighterVO, selectData:SelectCharListItemVO) {
			this.selectData = selectData;
			this.fighterData = fighterData;
			var face:DisplayObject = AssetManager.I.getFighterFace(fighterData);
			if (face) {
				ui.ct.addChild(face);
			}
			
			ui.mouseChildren = false;
			ui.buttonMode = true;
		}
		
		override public function addEventListener(
			type:String, listener:Function,
			useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void 
		{
			if (ui.hasEventListener(type)) {
				return;
			}
			
			ui.addEventListener(type, selfHandler, useCapture, priority, useWeakReference);
			_listeners[type] = listener;
		}
		
		public function removeAllEventListener():void {
			for (var i:String in _listeners) {
				ui.removeEventListener(i, _listeners[i]);
			}
			
			_listeners = {};
		}
		
		private function selfHandler(e:Event):void {
			var listener:Function = _listeners[e.type] as Function;
			if (listener != null) {
				listener(e.type, this);
			}
		}
		
		public function destory():void {
			if (ui) {
				removeAllEventListener();
			}
			if (ui && ui.parent) {
				try {
					ui.parent.removeChild(ui);
				}
				catch (e:Error) {
				}
				
				ui = null;
			}
		}
	}
}
