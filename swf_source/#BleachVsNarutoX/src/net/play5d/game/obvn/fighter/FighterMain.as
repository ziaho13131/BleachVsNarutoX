/**
 * 已重建完成
 */
package net.play5d.game.obvn.fighter {
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	
	import net.play5d.game.obvn.GameConfig;
	import net.play5d.game.obvn.ctrl.GameLogic;
	import net.play5d.game.obvn.ctrl.game_ctrler.GameCtrler;
	import net.play5d.game.obvn.data.FighterVO;
	import net.play5d.game.obvn.data.TeamVO;
	import net.play5d.game.obvn.fighter.ctrler.FighterBuffCtrler;
	import net.play5d.game.obvn.fighter.ctrler.FighterCtrler;
	import net.play5d.game.obvn.fighter.models.HitVO;
	import net.play5d.game.obvn.interfaces.BaseGameSprite;
	import net.play5d.game.obvn.interfaces.IFighterActionCtrl;
	import net.play5d.game.obvn.interfaces.IGameSprite;
	
	/**
	 * 主人物类
	 */
	public class FighterMain extends BaseGameSprite {
		
		public var qi:Number = 0;
		public const qiMax:Number = 300;
		public var energy:Number = 100;
		public var energyMax:Number = 100;
		public var energyOverLoad:Boolean = false;
		public var customHpMax:int = 0;
		public var fzqi:Number = 100;
		public const fzqiMax:Number = 100;
		public var speed:Number = 6;
		public var jumpPower:Number = 15;
		public var isSteelBody:Boolean = false;
		public var isSuperSteelBody:Boolean = false;
		
		public var data:FighterVO;
		public var airHitTimes:int = 1;
		public var jumpTimes:int = 2;
		public var actionState:int = 0;
		public var defenseType:int = 0;
		public var lastHitVO:HitVO;
		private var _buffCtrler:FighterBuffCtrler;
		private var _currentHurts:Vector.<HitVO>;
		public var hurtHit:HitVO;
		public var defenseHit:HitVO;
		public var targetTeams:Vector.<TeamVO>;
		
		private var _currentTarget:IGameSprite;
		private var _fighterCtrl:FighterCtrler;
		private var _energyAddGap:int;
		private var _explodeHitVO:HitVO;
		private var _explodeHitFrame:int;
		private var _explodeSteelFrame:int;
		private var _replaceSkillFrame:int;
		private var _speedBack:Number = 0;
//		private var _colorTransform:ColorTransform;
		
		// 取得特殊技能百分比
		public function get spRate():Number {
			var isNaruto:Boolean = data.comicType == 1;
			
			var cur:int = isNaruto ? 
				_replaceSkillFrame : 
				_explodeSteelFrame;
			var max:int = isNaruto ? 
				GameConfig.HURT_SKILL_FRAME_NARUTO : 
				GameConfig.HURT_SKILL_FRAME_BLEACH;
			
			return cur / max;
		}
		
		public var isRenderBeforeTarget:Boolean = false;
		public var isCheckedRender:Boolean = false;
		
		private var _usedPassiveCdFrame:int = 0;
		
		public function FighterMain(mainMc:MovieClip) {
			super(mainMc);
			_area = null;
		}
		
//		public function get colorTransform():ColorTransform {
//			return _colorTransform;
//		}
//		
//		public function set colorTransform(v:ColorTransform):void {
//			_colorTransform = v;
//			_mainMc.transform.colorTransform = v ? v : new ColorTransform();
//		}
		
		public function changeColor(v:ColorTransform):void {
			_mainMc.transform.colorTransform = v;
		}
		
		public function resumeColor():void {
			_mainMc.transform.colorTransform = _colorTransform ? _colorTransform : new ColorTransform();
		}
		
		override public function destory(dispose:Boolean = true):void {
			if (!dispose) {
				return;
			}
			
			if (_fighterCtrl) {
				_fighterCtrl.destory();
				_fighterCtrl = null;
			}
			if (_mainMc) {
				_mainMc.filters = null;
				_mainMc.gotoAndStop(1);
			}
			if (_buffCtrler) {
				_buffCtrler.destory();
				_buffCtrler = null;
			}
			
			targetTeams = null;
			_currentTarget = null;
			_currentHurts = null;
			super.destory(dispose);
		}
		
		override public function set attackRate(value:Number):void {
			super.attackRate = value;
			
			if (_fighterCtrl && _fighterCtrl.hitModel) {
				_fighterCtrl.hitModel.setPowerRate(value);
			}
		}
		
		public function currentHurtDamage():int {
			if (!_currentHurts) {
				return 0;
			}
			
			var damage:int = 0;
			for each(var i:HitVO in _currentHurts) {
				damage += i.getDamage();
			}
			
			return damage;
		}
		
		public function getLastHurtHitVO():HitVO {
			if (!_currentHurts) {
				return null;
			}
			
			return _currentHurts[_currentHurts.length - 1];
		}
		
		public function hurtBreakHit():Boolean {
			for each(var i:HitVO in _currentHurts) {
				if (i.isBreakDef) {
					return true;
				}
			}
			
			return false;
		}
		
		public function clearHurtHits():void {
			_currentHurts = null;
		}
		
		public function getCtrler():FighterCtrler {
			return _fighterCtrl;
		}
		
		public function getBuffCtrl():FighterBuffCtrler {
			return _buffCtrler;
		}
		
		public function getCurrentTarget():IGameSprite {
			if (_currentTarget) {
				if (_currentTarget is BaseGameSprite && (_currentTarget as BaseGameSprite).isAlive) {
					return _currentTarget;
				}
			}
			
			var targets:Vector.<IGameSprite> = getTargets();
			var targetsOrder:Array = [];
			if (targets && targets.length > 0) {
				for each(var i:IGameSprite in targets) {
					if (i.getBodyArea() == null) {
						targetsOrder.push({
							fighter: i,
							order  : 5
						});
					}
					else if (i is FighterMain && (i as FighterMain).isAlive) {
						targetsOrder.push({
							fighter: i,
							order  : 0
						});
					}
					else if (i is BaseGameSprite && (i as BaseGameSprite).isAlive) {
						targetsOrder.push({
							fighter: i,
							order  : 1
						});
					}
					else {
						targetsOrder.push({
							fighter: i,
							order  : 2
						});
					}
				}
				
				targetsOrder.sortOn("order", 16);
				_currentTarget = targetsOrder[0].fighter;
			}
			
			return _currentTarget;
		}
		
		public function getTargets():Vector.<IGameSprite> {
			if (!targetTeams || targetTeams.length < 1) {
				return null;
			}
			
			var ts:Vector.<IGameSprite> = new Vector.<IGameSprite>();
			
			for each (var team:TeamVO in targetTeams) {
				ts = ts.concat(team.getAliveChildren());
			}
			
			return ts;
		}
		
		public function getMC():FighterMC {
			if (!_fighterCtrl) {
				return null;
			}
			if (!_fighterCtrl.getMcCtrl()) {
				return null;
			}
			
			return _fighterCtrl.getMcCtrl().getFighterMc();
		}
		
		public function setActionCtrl(ctrler:IFighterActionCtrl):void {
			if (_fighterCtrl) {
				_fighterCtrl.setActionCtrl(ctrler);
				ctrler.initlize();
			}
		}
		
		public function initlize():void {
			_fighterCtrl = new FighterCtrler();
			_buffCtrler = new FighterBuffCtrler(this);
			_fighterCtrl.initFighter(this);
			
			_mainMc.gotoAndStop(data ? data.startFrame + 1 : 2);
		}
		
		override public function renderAnimate():void {
			super.renderAnimate();
			if (_destoryed) {
				return;
			}
			
			if (GameCtrler.I.isRenderGame) {
				renderEnergy();
				renderFzQi();
			}
			
			if (_fighterCtrl) {
				_fighterCtrl.renderAnimate();
			}
			
			if (_explodeHitFrame > 0) {
				_explodeHitFrame--;
				
				if (_explodeHitFrame == 8) {
					idle();
					isAllowBeHit = false;
				}
				
				if (_explodeHitFrame <= 0) {
					_explodeHitVO = null;
					isAllowBeHit = true;
				}
			}
			
			if (_usedPassiveCdFrame > 0) {
				_usedPassiveCdFrame--;
			}
			
			if (_explodeSteelFrame > 0) {
				_explodeSteelFrame--;
				
				_fighterCtrl.getMcCtrl().setSteelBody(true, true);
				if (FighterActionState.isHurtFlying(actionState)) {
					_explodeSteelFrame = 0;
				}
				if (_explodeSteelFrame <= 0) {
					_fighterCtrl.getMcCtrl().setSteelBody(false);
				}
			}
			
			if (_replaceSkillFrame > 0) {
				_replaceSkillFrame--;
				
				_mainMc.alpha = 0.5;
				isAllowBeHit = false;
				
				if (_replaceSkillFrame <= 0) {
					_mainMc.alpha = 1;
					isAllowBeHit = true;
				}
			}
		}
		
		override public function render():void {
			super.render();
			if (_destoryed) {
				return;
			}
			
			checkRenderToTarget();
			if (_fighterCtrl) {
				_fighterCtrl.render();
			}
			if (_buffCtrler) {
				_buffCtrler.render();
			}
			
			if (hp < 0) {
				hp = 0;
			}
			if (hp > hpMax) {
				hp = hpMax;
			}
			if (energy < 0) {
				energy = 0;
			}
			if (energy > energyMax) {
				energy = energyMax;
			}
			if (qi < 0) {
				qi = 0;
			}
			if (qi > qiMax) {
				qi = qiMax;
			}
			if (fzqi < 0) {
				fzqi = 0;
			}
			if (fzqi > fzqiMax) {
				fzqi = fzqiMax;
			}
		}
		
		public function jump():void {
			_g = 0;
			
			setVelocity(0, -jumpPower);
			setDamping(0, 0.5);
		}
		
		override public function getCurrentHits():Array {
			if (_explodeHitVO && _explodeHitFrame < 8) {
				return [_explodeHitVO];
			}
			
			return _fighterCtrl.getCurrentHits();
		}
		
		override public function getBodyArea():Rectangle {
			if (!_fighterCtrl) {
				return null;
			}
			
			return _fighterCtrl.getBodyArea();
		}
		
		override public function hit(hitvo:HitVO, target:IGameSprite):void {
			super.hit(hitvo, target);
			lastHitVO = hitvo;
			
			var addqi:Number = 0;
			if (target is FighterMain) {
				if (!hitvo.isBisha()) {
					addqi = Number(hitvo.power * 0.16);
				}
				if (addqi > GameConfig.QI_ADD_HIT_MAX) {
					addqi = GameConfig.QI_ADD_HIT_MAX;
				}
			}
			
			addQi(addqi);
			GameLogic.hitTarget(hitvo, this, target);
		}
		
		override public function beHit(hitvo:HitVO, hitRect:Rectangle = null):void {
			if (!isAllowBeHit) {
				return;
			}
			
			super.beHit(hitvo, hitRect);
			_fighterCtrl.getMcCtrl().beHit(hitvo, hitRect);
			
			var addqi:Number = hitvo.power * 0.085;
			if (addqi > GameConfig.QI_ADD_HURT_MAX) {
				addqi = GameConfig.QI_ADD_HURT_MAX;
			}
			
			addQi(addqi);
			if (actionState == FighterActionState.HURT_ING || 
				actionState == FighterActionState.HURT_FLYING) 
			{
				if (!_currentHurts) {
					_currentHurts = new Vector.<HitVO>();
				}
				_currentHurts.push(hitvo);
			}
		}
		
		private function renderEnergy():void {
			if (_energyAddGap > 0) {
				_energyAddGap--;
				return;
			}
			
			if (energy < energyMax) {
				if (energyOverLoad) {
					energy += GameConfig.ENERGY_ADD_OVER_LOAD_PERFRAME;
					if (energy > 30) {
						energyOverLoad = false;
					}
				}
				else if (actionState == FighterActionState.DEFENCE_ING) {
					energy += GameConfig.ENERGY_ADD_DEFENSE;
				}
				else if (FighterActionState.isAttacking(actionState)) {
					energy += GameConfig.ENERGY_ADD_ATTACKING;
				}
				else {
					energy += GameConfig.ENERGY_ADD_NORMAL;
				}
			}
		}
		
		private function renderFzQi():void {
			if (fzqi < fzqiMax) {
				fzqi += GameConfig.FUZHU_QU_ADD_PERFRAME;
			}
		}
		
		public function hasEnergy(v:Number, allowOverflow:Boolean = false):Boolean {
			if (energy >= v) {
				return true;
			}
			
			if (allowOverflow) {
				if (!energyOverLoad) {
					return true;
				}
			}
			
			return false;
		}
		
		public function useEnergy(v:Number):void {
			energy -= v;
			_energyAddGap = GameConfig.USE_ENERGY_CD * GameConfig.ENERGY_ADD_OVER_LOAD_RESUME;
			
			if (energy < 0) {
				energy = 0;
				energyOverLoad = true;
			}
		}
		
		public function useQi(v:Number):Boolean {
			if (qi < v) {
				return false;
			}
			
			qi -= v;
			return true;
		}
		
		public function addQi(v:Number):void {
			qi += v;
			
			if (qi > qiMax) {
				qi = qiMax;
			}
		}
		
		public function sayIntro():void {
			_fighterCtrl.getMcCtrl().sayIntro();
		}
		
		public function win():void {
			_fighterCtrl.getMcCtrl().doWin();
		}
		
		public function idle():void {
			_fighterCtrl.getMcCtrl().idle();
		}
		
		public function lose():void {
			_fighterCtrl.getMcCtrl().doLose();
		}
		
		public function getHitRange(id:String):Rectangle {
			return _fighterCtrl.getHitRange(id);
		}
		
		public function energyExplode():void {
			_fighterCtrl.getEffectCtrl().energyExplode();
			_fighterCtrl.getMcCtrl().setSteelBody(true, true);
			_explodeHitVO = new HitVO();
			
			var rect:Rectangle = new Rectangle(-100, -200, 200, 210);
			_explodeHitVO.currentArea = _fighterCtrl.getCurrentRect(rect);
			_explodeHitVO.power = 50;
			_explodeHitVO.hitx = 15 * direct;
			_explodeHitVO.hitType = 5;
			_explodeHitVO.hurtType = 1;
			_explodeHitFrame = 10;
			_explodeSteelFrame = GameConfig.HURT_SKILL_FRAME_BLEACH;
			
			isAllowBeHit = false;
			_usedPassiveCdFrame = 5;
		}
		
		public function replaceSkill():void {
			_fighterCtrl.getEffectCtrl().replaceSkill();
			_fighterCtrl.moveToTarget(200, 0);
			
			setVelocity(0, 0);
			idle();
			
			isAllowBeHit = false;
			super.render();
			renderAnimate();
			
			_fighterCtrl.setDirectToTarget();
			_replaceSkillFrame = GameConfig.HURT_SKILL_FRAME_NARUTO;
			_usedPassiveCdFrame = 5;
		}
		
		override public function getArea():Rectangle {
			if (!_area) {
				_area = getBodyArea();
			}
			
			return _area;
		}
		
		public function hasWankai():Boolean {
			return _fighterCtrl.getMcCtrl().getFighterMc().checkFrame("万解");
		}
		
		public function die():void {
			hp = 0;
			isAlive = false;
			
			if (!FighterActionState.isHurting(actionState) && 
				actionState != FighterActionState.DEAD) 
			{
				_fighterCtrl.getMcCtrl().getFighterMc().playHurtDown();
			}
		}
		
		public function relive():void {
			isAlive = true;
			idle();
		}
		
		private function checkRenderToTarget():void {
			var target:IGameSprite = getCurrentTarget();
			if (target == null || !(target is FighterMain)) {
				isCheckedRender = false;
				return;
			}
			
			var targetFighter:FighterMain = target as FighterMain;
			if (isCheckedRender && targetFighter.isCheckedRender) {
				return;
			}
			
			isCheckedRender = true;
			targetFighter.isCheckedRender = true;
			isRenderBeforeTarget = true;
			targetFighter.isRenderBeforeTarget = false;
		}
		
		/**
		 * 是否正在使用被动中
		 */
		public function isUsedPassiveCdIng():Boolean {
			return _usedPassiveCdFrame > 0;
		}
	}
}
