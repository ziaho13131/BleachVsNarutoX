/**
 * 已重建完成
 */
package net.play5d.game.obvn.ui {
	import com.greensock.TweenLite;
	import com.greensock.easing.Elastic;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.ColorTransform;
	
	import net.play5d.game.obvn.ctrl.AssetManager;
	import net.play5d.game.obvn.ctrl.SoundCtrl;
	import net.play5d.game.obvn.utils.ResUtils;
	import net.play5d.kyo.display.BitmapText;
	import net.play5d.kyo.display.bitmap.BitmapFontText;
	
	/**
	 * 主菜单按钮类
	 */
	public class MenuBtn extends EventDispatcher {
		
		
		public var ui:MovieClip;
		
		public var cn:String;						// 中文
		public var label:String;					// 标题
		
		public var func:Function;					// 点击后执行函数
		
		public var height:Number = 75;
		
		public var index:int;						// 索引
		
		public var children:Array;					// 子按钮组
		
		private var _bitmapText:BitmapFontText;
		private var _cnTxt:BitmapText;
		private var _listeners:Object = {};
		
		private var _isOpen:Boolean;
		
		public function MenuBtn(label:String, cn:String = "", func:Function = null) {
			this.cn = cn;
			this.label = label;
			this.func = func;
			
			_bitmapText = new BitmapFontText(AssetManager.I.getFont("font1"));
			_bitmapText.text = label;
			_bitmapText.x = -_bitmapText.width / 2;
			
			ui = ResUtils.I.createDisplayObject(ResUtils.I.common_ui, "mc_wzbtn");
			ui.buttonMode = true;
			ui.mouseChildren = false;
			ui.addChild(_bitmapText);
			ui.bg.mouseEnabled = false;
			ui.bg.mouseChildren = false;
			ui.bg.visible = false;
			
			if (GameUI.SHOW_CN_TEXT) {
				_cnTxt = new BitmapText();
				UIUtils.formatText(_cnTxt.textfield, {
					font: "SimHei",
					size: 18
				});
				
				_cnTxt.text = cn;
				_cnTxt.x = 10;
				_cnTxt.y = 45;
				
				ui.bg.addChild(_cnTxt);
			}
		}
		
		override public function addEventListener(
			type:String, listener:Function,
			useCapture:Boolean = false, priority:int = 0,
			useWeakReference:Boolean = false):void 
		{
			if (ui.hasEventListener(type)) {
				return;
			}
			
			ui.addEventListener(type, selfHandler, useCapture, priority, useWeakReference);
			_listeners[type] = listener;
		}
		
		/**
		 * 移除全部侦听器
		 */
		public function removeAllEventListener():void {
			for (var i:String in _listeners) {
				ui.removeEventListener(i, _listeners[i]);
			}
			
			_listeners = {};
		}
		
		private function selfHandler(e:Event):void {
			var listener:Function = _listeners[e.type];
			listener(e.type, this);
		}
		
		public function isHover():Boolean {
			return ui.bg.visible;
		}
		
		public function hover():void {
			if (_isOpen) {
				return;
			}
			if (ui.bg.visible) {
				return;
			}
			ui.bg.visible = true;
			
			ui.bg.scaleX = 0.01;
			TweenLite.to(ui.bg, 0.2, {scaleX: 1});
			
			SoundCtrl.I.sndSelect();
		}
		
		public function normal():void {
			if (_isOpen) {
				return;
			}
			
			ui.bg.visible = false;
		}
		
		public function select(back:Function = null):void {
			ui.alpha = -1;
			
			TweenLite.to(ui, 1, {
				alpha     : 1,
				ease      : Elastic.easeOut,
				onComplete: back
			});
			
			SoundCtrl.I.sndConfrim();
		}
		
		public function openChild():void {
			if (_isOpen) {
				return;
			}
			
			_isOpen = true;
			ui.bg.gotoAndStop(2);
			
			var ct:ColorTransform = new ColorTransform();
			ct.redOffset = 50;
			ct.greenOffset = -30;
			ct.blueOffset = -30;
			
			_bitmapText.colorTransform(ct);
		}
		
		public function closeChild():void {
			if (!_isOpen) {
				return;
			}
			
			_isOpen = false;
			ui.bg.gotoAndStop(1);
			
			_bitmapText.colorTransform(null);
		}
		
		public function dispose():void {
			if (_bitmapText) {
				_bitmapText.dispose();
				_bitmapText = null;
			}
			
			removeAllEventListener();
			
			if (children) {
				for each(var b:MenuBtn in children) {
					b.dispose();
				}
				children = null;
			}
			
			if (_cnTxt) {
				_cnTxt.destory();
				_cnTxt = null;
			}
		}
		
		/**
		 * 子按钮模式
		 */
		public function childMode():void {
			var ct:ColorTransform = new ColorTransform();
			ct.redOffset = 50;
			ct.greenOffset = -30;
			ct.blueOffset = -30;
			
			_bitmapText.colorTransform(ct);
			_bitmapText.scaleY = 0.75;
			_bitmapText.scaleX = 0.75;
			_bitmapText.x = -_bitmapText.width / 2;
			
			ui.bg.scaleY = 0.75;
			ui.bg.scaleX = 0.9;
			ui.bg.gotoAndStop(2);
			
			height = 55;
		}
	}
}
