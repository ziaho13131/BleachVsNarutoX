/**
 * 已重建完成
 */
package net.play5d.game.obvn.fighter.ctrler {
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	
	import net.play5d.game.obvn.ctrl.game_ctrler.GameCtrler;
	import net.play5d.game.obvn.fighter.FighterActionState;
	import net.play5d.game.obvn.fighter.FighterMC;
	import net.play5d.game.obvn.fighter.FighterMain;
	import net.play5d.game.obvn.fighter.models.FighterHitModel;
	import net.play5d.game.obvn.fighter.models.HitVO;
	import net.play5d.game.obvn.interfaces.BaseGameSprite;
	import net.play5d.game.obvn.interfaces.IFighterActionCtrl;
	import net.play5d.game.obvn.interfaces.IGameSprite;
	
	/**
	 * 角色控制器
	 */
	public class FighterCtrler {
		
		public var hitModel:FighterHitModel;
		
		private var _effectCtrl:FighterEffectCtrler;
		private var _fighterMcCtrl:FighterMcCtrler;
		private var _voiceCtrl:FighterVoiceCtrler;
		
		private var _fighter:FighterMain;
		private var _rectCache:Object = {};
		private var _doingWankai:Boolean;
		
		public function destory():void {
			if (_effectCtrl) {
				_effectCtrl.destory();
				_effectCtrl = null;
			}
			if (_fighterMcCtrl) {
				_fighterMcCtrl.destory();
				_fighterMcCtrl = null;
			}
			if (_voiceCtrl) {
				_voiceCtrl.destory();
				_voiceCtrl = null;
			}
			if (_rectCache) {
				_rectCache = null;
			}
			if (hitModel) {
				hitModel.destory();
				hitModel = null;
			}
			
			_fighter = null;
		}
		
		public function getEffectCtrl():FighterEffectCtrler {
			return _effectCtrl;
		}
		
		public function getVoiceCtrl():FighterVoiceCtrler {
			return _voiceCtrl;
		}
		
		public function get hp():Number {
			return _fighter.hp;
		}
		
		public function set hp(v:Number):void {
			_fighter.hp = _fighter.hpMax = _fighter.customHpMax = v;
		}
		
		public function get energy():Number {
			return _fighter.energyMax;
		}
		
		public function set energy(v:Number):void {
			_fighter.energy = _fighter.energyMax = v;
		}
		
		public function get speed():Number {
			return _fighter.speed;
		}
		
		public function set speed(v:Number):void {
			_fighter.speed = v;
		}
		
		public function get jumpPower():Number {
			return _fighter.jumpPower;
		}
		
		public function set jumpPower(v:Number):void {
			_fighter.jumpPower = v;
		}
		
		public function get heavy():Number {
			return _fighter.heavy;
		}
		
		public function set heavy(v:Number):void {
			_fighter.heavy = v;
		}
		
		public function get defenseType():int {
			return _fighter.defenseType;
		}
		
		public function set defenseType(v:int):void {
			_fighter.defenseType = v;
		}
		
		public function addHp(v:Number):void {
			_fighter.addHp(v);
		}
		
		public function addHpPercent(v:Number):void {
			_fighter.addHp(_fighter.hpMax * v);
		}
		
		/**
		 * 增加已损失血量的百分比血量
		 */
		public function addHpLosePercent(v:Number):void {
			var losedHp:Number = _fighter.hpMax - _fighter.hp;
			_fighter.addHp(losedHp * v);
		}
		
		public function loseHp(v:Number):void {
			_fighter.loseHp(v);
		}
		
		public function loseHpPercent(v:Number):void {
			_fighter.loseHp(v * _fighter.hpMax);
		}
		
		public function get self():DisplayObject {
			return _fighter.getDisplay();
		}
		
		public function get target():DisplayObject {
			var target:IGameSprite = _fighter.getCurrentTarget();
			if (!target) {
				return null;
			}
			
			return target.getDisplay();
		}
		
		public function getTargetSP():IGameSprite {
			var target:IGameSprite = _fighter.getCurrentTarget();
			if (!target) {
				return null;
			}
			
			return target;
		}
		
		public function getSelf():FighterMain {
			return _fighter;
		}
		
		public function getTargetState():int {
			var target:FighterMain = _fighter.getCurrentTarget() as FighterMain;
			if (!target) {
				return 0;
			}
			
			return target.actionState;
		}
		
		public function setTargetVelocity(x:Number, y:Number):void {
			var target:IGameSprite = _fighter.getCurrentTarget();
			if (target && target is BaseGameSprite) {
				(target as BaseGameSprite).setVelocity(x, y);
			}
		}
		
		public function setTargetDamping(x:Number, y:Number):void {
			var target:IGameSprite = _fighter.getCurrentTarget();
			if (target && target is BaseGameSprite) {
				(target as BaseGameSprite).setDamping(x, y);
			}
		}
		
		public function targetInRange(rx:Array = null, ry:Array = null):Boolean {
			if (!target) {
				return false;
			}
			
			var xDis:Number = NaN;
			
			var targetDisplay:DisplayObject = this.target;
			var selfDisplay:DisplayObject = this.self;
			if (_fighter.direct > 0) {
				xDis = targetDisplay.x - selfDisplay.x;
			}
			else {
				xDis = selfDisplay.x - targetDisplay.x;
			}
			
			var yDis:Number = targetDisplay.y - selfDisplay.y;
			var XinRange:Boolean = true;
			var YinRange:Boolean = true;
			if (rx) {
				XinRange = xDis >= rx[0] && xDis <= rx[1];
			}
			if (ry) {
				YinRange = yDis >= ry[0] && yDis <= ry[1];
			}
			
			return XinRange && YinRange;
		}
		
		public function justHit(hitId:String, includeDefense:Boolean = false):Boolean {
			var target:IGameSprite = _fighter.getCurrentTarget();
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
		
		public function getMcCtrl():FighterMcCtrler {
			return _fighterMcCtrl;
		}
		
		public function initFighter(fighter:FighterMain):void {
			_fighter = fighter;
			
			hitModel = new FighterHitModel(_fighter);
			_voiceCtrl = new FighterVoiceCtrler();
			_effectCtrl = new FighterEffectCtrler(fighter);
			_fighterMcCtrl = new FighterMcCtrler(fighter);
			_fighterMcCtrl.effectCtrler = _effectCtrl;
			
			if (fighter.mc.initFighter) {
				var param:Object = {
					fighter_ctrler: this,
					mc_ctrler     : _fighterMcCtrl,
					effect_ctrler : _effectCtrl
				};
				
				fighter.mc.initFighter(param);
				return;
			}
			
			throw new Error("Failed to initialize, SWF not define initFighter()");
		}
		
		public function renderAnimate():void {
			if (_fighterMcCtrl) {
				_fighterMcCtrl.renderAnimate();
			}
		}
		
		public function render():void {
			if (_fighterMcCtrl) {
				_fighterMcCtrl.render();
			}
		}
		
		public function setActionCtrl(ctrler:IFighterActionCtrl):void {
			if (_fighterMcCtrl) {
				_fighterMcCtrl.setActionCtrler(ctrler);
			}
			else {
				trace('Failed to set "ctrler"!');
			}
		}
		
		public function defineAction(id:String, obj:Object):void {
			hitModel.addHitVO(id, obj);
		}
		
		public function defineBishaFace(id:String, face:Class):void {
			_effectCtrl.setBishaFace(id, face);
		}
		
		public function defineHurtSound(...params):void {
			_voiceCtrl.setVoice(0, params);
		}
		
		public function defineHurtFlySound(...params):void {
			_voiceCtrl.setVoice(1, params);
		}
		
		public function defineDieSound(...params):void {
			_voiceCtrl.setVoice(2, params);
		}
		
		public function initMc(mc:MovieClip):void {
			if (mc) {
				var fighterMc:FighterMC = new FighterMC();
				fighterMc.initlize(mc, _fighter, _fighterMcCtrl);
				
				if (_doingWankai) {
					_fighter.actionState = FighterActionState.WAN_KAI_ING;
					fighterMc.goFrame("开场");
					
					_doingWankai = false;
				}
				else {
					_fighterMcCtrl.idle();
				}
				
				return;
			}
			
			throw new Error("FighterCtrler.initMc Error :: mc is null!");
		}
		
		public function getCurrentHits():Array {
			var areas:Array = null;
			
			try {
				areas = _fighter.getMC().getCurrentHitArea();
			}
			catch (e:Error) {
				trace("FighterCtrler.getCurrentHits :: " + e);
			}
			
			if (!areas || areas.length < 1) {
				return null;
			}
			
			var hits:Array = [];
			for (var i:int = 0; i < areas.length; i++) {
				var dobj:Object = areas[i];
				
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
		
		public function getBodyArea():Rectangle {
			var area:Rectangle = null;
			
			try {
				area = _fighter.getMC().getCurrentBodyArea();
			}
			catch (e:Error) {
				trace("FighterCtrler.getBodyArea :: " + e);
			}
			if (area == null) {
				return null;
			}
			
			return getCurrentRect(area, "body");
		}
		
		public function getHitCheckRect(name:String):Rectangle {
			var area:Rectangle = _fighter.getMC().getCheckHitRect(name);
			if (area == null) {
				return null;
			}
			
			return getCurrentRect(area, "hit_check");
		}
		
		public function getCurrentRect(rect:Rectangle, cacheId:String = null):Rectangle {
			var newRect:Rectangle;
			
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
			
			newRect.x = rect.x * _fighter.direct + _fighter.x;
			if (_fighter.direct < 0) {
				newRect.x -= rect.width;
			}
			newRect.y = rect.y + _fighter.y;
			newRect.width = rect.width;
			newRect.height = rect.height;
			
			return newRect;
		}
		
		public function doWanKai(frame:int = 0):void {
			_doingWankai = true;
			
			if (frame == 0) {
				_fighter.mc.nextFrame();
				return;
			}
			
			_fighter.mc.gotoAndStop(frame);
		}
		
		public function setDirectToTarget():void {
			var target:IGameSprite = _fighter.getCurrentTarget();
			if (!target) {
				return;
			}
			
			_fighter.direct = _fighter.x > target.x ? -1 : 1;
		}
		
		/**
		 * 反转方向
		 */
		public function setDirectReverse():void {
			_fighter.direct = -_fighter.direct;
		}
		
		public function moveOnce(x:Number = 0, y:Number = 0):void {
			_fighter.x += x * _fighter.direct;
			_fighter.y += y;
		}
		
		public function moveToTarget(x:Object = null, y:Object = null, setDirect:Boolean = true):void {
			var target:IGameSprite = _fighter.getCurrentTarget();
			if (!target) {
				return;
			}
			
			if (x != null) {
				var numX:Number = Number(x);
				var fx:Number = target.x + numX * _fighter.direct;
				
				if (numX > 0) {
					try {
						if (target.x < numX) {
							fx = target.x + numX;
						}
						else if (target.x > GameCtrler.I.gameState.getMap().right - numX) {
							fx = target.x - numX;
						}
					}
					catch (e:Error) {
					}
				}
				
				_fighter.x = fx;
			}
			if (y != null) {
				_fighter.y = target.y + Number(y);
			}
			
			if (setDirect) {
				_fighter.direct = _fighter.x < target.x ? 1 : -1;
			}
		}
		
		public function setCross(v:Boolean):void {
			_fighter.isCross = v;
		}
		
		public function getHitRange(id:String):Rectangle {
			var area:Rectangle = _fighter.getMC().getHitRange(id);
			if (area == null) {
				return null;
			}
			
			return getCurrentRect(area, "hitRange_" + id);
		}
	}
}
