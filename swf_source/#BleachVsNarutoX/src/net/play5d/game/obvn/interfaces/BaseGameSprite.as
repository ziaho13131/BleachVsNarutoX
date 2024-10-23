/**
 * 已重建完成
 */
package net.play5d.game.obvn.interfaces {
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.SoundTransform;
	
	import net.play5d.game.obvn.Debugger;
	import net.play5d.game.obvn.GameConfig;
	import net.play5d.game.obvn.ctrl.GameRender;
	import net.play5d.game.obvn.data.TeamVO;
	import net.play5d.game.obvn.fighter.models.HitVO;
	import net.play5d.game.obvn.utils.MCUtils;
	import net.play5d.kyo.utils.KyoUtils;
	import net.play5d.kyo.utils.UUID;
	
	/**
	 * 基本游戏精灵
	 */
	public class BaseGameSprite extends EventDispatcher implements IGameSprite {
		
		public var isInAir:Boolean;
		public var isTouchBottom:Boolean;
		public var isAllowBeHit:Boolean = true;
		public var isCross:Boolean = false;
		public var isAlive:Boolean = true;
		public var isAllowLoseHP:Boolean = true;
		public var isApplyG:Boolean = true;
		public var isOnStage:Boolean = false;				// 判断是否正在场上
		
		public var heavy:Number = 2;
		public var hp:Number = 1000;
		public var hpMax:Number = 1000;
		public var defense:Number = 0;
		
		public var isAllowCrossX:Boolean = false;
		public var isAllowCrossBottom:Boolean = false;
		
		private var _attackRate:Number = 1;
		private var _defenseRate:Number = 1;
		
		public var id:String = UUID.create();
		
		protected var _colorTransform:ColorTransform;
		
		protected var _x:Number = 0;
		protected var _y:Number = 0;
		protected var _g:Number = 0;
		
		protected var _mainMc:MovieClip;
		
		protected var _isTouchSide:Boolean = false;
		
		protected var _area:Rectangle;
		
		private var _direct:int = 1;
		private var _scale:Number = 1;
		
		private var _frameFuncs:Array = [];
		private var _frameAnimateFuncs:Array = [];
		
		private var _team:TeamVO;
		
		private var _speedPlus:Number = GameConfig.SPEED_PLUS;
		private var _dampingRate:Number = 1;
		private var _velocity:Point = new Point();
		private var _damping:Point = new Point();
		private var _velocity2:Point = new Point();
		private var _damping2:Point = new Point();
		
		protected var _destoryed:Boolean;
		
		public function BaseGameSprite(mainmc:MovieClip) {
			_mainMc = mainmc;
			
			if (_mainMc) {
				_area = _mainMc.getBounds(_mainMc);
			}
		}
		
		public function get attackRate():Number {
			return _attackRate;
		}
		
		public function set attackRate(value:Number):void {
			_attackRate = value;
		}
		
		public function get defenseRate():Number {
			return _defenseRate;
		}
		
		public function set defenseRate(value:Number):void {
			_defenseRate = value;
		}
		
		public function get mc():MovieClip {
			return _mainMc;
		}
		
		public function get colorTransform():ColorTransform {
			return _colorTransform;
		}
		
		public function set colorTransform(ct:ColorTransform):void {
			_colorTransform = ct;
			_mainMc.transform.colorTransform = ct ? ct : new ColorTransform();
		}
		
		public function get x():Number {
			return _x;
		}
		
		public function set x(v:Number):void {
			_x = v;
		}
		
		public function get y():Number {
			return _y;
		}
		
		public function set y(v:Number):void {
			_y = v;
		}
		
		public function get scale():Number {
			return _scale;
		}
		
		public function set scale(v:Number):void {
			_scale = v;
			_mainMc.scaleX = _mainMc.scaleY = v;
		}
		
		public function get direct():int {
			return _direct;
		}
		
		public function set direct(value:int):void {
			_direct = value;
			_mainMc.scaleX = _direct * _scale;
		}
		
		public function get team():TeamVO {
			return _team;
		}
		
		public function set team(value:TeamVO):void {
			_team = value;
		}
		
		public function updatePosition():void {
			_mainMc.x = _x;
			_mainMc.y = _y;
		}
		
		public function setVolume(v:Number):void {
			var transform:SoundTransform = null;
			if (_mainMc) {
				transform = _mainMc.soundTransform;
				if (transform) {
					transform.volume = v;
					_mainMc.soundTransform = transform;
				}
			}
		}
		
		public function isDestoryed():Boolean {
			return _destoryed;
		}
		
		public function destory(dispose:Boolean = true):void {
			_destoryed = true;
			isAlive = false;
			isAllowBeHit = false;
			isOnStage = false;
			stopRenderSelf();
			if (dispose) {
				if (_mainMc) {
					MCUtils.stopAllMovieClips(_mainMc);
					
					_mainMc = null;
				}
				
				_area = null;
			}
		}
		
		public function renderAnimate():void {
			if (_destoryed) {
				return;
			}
			
			renderAnimateFrameOut();
		}
		
		public function render():void {
			if (_destoryed) {
				return;
			}
			
			renderVelocity();
			renderFrameOut();
			_mainMc.x = _x;
			_mainMc.y = _y;
		}
		
		public function getDisplay():DisplayObject {
			return _mainMc;
		}
		
		public function move(x:Number = 0, y:Number = 0):void {
			if (x != 0) {
				_x += x * _speedPlus;
			}
			if (y != 0) {
				_y += y * _speedPlus;
			}
		}
		
		public function setSpeedRate(v:Number):void {
			_speedPlus = v;
			_dampingRate = v / GameConfig.SPEED_PLUS_DEFAULT;
		}
		
		public function getVelocity():Point {
			return _velocity;
		}
		
		public function getVecX():Number {
			return _velocity.x;
		}
		
		public function getVecY():Number {
			return _velocity.y;
		}
		
		public function setVecX(v:Number):void {
			_velocity.x = v;
		}
		
		public function setVecY(v:Number):void {
			_velocity.y = v;
		}
		
		public function setVelocity(x:Number = 0, y:Number = 0):void {
			_velocity.x = x;
			_velocity.y = y;
			setDamping(0, 0);
		}
		
		public function addVelocity(x:Number = 0, y:Number = 0):void {
			_velocity.x += x;
			_velocity.y += y;
		}
		
		public function setVec2(x:Number = 0, y:Number = 0, dampingX:Number = 0, dampingY:Number = 0):void {
			_velocity2.x = x;
			_velocity2.y = y;
			
			_damping2.x = dampingX * GameConfig.SPEED_PLUS_DEFAULT * 6;
			_damping2.y = dampingY * GameConfig.SPEED_PLUS_DEFAULT * 6;
		}
		
		public function getVec2():Point {
			return _velocity2;
		}
		
		public function getDampingX():Number {
			return _damping.x;
		}
		
		public function getDampingY():Number {
			return _damping.y;
		}
		
		public function setDampingX(v:Number):void {
			_damping.x = v;
		}
		
		public function setDampingY(v:Number):void {
			_damping.y = v;
		}
		
		public function setDamping(x:Number = 0, y:Number = 0):void {
			_damping.x = x * GameConfig.SPEED_PLUS_DEFAULT * 2;
			_damping.y = y * GameConfig.SPEED_PLUS_DEFAULT * 2;
		}
		
		public function addDamping(x:Number = 0, y:Number = 0):void {
			_damping.x += x;
			_damping.y += y;
		}
		
		private function renderVelocity():void {
			var resultX:Number = 0;
			var resultY:Number = 0;
			if (_velocity.x != 0) {
				resultX += _velocity.x;
				if (_damping.x > 0) {
					_velocity.x = KyoUtils.num_wake(_velocity.x, _damping.x * _dampingRate);
				}
			}
			if (_velocity.y != 0) {
				resultY += _velocity.y;
				if (_damping.y > 0) {
					_velocity.y = KyoUtils.num_wake(_velocity.y, _damping.y * _dampingRate);
				}
			}
			if (_velocity2.x != 0) {
				resultX += _velocity2.x;
				if (_damping2.x > 0) {
					_velocity2.x = KyoUtils.num_wake(_velocity2.x, _damping2.x * _dampingRate);
				}
			}
			if (_velocity2.y != 0) {
				resultY += _velocity2.y;
				if (_damping2.y > 0) {
					_velocity2.y = KyoUtils.num_wake(_velocity2.y, _damping2.y * _dampingRate);
				}
			}
			if (resultX != 0 || resultY != 0) {
				move(resultX, resultY);
			}
		}
		
		public function applayG(g:Number):void {
			if (!isApplyG) {
				_g = 0;
				return;
			}
			if (_velocity.y < 0) {
				_g = 0;
				return;
			}
			if (_g < g) {
				var addG:Number = 1.2 * GameConfig.SPEED_PLUS;
				_g += addG;
				if (_g > g) {
					_g = g;
				}
			}
			
			move(0, _g);
		}
		
		public function setInAir(v:Boolean):void {
			if (!v) {
				_g = 4;
			}
			
			isInAir = v;
		}
		
		public function hit(hitvo:HitVO, target:IGameSprite):void {
			if (target && target.getDisplay()) {
				var d:DisplayObject = getDisplay();
				var td:DisplayObject = target.getDisplay();
				
				if (d && td && d.parent && d.parent == td.parent) {
					var _parent:DisplayObjectContainer = d.parent;
					var index1:int = _parent.getChildIndex(d);
					var index2:int = _parent.getChildIndex(td);
					
					if (index1 != -1 && index2 != -1 && index1 < index2) {
						_parent.setChildIndex(td, index1);
						_parent.setChildIndex(d, index2);
					}
				}
			}
		}
		
		public function beHit(hitvo:HitVO, hitRect:Rectangle = null):void {}
		
		public function getCurrentHits():Array {
			return null;
		}
		
		public function getArea():Rectangle {
			if (!_area) {
				return null;
			}
			var newRect:Rectangle = _area.clone();
			newRect.x += _x;
			newRect.y += _y;
			
			return newRect;
		}
		
		public function getBodyArea():Rectangle {
			return null;
		}
		
		public function allowCrossMapXY():Boolean {
			return isAllowCrossX;
		}
		
		public function allowCrossMapBottom():Boolean {
			return isAllowCrossBottom;
		}
		
		public function getIsTouchSide():Boolean {
			return _isTouchSide;
		}
		
		public function setIsTouchSide(v:Boolean):void {
			_isTouchSide = v;
		}
		
		public function addHp(v:Number):void {
			hp += v;
			if (hp > hpMax) {
				hp = hpMax;
			}
		}
		
		public function loseHp(v:Number):void {
			if (!isAllowLoseHP) {
				return;
			}
			var dr:Number = 2 - defenseRate;
			if (dr < 0.1) {
				dr = 0.1;
			}
			if (dr > 1) {
				dr = 1;
			}
			var lose:Number = v * dr - defense;
			if (lose < 0) {
				return;
			}
			hp -= lose;
			if (hp < 0) {
				hp = 0;
			}
		}
		
		public function delayCall(func:Function, frame:int):void {
			_frameFuncs.push({
				func : func,
				frame: frame
			});
		}
		
		public function renderSelf():void {
			GameRender.add(renderSelfEnterFrame, this);
		}
		
		private function renderSelfEnterFrame():void {
			if (_destoryed) {
				return;
			}
			try {
				render();
				renderAnimate();
			}
			catch (e:Error) {
				Debugger.log("BaseGameSprite.renderSelfEnterFrame :: " + e);
			}
		}
		
		public function stopRenderSelf():void {
			GameRender.remove(renderSelfEnterFrame, this);
		}
		
		public function setAnimateFrameOut(func:Function, frame:int):void {
			_frameAnimateFuncs.push({
				func : func,
				frame: frame
			});
		}
		
		private function renderAnimateFrameOut():void {
			if (_frameAnimateFuncs.length < 1) {
				return;
			}
			
			for (var i:int = 0; i < _frameAnimateFuncs.length; i++) {
				var o:Object = _frameAnimateFuncs[i];
				o.frame--;
				
				if (o.frame < 1) {
					o.func();
					_frameAnimateFuncs.splice(i, 1);
				}
			}
		}
		
		private function renderFrameOut():void {
			if (_frameFuncs.length < 1) {
				return;
			}
			
			for (var i:int = 0; i < _frameFuncs.length; i++) {
				var o:Object = _frameFuncs[i];
				o.frame--;
				
				if (o.frame < 1) {
					o.func();
					_frameFuncs.splice(i, 1);
				}
			}
		}
	}
}
