/**
 * 已重建完成
 */
package net.play5d.game.obvn.fighter {
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import net.play5d.game.obvn.GameConfig;
	import net.play5d.game.obvn.ctrl.EffectCtrl;
	import net.play5d.game.obvn.ctrl.GameLogic;
	import net.play5d.game.obvn.data.TeamVO;
	import net.play5d.game.obvn.fighter.models.HitVO;
	import net.play5d.game.obvn.interfaces.BaseGameSprite;
	import net.play5d.game.obvn.interfaces.IGameSprite;
	import net.play5d.game.obvn.utils.MCUtils;
	import net.play5d.kyo.utils.KyoUtils;
	
	/**
	 * 飞行道具
	 */
	public class Bullet implements IGameSprite {
		
		public var speed:Point = new Point(5, 0);
		
		public var hp:int = 100;
		public var hpMax:int = 100;
		
		public var addSpeed:Point = new Point();
		public var maxSpeed:Point = new Point(999, 999);
		public var minSpeed:Point = new Point(-999, -999);
		public var hitSpeed:Point = new Point(NaN, NaN);
		
		public var holdFrame:int = -1;
		
		private var _colorTransform:ColorTransform;
		
		public var onRemove:Function;
		public var mc:MovieClip;
		public var hitTimes:int = -1;
		public var owner:IGameSprite;
		
		private var _area:Rectangle;
		private var _orgScale:Point;
		private var _orgRotate:int;
		private var _team:TeamVO;
		private var _isHit:Boolean;
		private var _isTimeout:Boolean;
		private var _bulletArea:Rectangle;
		private var _hitVO:HitVO;
		private var _loopFrame:Object;
		private var _hitAble:Boolean = true;
		private var _speedPlus:Number = GameConfig.SPEED_PLUS;
		private var _destoryed:Boolean;
		private var _direct:int;
		private var _currentRect:Rectangle = new Rectangle();
		
		public function Bullet(mc:MovieClip, params:Object = null) {
			this.mc = mc;
			_orgScale = new Point(mc.scaleX, mc.scaleY);
			_orgRotate = mc.rotation;
			
			if (!params) {
				return;
			}
			
			if (params.x) {
				if (params.x is Number) {
					speed.x = params.x;
				}
				else {
					if (params.x.start != undefined) {
						speed.x = params.x.start;
					}
					if (params.x.add != undefined) {
						addSpeed.x = params.x.add * 2;
					}
					if (params.x.max != undefined) {
						maxSpeed.x = params.x.max;
					}
					if (params.x.min != undefined) {
						minSpeed.x = params.x.min;
					}
					if (params.x.hit != undefined) {
						hitSpeed.x = params.x.hit;
					}
				}
			}
			if (params.y) {
				if (params.y is Number) {
					speed.y = params.y;
				}
				else {
					if (params.y.start != undefined) {
						speed.y = params.y.start;
					}
					if (params.y.add != undefined) {
						addSpeed.y = params.y.add * 2;
					}
					if (params.y.max != undefined) {
						maxSpeed.y = params.y.max;
					}
					if (params.y.min != undefined) {
						minSpeed.y = params.y.min;
					}
					if (params.y.hit != undefined) {
						hitSpeed.y = params.y.hit;
					}
				}
			}
			if (params.hold) {
				if (params.hold == -1) {
					holdFrame = -1;
				}
				else {
					holdFrame = params.hold * GameConfig.FPS_GAME;
				}
			}
			if (params.hits) {
				hitTimes = params.hits;
			}
			if (params.hp) {
				hp = hpMax = params.hp;
			}
		}
		
		public function get colorTransform():ColorTransform {
			return _colorTransform;
		}
		
		public function set colorTransform(ct:ColorTransform):void {
			_colorTransform = ct;
			mc.transform.colorTransform = ct ? ct : new ColorTransform();
		}
		
		public function get x():Number {
			if (!mc) {
				return NaN;
			}
			
			return mc.x;
		}
		
		public function set x(v:Number):void {
			mc.x = v;
		}
		
		public function get y():Number {
			if (!mc) {
				return NaN;
			}
			
			return mc.y;
		}
		
		public function set y(v:Number):void {
			mc.y = v;
		}
		
		public function get team():TeamVO {
			return _team;
		}
		
		public function set team(value:TeamVO):void {
			_team = value;
		}
		
		public function isAttacking():Boolean {
			return _hitAble;
		}
		
		public function setSpeedRate(v:Number):void {
			_speedPlus = v;
		}
		
		public function setVolume(v:Number):void {
			KyoUtils.setMcVolume(mc, v);
		}
		
		public function get direct():int {
			return _direct;
		}
		
		public function set direct(value:int):void {
			_direct = value;
			
			mc.scaleX = _orgScale.x * _direct;
			mc.rotation = _orgRotate * _direct;
			mc.x *= _direct;
			speed.x *= value;
			addSpeed.x *= value;
			
			if (!isNaN(hitSpeed.x)) {
				hitSpeed.x *= value;
			}
		}
		
		public function setHitVO(v:HitVO):void {
			owner = v.owner;
			
			_hitVO = v.clone();
			_hitVO.owner = this;
			
			var mainDisplay:DisplayObject = mc.getChildByName("main");
			var ownerDisplay:DisplayObject = owner.getDisplay();
			
			if (mainDisplay) {
				_bulletArea = mainDisplay.getBounds(ownerDisplay);
				_bulletArea.x -= mc.x;
				_bulletArea.y -= mc.y;
			}
			else {
				_bulletArea = mc.getBounds(ownerDisplay);
				_bulletArea.x -= mc.x;
				_bulletArea.y -= mc.y;
			}
			
			direct = owner.direct;
			mc.x += owner.x;
			mc.y += owner.y;
			
			// 修复辅助，独立道具的主人问题
			if (owner is FighterMain) {
				var fmc:FighterMC = (owner as FighterMain).getMC();
				mc.x += fmc.x;
				mc.y += fmc.y;
				_bulletArea.x -= fmc.x;
				_bulletArea.y -= fmc.y;
			}
			else if (owner is Assister) {
				owner = (owner as Assister).getOwner();
			}
			else if (owner is FighterAttacker) {
				owner = (owner as FighterAttacker).getOwner();
			}
		}
		
		public function destory(dispose:Boolean = true):void {
			_destoryed = true;
			
			if (mc) {
				MCUtils.stopAllMovieClips(mc);
				mc = null;
			}
			speed = null;
			addSpeed = null;
			maxSpeed = null;
			minSpeed = null;
			hitSpeed = null;
			owner = null;
			_area = null;
			_orgScale = null;
			_team = null;
			_bulletArea = null;
			_hitVO = null;
		}
		
		public function isDestoryed():Boolean {
			return _destoryed;
		}
		
		public function renderAnimate():void {
			mc.nextFrame();
			
			switch (mc.currentLabel) {
				case "loop":
					if (_loopFrame == null) {
						if (MCUtils.hasFrameLabel(mc, "loop_start")) {
							_loopFrame = "loop_start";
						}
						else {
							_loopFrame = 1;
						}
					}
					mc.gotoAndStop(_loopFrame);
					break;
				case "remove":
					removeSelf();
					break;
				case "hit_over":
					_hitAble = false;
					break;
				default:
					if (mc.currentFrame == mc.totalFrames - 1) {
						removeSelf();
						break;
					}
			}
		}
		
		public function render():void {
			if (_isHit) {
				return;
			}
			
			mc.x += speed.x * _speedPlus;
			mc.y += speed.y * _speedPlus;
			
			speed.x += addSpeed.x * _speedPlus;
			speed.y += addSpeed.y * _speedPlus;
			
			if (_direct > 0) {
				if (speed.x > maxSpeed.x) {
					speed.x = maxSpeed.x;
				}
				if (speed.x < minSpeed.x) {
					speed.x = minSpeed.x;
				}
			}
			else {
				if (speed.x < -maxSpeed.x) {
					speed.x = -maxSpeed.x;
				}
				if (speed.x > -minSpeed.x) {
					speed.x = -minSpeed.x;
				}
			}
			if (speed.y > maxSpeed.y) {
				speed.y = maxSpeed.y;
			}
			if (speed.y < minSpeed.y) {
				speed.y = minSpeed.y;
			}
			
			if (holdFrame != -1 && !_isTimeout) {
				holdFrame--;
				if (holdFrame <= 0) {
					if (!MCUtils.hasFrameLabel(mc, "timeout")) {
						removeSelf();
						
						return;
					}
					
					_isTimeout = true;
					mc.gotoAndStop("timeout");
				}
			}
			
			if (GameLogic.isTouchBottomFloor(this)) {
				hit(_hitVO, null);
				EffectCtrl.I.shake(0, 1, 200);
				return;
			}
			if (GameLogic.isOutRange(this)) {
				removeSelf();
			}
		}
		
		public function getDisplay():DisplayObject {
			return mc;
		}
		
		private function removeSelf():void {
			if (onRemove != null) {
				onRemove(this);
			}
		}
		
		private function doHit():void {
			if (!_isHit) {
				try {
					mc.gotoAndStop("hit");
				}
				catch (e:Error) {
					trace("Bullet.doHit :: " + e);
				}
			}
			
			_isHit = true;
			_hitAble = false;
		}
		
		public function hit(hitvo:HitVO, target:IGameSprite):void {
			if (target is Bullet) {
				if (!isNaN(hitSpeed.x)) {
					speed.x = hitSpeed.x;
				}
				if (!isNaN(hitSpeed.y)) {
					speed.y = hitSpeed.y;
				}
				
				return;
			}
			if (hitTimes != -1) {
				hitTimes = hitTimes - 1;
				if (hitTimes <= 0) {
					doHit();
				}
			}
			
			if (target && owner && owner is FighterMain) {
				if (!hitvo.isBisha()) {
					(owner as FighterMain).addQi(hitvo.power * 0.1);
				}
				
				GameLogic.hitTarget(hitvo, owner, target);
			}
			if (target) {
				if (hitSpeed.x == 0 && hitSpeed.y == 0) {
					return;
				}
				
				if (target is BaseGameSprite && (target as BaseGameSprite).getIsTouchSide()) {
					if (isNaN(hitSpeed.x)) {
						hitSpeed.x = speed.x;
					}
					if (isNaN(hitSpeed.y)) {
						hitSpeed.y = speed.y;
					}
					
					hitSpeed.x = Math.abs(hitSpeed.x) < 1 ? 0 : Number(hitSpeed.x / 2);
					hitSpeed.y = Math.abs(hitSpeed.y) < 1 ? 0 : Number(hitSpeed.y / 2);
				}
				if (!isNaN(hitSpeed.x)) {
					speed.x = hitSpeed.x;
				}
				if (!isNaN(hitSpeed.y)) {
					speed.y = hitSpeed.y;
				}
			}
		}
		
		public function beHit(hitvo:HitVO, hitRect:Rectangle = null):void {
			if (hitvo.owner && hitvo.owner is Bullet) {
				hp -= (hitvo.owner as Bullet).hpMax;
			}
			else {
				hp -= hitvo.power;
			}
			
			if (hp <= 0) {
				doHit();
			}
		}
		
		public function getCurrentHits():Array {
			if (!_hitVO || !_bulletArea || !_hitAble) {
				return null;
			}
			
			_hitVO.currentArea = getCurrentRect(_bulletArea);
			return [_hitVO];
		}
		
		public function getArea():Rectangle {
			if (!_bulletArea) {
				return null;
			}
			
			return getCurrentRect(_bulletArea);
		}
		
		public function getBodyArea():Rectangle {
			if (!_bulletArea) {
				return null;
			}
			
			return getCurrentRect(_bulletArea);
		}
		
		private function getCurrentRect(rect:Rectangle):Rectangle {
			var newRect:Rectangle = _currentRect;
			newRect.x = rect.x * _direct + mc.x;
			
			if (_direct < 0) {
				newRect.x -= rect.width;
			}
			
			newRect.y = rect.y + mc.y;
			newRect.width = rect.width;
			newRect.height = rect.height;
			
			return newRect;
		}
		
		public function allowCrossMapXY():Boolean {
			return true;
		}
		
		public function allowCrossMapBottom():Boolean {
			return false;
		}
		
		public function getIsTouchSide():Boolean {
			return false;
		}
		
		public function setIsTouchSide(v:Boolean):void {}
	}
}
