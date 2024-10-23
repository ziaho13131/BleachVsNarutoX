/**
 * 已重建完成
 */
package net.play5d.game.obvn.views.effects {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.PixelSnapping;
	import flash.utils.getTimer;
	
	import net.play5d.game.obvn.GameConfig;
	
	/**
	 * 闪屏特效
	 */
	public class ShineEffectView extends Bitmap {
		
		
		public var onRemove:Function;
		
		public var isActive:Boolean = true;
		private var _loseAlpha:Number = 1;
		private var _alpha:int;
		
		private var _renderGap:int = 0;
		private var _renderFrame:int;
		
		private var _isDestoryed:Boolean;
		
		private var _startTimer:int;
		private var _frameTime:int;
//		private const _skipFrameRate:Number = 1.2;
		
		public function ShineEffectView() {
			super(null, PixelSnapping.NEVER, false);
		}
		
		public function destory():void {
			_isDestoryed = true;
			
			if (isActive) {
				removeSelf();
			}
		}
		
		public function init(color:uint = 0xffffff, alpha:Number = 0.2):void {
			if (bitmapData) {
				bitmapData.dispose();
				bitmapData = null;
			}
			
			bitmapData = new BitmapData(GameConfig.GAME_SIZE.x / 10, GameConfig.GAME_SIZE.y / 10, false, color);
			
			width = GameConfig.GAME_SIZE.x;
			height = GameConfig.GAME_SIZE.y;
			
			isActive = true;
			
			const halfC:Number = 0x7fffff;
			if (color > halfC) {
				blendMode = BlendMode.ADD;
			}
			else {
				blendMode = BlendMode.DARKEN;
				alpha *= 0.8;
			}
			
			this.alpha = alpha;
			
			_alpha = alpha * 100;
			_renderFrame = 0;
			_renderGap = Math.ceil(GameConfig.FPS_GAME / GameConfig.FPS_SHINE_EFFECT) - 1;
			_startTimer = 0;
			_loseAlpha = _renderGap + 1;
			_frameTime = 1000 / GameConfig.FPS_SHINE_EFFECT;
		}
		
		public function render():void {
			if (_isDestoryed) {
				return;
			}
			
			if (_renderGap > 0) {
				_renderFrame++;
				if (_renderFrame % _renderGap != 0) {
					return;
				}
			}
			
			skipFrame();
			_alpha -= _loseAlpha;
			
			if (_alpha <= 5) {
				removeSelf();
			}
			else {
				this.alpha = _alpha * 0.01;
			}
		}
		
		private function skipFrame():void {
			if (_startTimer != 0) {
				var frameTime:int = getTimer() - _startTimer;
				var rate:Number = frameTime / _frameTime;
				
				if (rate > 1.2) {
					var la:int = Math.ceil(_loseAlpha * rate);
					
					if (_loseAlpha < la) {
						_loseAlpha = la;
					}
				}
			}
			
			_startTimer = getTimer();
		}
		
		public function removeSelf():void {
			isActive = false;
			if (bitmapData) {
				bitmapData.dispose();
				bitmapData = null;
			}
			
			if (parent) {
				try {
					parent.removeChild(this);
				}
				catch (e:Error) {
				}
			}
			
			if (onRemove != null) {
				onRemove(this);
			}
		}
	}
}
