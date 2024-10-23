/**
 * 已重建完成
 */
package net.play5d.game.obvn.views.effects {
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.PixelSnapping;
	import flash.filters.BitmapFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import net.play5d.game.obvn.data.TeamVO;
	import net.play5d.game.obvn.fighter.FighterMain;
	import net.play5d.game.obvn.fighter.models.HitVO;
	import net.play5d.game.obvn.interfaces.BaseGameSprite;
	import net.play5d.game.obvn.interfaces.IGameSprite;
	import net.play5d.kyo.utils.KyoUtils;
	
	/**
	 * 位图滤镜渲染元件
	 */
	public class BitmapFilterView implements IGameSprite {
		
		private var _bitmap:Bitmap;
		public var target:BaseGameSprite;
		
		private var _filter:BitmapFilter;
		private var _filterOffset:Point;
		
		private var _isDestoryed:Boolean;
		
		private var _bitmapFrame:int;
		
		private var _targetDisplay:DisplayObject;
		private var _targetBounds:Rectangle;
		private var _targetFighter:FighterMain;
		
		public function BitmapFilterView(target:BaseGameSprite, filter:BitmapFilter, filterOffset:Point = null) {
			_bitmap = new Bitmap(null, PixelSnapping.AUTO, false);
			this.target = target;
			
			if (target is FighterMain) {
				_targetFighter = target as FighterMain;
			}
			
			_targetDisplay = target.getDisplay();
			_filter = filter;
			_filterOffset = filterOffset;
		}
		
		public function setVolume(v:Number):void {}
		
		public function update(filter:BitmapFilter, filterOffset:Point = null):void {
			_filter = filter;
			_filterOffset = filterOffset;
		}
		
		public function renderAnimate():void {}
		
		public function render():void {
			if (!target || !_targetDisplay) {
				return;
			}
			if (_isDestoryed) {
				return;
			}
			
			renderBitmapData();
			if (_targetBounds == null) {
				return;
			}
			
			_bitmap.scaleX = _targetDisplay.scaleX;
			_bitmap.scaleY = _targetDisplay.scaleY;
			
			if (target.direct > 0) {
				_bitmap.x = _targetDisplay.x - _filterOffset.x + _targetBounds.x;
			}
			else {
				_bitmap.x = _targetDisplay.x + _filterOffset.x - _targetBounds.x;
			}
			_bitmap.y = _targetDisplay.y - _filterOffset.y + _targetBounds.y;
		}
		
		private function renderBitmapData():void {
			if (_targetFighter) {
				var curFrame:int = _targetFighter.getMC().getCurrentFrameCount();
				if (curFrame == _bitmapFrame) {
					return;
				}
				
				_bitmapFrame = curFrame;
			}
			if (_bitmap.bitmapData) {
				_bitmap.bitmapData.dispose();
				_bitmap.bitmapData = null;
			}
			if (_targetDisplay.width != 0 && _targetDisplay.height != 0) {
				_bitmap.bitmapData = KyoUtils.drawBitmapFilter(_targetDisplay, _filter, true, _filterOffset);
			}
			
			_targetBounds = _targetDisplay.getBounds(_targetDisplay);
		}
		
		public function isDestoryed():Boolean {
			return _isDestoryed;
		}
		
		public function getDisplay():DisplayObject {
			return _bitmap;
		}
		
		public function get colorTransform():ColorTransform {
			return null;
		}
		
		public function set colorTransform(ct:ColorTransform):void {}
		
		public function get direct():int {
			return target.direct;
		}
		
		public function set direct(value:int):void {
			target.direct = value;
		}
		
		public function get x():Number {
			return _bitmap.x;
		}
		
		public function set x(v:Number):void {
			_bitmap.x = v;
		}
		
		public function get y():Number {
			return _bitmap.y;
		}
		
		public function set y(v:Number):void {
			_bitmap.y = v;
		}
		
		public function get team():TeamVO {
			return null;
		}
		
		public function set team(v:TeamVO):void {}
		
		public function hit(hitvo:HitVO, target:IGameSprite):void {}
		
		public function beHit(hitvo:HitVO, hitRect:Rectangle = null):void {}
		
		public function getArea():Rectangle {
			return null;
		}
		
		public function getBodyArea():Rectangle {
			return null;
		}
		
		public function getCurrentHits():Array {
			return null;
		}
		
		public function allowCrossMapXY():Boolean {
			return true;
		}
		
		public function allowCrossMapBottom():Boolean {
			return true;
		}
		
		public function getIsTouchSide():Boolean {
			return false;
		}
		
		public function setIsTouchSide(v:Boolean):void {}
		
		public function setSpeedRate(v:Number):void {}
		
		public function destory(dispose:Boolean = true):void {
			if (dispose) {
				if (_bitmap.bitmapData) {
					_bitmap.bitmapData.dispose();
					_bitmap.bitmapData = null;
				}
				
				_isDestoryed = true;
				target = null;
				_filter = null;
				_filterOffset = null;
				_targetFighter = null;
				_targetBounds = null;
				_targetDisplay = null;
			}
		}
	}
}
