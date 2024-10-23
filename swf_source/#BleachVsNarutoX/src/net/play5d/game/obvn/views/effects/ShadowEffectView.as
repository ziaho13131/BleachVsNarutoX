/**
 * 已重建完成
 */
package net.play5d.game.obvn.views.effects {
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	
	import net.play5d.kyo.utils.KyoUtils;
	
	/**
	 * 残影特效
	 */
	public class ShadowEffectView {
		
		public var target:DisplayObject;					// 渲染目标
		
		public var r:int = 0;
		public var g:int = 0;
		public var b:int = 0;
		
		public var container:Sprite;
		
		private var _bps:Vector.<Bitmap> = new Vector.<Bitmap>();
		
		private var _alphaLose:Number = 0.1;
		private var _alphaStart:Number = 0.8;
		
		private var _addBpGap:int = 1;
		private var _addBpFrame:int = 0;
		
		public var stopShadow:Boolean;						// 是否停止残影
		
		public var onRemove:Function;
		
		public function ShadowEffectView(target:DisplayObject, r:int = 0, g:int = 0, b:int = 0) {
			this.target = target;
			this.r = r;
			this.g = g;
			this.b = b;
			
			_addBpFrame = 0;
		}
		
		public function destory():void {
			target = null;
			
			for each (var bp:Bitmap in _bps) {
				bp.bitmapData.dispose();
				try {
					container.removeChild(bp);
				}
				catch (e:Error) {
				}
			}
			
			_bps = null;
		}
		
		public function render():void {
			if (stopShadow) {
				if (_bps.length <= 0) {
					removeSelf();
				}
			}
			else if (_addBpFrame++ > _addBpGap) {
				addShadowBp();
				_addBpFrame = 0;
			}
			for each (var bp:Bitmap in _bps) {
				bp.alpha -= _alphaLose;
				if (bp.alpha <= 0) {
					removeBitmap(bp);
				}
			}
		}
		
		private function addShadowBp():void {
			var ct:ColorTransform = new ColorTransform();
			
			if (r != 0 || g != 0 || b != 0) {
				ct.redOffset = r;
				ct.greenOffset = g;
				ct.blueOffset = b;
			}
			
			var bds:Rectangle = target.getBounds(target);
			var bp:Bitmap = KyoUtils.drawDisplay(target, true, true, 0, ct);
			if (bp == null) {
				return;
			}
			
			bp.alpha = _alphaStart;
			bp.x = target.x + bds.x * target.scaleX;
			bp.y = target.y + bds.y;
			bp.scaleX = target.scaleX;
			bp.scaleY = target.scaleY;
			
			container.addChildAt(bp, 0);
			_bps.push(bp);
		}
		
		private function removeBitmap(bp:Bitmap):void {
			var id:int = _bps.indexOf(bp);
			if (id != -1) {
				_bps.splice(id, 1);
			}
			try {
				container.removeChild(bp);
			}
			catch (e:Error) {
			}
			
			bp.bitmapData.dispose();
		}
		
		private function removeSelf():void {
			if (onRemove != null) {
				onRemove(this);
			}
		}
	}
}
