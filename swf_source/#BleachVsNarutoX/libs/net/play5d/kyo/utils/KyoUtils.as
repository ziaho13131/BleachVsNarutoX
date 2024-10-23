/**
 * 已重建完成
 */
package net.play5d.kyo.utils {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.filters.BitmapFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.SoundTransform;
	import flash.utils.ByteArray;
	import flash.utils.describeType;
	
	/**
	 * 工具类
	 */
	public class KyoUtils {
		
		public static function array_deleteSames(array:Object):void {
			var ba:Object = array.concat();
			
			array.splice(0, array.length);
			for (var i:int = 0; i < ba.length; i++) {
				var o:Object = ba[i];
				if (array.indexOf(o) == -1) {
					array.push(o);
				}
			}
		}
		
		public static function drawDisplay(
			d:DisplayObject, fixPosition:Boolean = true,
			transparent:Boolean = true, fillColor:uint = 0, colorTransform:ColorTransform = null):Bitmap {
			if (!d || d.width <= 0 || d.height <= 0) {
				return null;
			}
			
			var bp:Bitmap = new Bitmap(new BitmapData(d.width, d.height, transparent, fillColor));
			var matrix:Matrix = null;
			if (fixPosition) {
				var bds:Rectangle = d.getBounds(d);
				matrix = new Matrix(1, 0, 0, 1, -bds.x, -bds.y);
			}
			
			bp.bitmapData.draw(d, matrix, colorTransform);
			return bp;
		}
		
		public static function drawBitmapFilter(
			d:DisplayObject, filter:BitmapFilter,
			fixPosition:Boolean = true, filterOffset:Point = null):BitmapData {
			var bpd:BitmapData = new BitmapData(d.width, d.height, true, 0);
			
			var matrix:Matrix = null;
			if (fixPosition) {
				var bds:Rectangle = d.getBounds(d);
				matrix = new Matrix(1, 0, 0, 1, -bds.x, -bds.y);
			}
			
			bpd.draw(d, matrix);
			
			var rect:Rectangle = new Rectangle(0, 0, d.width, d.height);
			if (filterOffset) {
				rect.x -= filterOffset.x;
				rect.y -= filterOffset.y;
				rect.width += filterOffset.x * 2;
				rect.height += filterOffset.y * 2;
			}
			
			var bpd2:BitmapData = new BitmapData(rect.width, rect.height, true, 0);
			bpd2.applyFilter(bpd, rect, new Point(), filter);
			bpd.dispose();
			
			return bpd2;
		}
		
		public static function num_wake(n:Number, k:Number):Number {
			if (n > 0) {
				n -= k;
				if (n < 0) {
					n = 0;
				}
			}
			if (n < 0) {
				n += k;
				if (n > 0) {
					n = 0;
				}
			}
			
			return n;
		}
		
		public static function setValueByObject(setter:*, obj:Object):void {
			if (!obj) {
				return;
			}
			
			for (var i:String in obj) {
				var tmp:* = undefined;
				try {
					tmp = setter[i];
				}
				catch (e:Error) {
				}
				
				var vv:Object = obj[i];
				if (tmp === undefined) {
					try {
						setter[i] = vv;
					}
					catch (e:Error) {
						trace("KyoUtils.setValueByObject :: " + e);
					}
				}
				else if (setter[i] is Boolean) {
					if (vv is Boolean) {
						setter[i] = vv;
					}
					else if (vv is Number) {
						setter[i] = vv == 1;
					}
					else if (vv is String) {
						setter[i] = vv == "true" || vv == "1";
					}
				}
				else if (setter[i] is Number) {
					setter[i] = Number(vv);
				}
				else {
					setter[i] = vv;
				}
			}
		}
		
		public static function cloneValue(to:*, from:*, keys:Array = null):* {
			if (keys) {
				for each(var i:String in keys) {
					to[i] = from[i];
				}
			}
			else {
				for (var j:String in from) {
					to[j] = from[j];
				}
			}
			
			return to;
		}
		
		
		public static function addFrameScript(mc:MovieClip, script:Function, frame:int = -1):void {
			var f:uint = 0;
			if (frame == -1) {
				f = mc.totalFrames - 1;
			}
			
			mc.addFrameScript(f, script);
		}
		
		public static function clone(v:Object):* {
			var myBA:ByteArray = new ByteArray();
			
			myBA.writeObject(v);
			myBA.position = 0;
			
			return myBA.readObject();
		}
		
		public static function itemToObject(item:*):Object {
			var xml:XML = describeType(item);
			var o:Object = {};
			
			for each(var j:XML in xml.variable) {
				var k:String = j.@name;
				o[k] = item[k];
			}
			
			return o;
		}
		
		
		public static function setMcVolume(mc:Sprite, volume:Number):void {
			if (!mc) {
				return;
			}
			
			var st:SoundTransform = mc.soundTransform;
			if (st) {
				st.volume = volume;
				mc.soundTransform = st;
			}
		}
	}
}
