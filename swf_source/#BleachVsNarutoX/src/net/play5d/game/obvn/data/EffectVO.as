/**
 * 已重建完成
 */
package net.play5d.game.obvn.data {
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.MovieClip;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import net.play5d.game.obvn.ctrl.AssetManager;
	import net.play5d.kyo.utils.KyoUtils;
	
	/**
	 * 特效值对象
	 */
	public class EffectVO {
		
		public var className:String;
		public var shine:Object;
		public var shake:Object;
		public var freeze:int;
		public var sound:String;
		public var randRotate:Boolean;
		public var followDirect:Boolean;
		public var slowDown:Object;
		public var blendMode:String = BlendMode.NORMAL;
		public var bitmapDataCache:Vector.<BitmapDataCacheVO>;
		public var frameLabelCache:Object;
		public var specialEffectId:String;
		public var targetColorOffset:Array;
		
		public var isSpecial:Boolean = false;
		public var isBuff:Boolean = false;
		public var isSteelHit:Boolean = false;
		
		public function EffectVO(className:String, param:Object = null) {
			this.className = className;
			KyoUtils.setValueByObject(this, param);
		}
		
		public function clone():EffectVO {
			var o:Object = KyoUtils.itemToObject(this);
			delete o["className"];
			
			return new EffectVO(className, o);
		}
		
		public function cacheBitmapData():void {
			var bounds:Rectangle = null;
			var cache:BitmapDataCacheVO = null;
			
			bitmapDataCache = new Vector.<BitmapDataCacheVO>();
			frameLabelCache = {};
			var mc:MovieClip = AssetManager.I.getEffect(className);
			mc.gotoAndStop(1);
			
			while (mc.currentFrame < mc.totalFrames) {
				var frameLabel:String = mc.currentFrameLabel;
				if (frameLabel) {
					frameLabelCache[mc.currentFrame] = frameLabel;
				}
				if (mc.width < 1 || mc.height < 1) {
					bitmapDataCache.push(null);
					mc.nextFrame();
				}
				else {
					var bd:BitmapData = new BitmapData(mc.width, mc.height, true, 0);
					bounds = mc.getBounds(mc);
					bd.draw(mc, new Matrix(1, 0, 0, 1, -bounds.x, -bounds.y));
					
					var offsetX:Number = bounds.x;
					var offsetY:Number = bounds.y;
					if (cache && 
						cache.offsetX == offsetX && cache.offsetY == offsetY && 
						cache.bitmapData.compare(bd) == 0) 
					{
						bitmapDataCache.push(cache);
						mc.nextFrame();
					}
					else {
						cache = new BitmapDataCacheVO();
						cache.bitmapData = bd;
						cache.offsetX = offsetX;
						cache.offsetY = offsetY;
						bitmapDataCache.push(cache);
						mc.nextFrame();
					}
				}
			}
			
			mc = null;
			bounds = null;
			cache = null;
		}
	}
}
