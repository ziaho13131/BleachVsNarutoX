/**
 * 已重建完成
 */
package net.play5d.kyo.display {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.filters.BitmapFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * 位图文本
	 */
	public class BitmapText extends Bitmap {
		
		public var autoUpdate:Boolean;
		
		private var _tf:TextField;
		private var _filers:Array;
		
		public function BitmapText(autoUpdate:Boolean = true, color:uint = 0, filers:Array = null) {
			this.autoUpdate = autoUpdate;
			this.smoothing = true;
			this._filers = filers;
			this._tf = new TextField();
			this.color = color;
		}
		
		override public function set width(value:Number):void {
			_tf.width = value;
		}
		
		override public function set height(value:Number):void {
			_tf.height = value;
		}
		
		public function get textfield():TextField {
			return _tf;
		}
		
//		public function get font():String {
//			return defaultTextFormat.font;
//		}
		
		public function set font(v:String):void {
			defaultTextFormat.font = v;
			if (autoUpdate) {
				update();
			}
		}
		
//		public function get fontSize():Object {
//			return defaultTextFormat.size;
//		}
//
//		public function set fontSize(v:Object):void {
//			defaultTextFormat.size = v;
//			if (autoUpdate) {
//				update();
//			}
//		}
		
		public function get color():uint {
			return defaultTextFormat.color as uint;
		}
		
		public function set color(value:uint):void {
			defaultTextFormat.color = value;
			if (autoUpdate) {
				update();
			}
		}
		
//		public function get align():String {
//			return defaultTextFormat.align;
//		}
//
//		public function set align(value:String):void {
//			defaultTextFormat.align = value;
//		}
		
		public function get text():String {
			return _tf.text;
		}
		
		public function set text(value:String):void {
			_tf.text = value;
			if (autoUpdate) {
				update();
			}
		}
		
//		public function setTextFormat(f:TextFormat, beginIndex:int = -1, endIndex:int = -1):void {
//			_tf.setTextFormat(f, beginIndex, endIndex);
//			if (autoUpdate) {
//				update();
//			}
//		}
		
		public function get defaultTextFormat():TextFormat {
			if (!_tf.defaultTextFormat) {
				_tf.defaultTextFormat = new TextFormat();
			}
			return _tf.defaultTextFormat;
		}
		
//		public function set defaultTextFormat(v:TextFormat):void {
//			_tf.defaultTextFormat = v;
//			if (autoUpdate) {
//				update();
//			}
//		}
//
//		public function get textWidth():Number {
//			return _tf.width;
//		}
//
//		public function set textWidth(v:Number):void {
//			_tf.width = v;
//		}
//
//		public function get textHeight():Number {
//			return _tf.height;
//		}
//
//		public function set textHeight(v:Number):void {
//			_tf.height = v;
//		}
		
		public function update():void {
			if (!_tf) {
				return;
			}
			
			_tf.height = _tf.textHeight + 10;
			_tf.defaultTextFormat = defaultTextFormat;
			var bd:BitmapData = new BitmapData(_tf.width + 10, _tf.height, true, 0);
			bd.draw(_tf);
			if (_filers) {
				for each(var i:BitmapFilter in _filers) {
					bd.applyFilter(bd, new Rectangle(0, 0, bd.width, bd.height), new Point(), i);
				}
			}
			if (bitmapData) {
				bitmapData.dispose();
			}
			bitmapData = bd;
		}
		
		public function destory():void {
			try {
				parent.removeChild(this);
			}
			catch (e:Error) {
			}
			
			bitmapData.dispose();
			_tf = null;
		}
	}
}
