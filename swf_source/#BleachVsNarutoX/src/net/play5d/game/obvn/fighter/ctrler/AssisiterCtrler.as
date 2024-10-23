/**
 * 已重建完成
 */
package net.play5d.game.obvn.fighter.ctrler {
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	
	import net.play5d.game.obvn.ctrl.EffectCtrl;
	import net.play5d.game.obvn.ctrl.game_ctrler.GameCtrler;
	import net.play5d.game.obvn.fighter.Assister;
	import net.play5d.game.obvn.fighter.FighterAttacker;
	import net.play5d.game.obvn.fighter.FighterMain;
	import net.play5d.game.obvn.fighter.events.FighterEvent;
	import net.play5d.game.obvn.fighter.events.FighterEventDispatcher;
	import net.play5d.game.obvn.fighter.models.FighterHitModel;
	import net.play5d.game.obvn.fighter.models.HitVO;
	import net.play5d.game.obvn.interfaces.IGameSprite;
	
	/**
	 * 辅助控制器
	 */
	public class AssisiterCtrler {
		
		public var hitModel:FighterHitModel;
		
		private var _effectCtrl:FighterEffectCtrler;
		private var _assister:Assister;
		private var _touchFloor:Boolean;
		private var _touchFloorFrame:String;
		private var hitTargetAction:String;
		private var hitTargetChecker:String;
		private var _touchSideAction:String;
		
		public function get effect():FighterEffectCtrler {
			return _effectCtrl;
		}
		
		public function destory():void {
			if (_effectCtrl) {
				_effectCtrl.destory();
				_effectCtrl = null;
			}
			if (hitModel) {
				hitModel.destory();
				hitModel = null;
			}
			
			_assister = null;
		}
		
		public function getTarget():IGameSprite {
			var owner:FighterMain = _assister.getOwner() as FighterMain;
			if (owner) {
				return owner.getCurrentTarget();
			}
			
			return null;
		}
		
		public function getOwner():IGameSprite {
			return _assister.getOwner();
		}
		
		public function getSelf():Assister {
			return _assister;
		}
		
		public function setApplyG(v:Boolean):void {
			_assister.isApplyG = v;
		}
		
		public function finish(showEffect:Boolean = true):void {
			if (showEffect) {
				EffectCtrl.I.assisterEffect(_assister);
			}
			
			_touchSideAction = null;
			_assister.isAttacking = false;
			
			_assister.gotoAndStop(1);
			removeSelf();
		}
		
		public function defineAction(id:String, obj:Object):void {
			hitModel.addHitVO(id, obj);
		}
		
		public function get owner_mc_ctrler():FighterMcCtrler {
			var fighter:FighterMain = _assister.getOwner() as FighterMain;
			if (fighter) {
				return fighter.getCtrler().getMcCtrl();
			}
			
			return null;
		}
		
		public function get owner_fighter_ctrler():FighterCtrler {
			var fighter:FighterMain = _assister.getOwner() as FighterMain;
			if (fighter) {
				return fighter.getCtrler();
			}
			
			return null;
		}
		
		public function initAssister(assister:Assister):void {
			hitModel = new FighterHitModel(assister);
			_assister = assister;
			
			_effectCtrl = new FighterEffectCtrler(assister);
		}
		
		public function endAct():void {
			_assister.isAttacking = false;
		}
		
		public function render():void {
			renderCheckTargetHit();
			renderTouchSide();
			if (_assister.isInAir) {
				_touchFloor = false;
				
				return;
			}
			
			if (!_touchFloor) {
				_touchFloor = true;
				
				if (_touchFloorFrame) {
					_assister.gotoAndPlay(_touchFloorFrame);
					_touchFloorFrame = null;
				}
			}
		}
		
		/**
		 * 移动到目标（参数是OBJ的原因应该是允许空参）
		 */
		public function moveToTarget(x:Object = null, y:Object = null, setDirect:Boolean = true):void {
			var fighter:FighterMain = _assister.getOwner() as FighterMain;
			if (!fighter) {
				return;
			}
			
			var target:IGameSprite = fighter.getCurrentTarget();
			if (!target) {
				return;
			}
			
			if (x != null) {
				_assister.x = target.x + Number(x) * _assister.direct;
			}
			if (y != null) {
				_assister.y = target.y + Number(y);
			}
			
			if (setDirect) {
				_assister.direct = _assister.x < target.x ? 1 : -1;
			}
		}
		
		public function setDirectToTarget():void {
			var target:IGameSprite = getTarget();
			if (!target) {
				return;
			}
			
			_assister.direct = _assister.x < target.x ? 1 : -1;
		}
		
		public function move(x:Number = 0, y:Number = 0):void {
			_assister.setVelocity(x * _assister.direct, y);
		}
		
		public function damping(x:Number = 0, y:Number = 0):void {
			_assister.setDamping(x, y);
		}
		
		public function moveOnce(x:Number = 0, y:Number = 0):void {
			_assister.x += x * _assister.direct;
			_assister.y += y;
		}
		
		public function stopMove():void {
			_assister.setVelocity(0, 0);
		}
		
		public function stop():void {
			_assister.stop();
		}
		
		public function gotoAndPlay(frame:String):void {
			_assister.gotoAndPlay(frame);
		}
		
		public function gotoAndStop(frame:String):void {
			_assister.gotoAndStop(frame);
		}
		
		public function setTouchFloor(frame:String):void {
			_touchFloorFrame = frame;
		}
		
		public function setTouchSide(action:String):void {
			_touchSideAction = action;
		}
		
		public function justHit(hitId:String, playFrame:String = null, includeDefense:Boolean = false):Boolean {
			if (isJustHit(hitId, includeDefense)) {
				if (playFrame != null) {
					gotoAndPlay(playFrame);
				}
				
				return true;
			}
			
			return false;
		}
		
		/**
		 * 判断当前是否命中
		 */
		private function isJustHit(hitId:String, includeDefense:Boolean = false):Boolean {
			var owner:FighterMain = _assister.getOwner() as FighterMain;
			var target:IGameSprite = owner.getCurrentTarget();
			
			if (target && target is FighterMain) {
				var hv:HitVO = (target as FighterMain).hurtHit;
				if (hv) {
					return hv.id == hitId;
				}
				
				if (includeDefense) {
					var hv2:HitVO = (target as FighterMain).defenseHit;
					if (hv2) {
						return hv2.id == hitId;
					}
				}
			}
			
			return false;
		}
		
		public function setHitTarget(checker:String, action:String):void {
			hitTargetAction = action;
			hitTargetChecker = checker;
		}
		
		public function removeSelf():void {
			_assister.removeSelf();
		}
		
		public function fire(mcName:String, params:Object = null):void {
			var mc:MovieClip = _assister.mc.getChildByName(mcName) as MovieClip;
			if (mc) {
				if (!params) {
					params = {};
				}
				
				params.mc = mc;
				params.hitVO = hitModel.getHitVO(mcName);
				FighterEventDispatcher.dispatchEvent(_assister, FighterEvent.FIRE_BULLET, params);
			}
			else {
				_assister.setAnimateFrameOut(function ():void {
					fire(mcName, params);
				}, 1);
			}
		}
		
		public function addAttacker(mcName:String, params:Object = null):void {
			var mc:MovieClip = _assister.mc.getChildByName(mcName) as MovieClip;
			if (mc) {
				if (!params) {
					params = {};
				}
				
				params.mc = mc;
				params.hitVO = hitModel.getHitVOByDisplayName(mcName);
				FighterEventDispatcher.dispatchEvent(_assister, FighterEvent.ADD_ATTACKER, params);
			}
			else {
				_assister.setAnimateFrameOut(function ():void {
					addAttacker(mcName, params);
				}, 1);
			}
		}
		
		public function checkHitOwner(mcName:String):Boolean {
			var rect:Rectangle = _assister.getHitCheckRect(mcName);
			if (!rect) {
				return false;
			}
			
			var ownerRect:Rectangle = _assister.getOwner().getArea();
			if (!ownerRect) {
				return false;
			}
			
			return rect.intersects(ownerRect);
		}
		
		private function renderCheckTargetHit():void {
			if (!hitTargetChecker) {
				return;
			}
			
			var rect:Rectangle = _assister.getHitCheckRect(hitTargetChecker);
			if (!rect) {
				return;
			}
			var targets:Vector.<IGameSprite> = _assister.getTargets();
			if (!targets) {
				return;
			}
			
			for each (var target:IGameSprite in targets) {
				var body:Rectangle = target.getBodyArea();
				if (body && rect.intersects(body)) {
					gotoAndPlay(hitTargetAction);
				}
			}
		}
		
		public function renderTouchSide():void {
			if (_touchSideAction == null) {
				return;
			}
			
			if (_assister.getIsTouchSide()) {
				_assister.gotoAndPlay(_touchSideAction);
				_touchSideAction = null;
			}
		}
		
		public function addCustomFunc(func:Function = null):void {
			_assister.addCustomFunc(func);
		}
		
		public function removeCustomFunc():void {
			_assister.removeCustomFunc();
		}
		
		public function getAttacker(name:String):FighterAttackerCtrler {
			var attacker:FighterAttacker = GameCtrler.I.getAttacker(name, _assister.team.id);
			if (attacker != null) {
				return attacker.getCtrler();
			}
			
			return null;
		}
	}
}
