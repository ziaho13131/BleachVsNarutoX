/**
 * 已重建完成
 */
package net.play5d.game.obvn.fighter {
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import net.play5d.game.obvn.ctrl.GameLogic;
	import net.play5d.game.obvn.data.FighterVO;
	import net.play5d.game.obvn.fighter.ctrler.AssisiterCtrler;
	import net.play5d.game.obvn.fighter.models.FighterHitModel;
	import net.play5d.game.obvn.fighter.models.HitVO;
	import net.play5d.game.obvn.fighter.utils.McAreaCacher;
	import net.play5d.game.obvn.interfaces.BaseGameSprite;
	import net.play5d.game.obvn.interfaces.IGameSprite;
	
	/**
	 * 辅助
	 */
	public class Assister extends BaseGameSprite {
		
		public var onRemove:Function;
		public var data:FighterVO;
		public var isAttacking:Boolean;
		
		private var _hitAreaCache:McAreaCacher = new McAreaCacher("hit");
		private var _hitCheckAreaCache:McAreaCacher = new McAreaCacher("hit_check");
		private var _rectCache:Object = {};
		private var _mcOrgPoint:Point;
		private var _owner:IGameSprite;
		private var _isRenderMainAnimate:Boolean = true;
		private var _ctrler:AssisiterCtrler;
		
		private var _customFunc:Function = null;			// 自定义跟随渲染函数
		
		public function Assister(mainmc:MovieClip) {
			super(mainmc);
			
			if (_mainMc.setAssistCtrler) {
				_ctrler = new AssisiterCtrler();
				_ctrler.initAssister(this);
				
				_mainMc.setAssistCtrler(_ctrler);
				return;
			}
			
			throw new Error("Failed to initialize, SWF not define setAssistCtrler()");
		}
		
		public function get name():String {
			return _mainMc.name;
		}
		
		public function getOwner():IGameSprite {
			return _owner;
		}
		
		public function setOwner(v:IGameSprite):void {
			_owner = v;
		}
		
		public function getCtrler():AssisiterCtrler {
			return _ctrler;
		}
		
		public function goFight():void {
			removeCustomFunc();
			isAttacking = true;
			isOnStage = true;
			
			gotoAndPlay(2);
		}
		
		override public function destory(dispose:Boolean = true):void {
			if (!dispose) {
				return;
			}
			
			if (_hitAreaCache) {
				_hitAreaCache.destory();
				_hitAreaCache = null;
			}
			if (_hitCheckAreaCache) {
				_hitCheckAreaCache.destory();
				_hitCheckAreaCache = null;
			}
			if (_ctrler) {
				_ctrler.destory();
				_ctrler = null;
			}
			
			removeCustomFunc();
			onRemove = null;
			data = null;
			_rectCache = null;
			_mcOrgPoint = null;
			_owner = null;
			
			super.destory(dispose);
		}
		
		public function stop():void {
			_isRenderMainAnimate = false;
		}
		
		public function gotoAndPlay(frame:Object):void {
			_mainMc.gotoAndStop(frame);
			_isRenderMainAnimate = true;
		}
		
		public function gotoAndStop(frame:Object):void {
			_mainMc.gotoAndStop(frame);
			_isRenderMainAnimate = false;
		}
		
		public function getTargets():Vector.<IGameSprite> {
			if (!_owner is FighterMain) {
				return null;
			}
			
			return (_owner as FighterMain).getTargets();
		}
		
		public function removeSelf():void {
			isAttacking = false;
			isAlive = false;
			isOnStage = false;
			
			// 关闭残影
			_ctrler.effect.endShadow();
			
			if (onRemove != null) {
				onRemove(this);
			}
		}
		
		override public function render():void {
			super.render();
			_ctrler.render();
		}
		
		override public function renderAnimate():void {
			if (!_isRenderMainAnimate) {
				return;
			}
			
			super.renderAnimate();
			renderChildren();
			mc.nextFrame();
			if (mc == null) {
				return;
			}
			// 执行自定义函数
			if (_customFunc != null) {
				_customFunc();
			}
			
			findHitArea();
			if (mc.currentFrame == mc.totalFrames - 1 || 
				!(_owner as BaseGameSprite).isAlive) 
			{
				_ctrler.finish(true);
			}
		}
		
		private function renderChildren():void {
			for (var i:int = 0; i < _mainMc.numChildren; i++) {
				var mc:MovieClip = _mainMc.getChildAt(i) as MovieClip;
				if (!mc) {
					continue;
				}
				
				var mcName:String = mc.name;
				if (mcName == "bdmn" || mcName.indexOf("atm") != -1) {
					continue;
				}
				
				var totalFrames:int = mc.totalFrames;
				if (totalFrames >= 2) {
					if (mc.currentFrameLabel != "stop") {
						if (mc.currentFrame == totalFrames) {
							mc.gotoAndStop(1);
						}
						else {
							mc.nextFrame();
						}
					}
				}
			}
		}
		
		public function getHitCheckRect(name:String):Rectangle {
			var area:Rectangle = getCheckHitRect(name);
			if (area == null) {
				return null;
			}
			
			return getCurrentRect(area, "hit_check");
		}
		
		public function getCheckHitRect(name:String):Rectangle {
			var d:DisplayObject = _mainMc.getChildByName(name);
			if (!d) {
				return null;
			}
			
			var cacheObj:Object = _hitCheckAreaCache.getAreaByDisplay(d);
			if (cacheObj) {
				return cacheObj.area;
			}
			
			var rect:Rectangle = d.getBounds(_mainMc);
			_hitCheckAreaCache.cacheAreaByDisplay(d, rect);
			
			return rect;
		}
		
		private function getCurrentRect(rect:Rectangle, cacheId:String = null):Rectangle {
			var newRect:Rectangle = null;
			
			if (cacheId == null) {
				newRect = new Rectangle();
			}
			else if (_rectCache[cacheId]) {
				newRect = _rectCache[cacheId];
			}
			else {
				newRect = new Rectangle();
				_rectCache[cacheId] = newRect;
			}
			
			newRect.x = rect.x * direct + _x;
			if (direct < 0) {
				newRect.x -= rect.width;
			}
			newRect.y = rect.y + _y;
			newRect.width = rect.width;
			newRect.height = rect.height;
			
			return newRect;
		}
		
		private function findHitArea():void {
			if (!_hitAreaCache) {
				return;
			}
			
			if (_hitAreaCache.areaFrameDefined(_mainMc.currentFrame)) {
				return;
			}
			
			var area:Object = _hitAreaCache.getAreaByFrame(_mainMc.currentFrame);
			if (area != null) {
				return;
			}
			
			var hitModel:FighterHitModel = _ctrler.hitModel;
			var areaRects:Array = [];
			for (var i:int = 0; i < _mainMc.numChildren; i++) {
				var d:DisplayObject = _mainMc.getChildAt(i);
				var hitvo:HitVO = hitModel.getHitVO(d.name);
				
				if (d == null || hitvo == null) {
					continue;
				}
				
				var areaCached:Object = _hitAreaCache.getAreaByDisplay(d);
				if (areaCached == null) {
					var areaRect:Rectangle = d.getBounds(_mainMc);
					var areaCacheObj:Object = _hitAreaCache.cacheAreaByDisplay(d, areaRect, {
						hitVO: hitvo
					});
					areaRects.push(areaCacheObj);
				}
				else {
					areaRects.push(areaCached);
				}
			}
			
			if (areaRects.length < 1) {
				areaRects = null;
			}
			
			_hitAreaCache.cacheAreaByFrame(_mainMc.currentFrame, areaRects);
		}
		
		override public function hit(hitvo:HitVO, target:IGameSprite):void {
			if (target && _owner && _owner is FighterMain) {
				(_owner as FighterMain).addQi(hitvo.power * 0.15);
				GameLogic.hitTarget(hitvo, _owner, target);
			}
		}
		
		override public function getCurrentHits():Array {
			if (!_hitAreaCache) {
				return null;
			}
			
			var areas:Array = _hitAreaCache.getAreaByFrame(_mainMc.currentFrame) as Array;
			if (!areas || areas.length < 1) {
				return null;
			}
			
			var hits:Array = [];
			for (var i:int = 0; i < areas.length; i++) {
				var dobj:Object = areas[i]
				var dname:String = dobj.name;
				var hitvo:HitVO = dobj.hitVO;
				
				if (hitvo) {
					var area:Rectangle = dobj.area;
					
					hitvo.currentArea = getCurrentRect(area, "hit" + i);
					hits.push(hitvo);
				}
			}
			
			return hits;
		}
		
		public function getCurrentTarget():IGameSprite {
			if (_owner is FighterMain) {
				return (_owner as FighterMain).getCurrentTarget();
			}
			
			return null;
		}
		
		public function addCustomFunc(func:Function = null):void {
			if (func == null || _customFunc != null) {
				return;
			}
			
			_customFunc = func;
		}
		
		public function removeCustomFunc():void {
			if (_customFunc != null) {
				_customFunc = null;
			}
		}
	}
}
