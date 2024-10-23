/**
 * 已重建完成
 */
package net.play5d.game.obvn.fighter.ctrler {
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import net.play5d.game.obvn.GameConfig;
	import net.play5d.game.obvn.ctrl.EffectCtrl;
	import net.play5d.game.obvn.ctrl.GameLogic;
	import net.play5d.game.obvn.ctrl.game_ctrler.GameCtrler;
	import net.play5d.game.obvn.data.HitType;
	import net.play5d.game.obvn.fighter.FighterAction;
	import net.play5d.game.obvn.fighter.FighterActionState;
	import net.play5d.game.obvn.fighter.FighterAttacker;
	import net.play5d.game.obvn.fighter.FighterMC;
	import net.play5d.game.obvn.fighter.FighterMain;
	import net.play5d.game.obvn.fighter.events.FighterEvent;
	import net.play5d.game.obvn.fighter.events.FighterEventDispatcher;
	import net.play5d.game.obvn.fighter.models.HitVO;
	import net.play5d.game.obvn.fighter.vos.MoveTargetParamVO;
	import net.play5d.game.obvn.interfaces.BaseGameSprite;
	import net.play5d.game.obvn.interfaces.IFighterActionCtrl;
	import net.play5d.game.obvn.interfaces.IGameSprite;
	
	/**
	 * 角色MC控制器
	 */
	public class FighterMcCtrler {
		
		public var effectCtrler:FighterEffectCtrler;
		
		private var _actionCtrler:IFighterActionCtrl;
		private var _mc:FighterMC;
		private var _fighter:FighterMain;
		private var _action:FighterAction = new FighterAction();
		
		private var _doingAction:String;
		private var _doingAirAction:String;
		private var _isFalling:Boolean;
		private var _jumpDelayFrame:int = 0;
		private var _hurtHoldFrame:int = 0;
		private var _defenseHoldFrame:int = 0;
		private var _beHitGap:int;
		private var _doActionFrame:int;
		private var _isTouchFloor:Boolean = true;
		private var _isDefense:Boolean;
		private var _defenseFrameDelay:int = 0;
		private var _moveTargetParam:MoveTargetParamVO;
		private var _hurtDownFrame:int;
		private var _ghostStepIng:Boolean;
		private var _ghostStepFrame:int;
		private var _autoDirectFrame:int;
		private var _justDefenseFrame:int;
		private var _ghostType:int = 0;
		private var _justHurtResume:Boolean;
		
		private var _isContinuousGhostStep:Boolean = true;
		
		public function FighterMcCtrler(fighter:FighterMain) {
			_fighter = fighter;
		}
		
		public function destory():void {
			if (_actionCtrler) {
				_actionCtrler.destory();
				_actionCtrler = null;
			}
			if (_mc) {
				_mc.destory();
				_mc = null;
			}
			
			_fighter = null;
			_action = null;
			_moveTargetParam = null;
			effectCtrler = null;
		}
		
		public function getAction():FighterAction {
			return _action;
		}
		
		public function getFighterMc():FighterMC {
			return _mc;
		}
		
		public function getCurAction():String {
			if (_doingAirAction != null) {
				return _doingAirAction;
			}
			
			return _doingAction;
		}
		
		public function setActionCtrler(v:IFighterActionCtrl):void {
			_actionCtrler = v;
		}
		
		public function setMc(mc:FighterMC):void {
			_mc = mc;
			idle();
		}
		
		public function setSteelBody(v:Boolean, isSuper:Boolean = false):void {
			_fighter.isSteelBody = v;
			_fighter.isSuperSteelBody = v && isSuper;
			
			if (v) {
				effectCtrler.startGlow(isSuper ? 0xFFFF00 : 0xFFFFFF);
			}
			else {
				effectCtrler.endGlow();
			}
		}
		
		public function addQi(qi:Number):void {
			_fighter.addQi(qi);
		}
		
		public function idle(frame:String = "站立"):void {
			var isPlay:Boolean = false;
			
			if (FighterActionState.isHurting(_fighter.actionState)) {
				_justHurtResume = true;
			}
			
			_mc.stopHurtFly();
			endAct();
			
			_doingAction = null;
			_doingAirAction = null;
			
			setSteelBody(false);
			_justDefenseFrame = 0.1 * GameConfig.FPS_GAME;
			
			effectCtrler.endShadow();
			effectCtrler.endShake();
			
			_action.clearAction();
			_action.clearState();
			
			_fighter.actionState = FighterActionState.NORMAL;
			_fighter.isAllowBeHit = !_justHurtResume;
			_fighter.isApplyG = true;
			_fighter.isCross = false;
			_fighter.hurtHit = null;
			_fighter.defenseHit = null;
			_fighter.clearHurtHits();
			_fighter.getDisplay().visible = true;
			
			_isDefense = false;
			_autoDirectFrame = 0;
			
			if (!_isTouchFloor) {
				fall();
			}
			else {
				isPlay = true;
				_fighter.setVelocity(0, 0);
				if (frame == "站立") {
					isPlay = false;
					_action.jumpTimes = _fighter.jumpTimes;
					_action.airHitTimes = _fighter.airHitTimes;
					setAllAct();
				}
				
				_mc.goFrame(frame, isPlay);
			}
		}
		
		public function loop(frame:String):void {
			_mc.goFrame(frame);
		}
		
		public function stop():void {
			_mc.stopRenderMainAnimate();
		}
		
		public function dash(speedPlus:Number = 3):void {
			_action.isDashing = true;
			
			_fighter.setVelocity(_fighter.speed * speedPlus * _fighter.direct, 0);
			_fighter.setDamping(0, 0);
			_fighter.isCross = true;
			_fighter.isAllowBeHit = false;
		}
		
		public function dashStop(loseSpdPercent:Number = 0.5):void {
			var vecx:Number = _fighter.getVecX();
			var damping:Number = Math.abs(vecx) * loseSpdPercent;
			
			_fighter.setDamping(damping);
			_fighter.isAllowBeHit = true;
			_fighter.actionState = 0;
			_action.clearAction();
			_action.isDashing = false;
			_fighter.isCross = false;
		}
		
		public function setAllAct():void {
			setMove();
			setDefense();
			setJump();
			setJumpDown();
			setDash();
			setAttack();
			setSkill1();
			setSkill2();
			setZhao1();
			setZhao2();
			setZhao3();
			setCatch1();
			setCatch2();
			setBisha();
			setBishaUP();
			setBishaSUPER();
			setWankai();
		}
		
		public function setAirAllAct():void {
			setDash();
			setAttackAIR();
			setSkillAIR();
			setBishaAIR();
			setAirMove(true);
		}
		
		public function setAirMove(v:Boolean):void {
			_action.airMove = v;
		}
		
		public function setMove():void {
			setMoveLeft();
			setMoveRight();
		}
		
		public function setMoveLeft():void {
			_action.moveLeft = "走";
		}
		
		public function setMoveRight():void {
			_action.moveRight = "走";
		}
		
		public function setDefense():void {
			_action.defense = "防御";
		}
		
		public function setJump(action:String = "跳"):void {
			if (!_mc.checkFrame(action)) {
				return;
			}
			_action.jump = action;
		}
		
		public function setJumpQuick(action:String = "跳"):void {
			if (!_mc.checkFrame(action)) {
				return;
			}
			_action.jumpQuick = action;
		}
		
		public function setJumpDown(action:String = "落"):void {
			if (!_mc.checkFrame(action)) {
				return;
			}
			_action.jumpDown = action;
		}
		
		public function setDash(action:String = "瞬步"):void {
			if (!_mc.checkFrame(action)) {
				return;
			}
			_action.dash = action;
		}
		
		public function setAttack(action:String = "砍1"):void {
			if (!_mc.checkFrame(action)) {
				return;
			}
			_action.attack = action;
		}
		
		public function setSkill1(action:String = "砍技1"):void {
			if (!_mc.checkFrame(action)) {
				return;
			}
			_action.skill1 = action;
		}
		
		public function setSkill2(action:String = "砍技2"):void {
			if (!_mc.checkFrame(action)) {
				return;
			}
			_action.skill2 = action;
		}
		
		public function setZhao1(action:String = "招1"):void {
			if (!_mc.checkFrame(action)) {
				return;
			}
			_action.zhao1 = action;
		}
		
		public function setZhao2(action:String = "招2"):void {
			if (!_mc.checkFrame(action)) {
				return;
			}
			_action.zhao2 = action;
		}
		
		public function setZhao3(action:String = "招3"):void {
			if (!_mc.checkFrame(action)) {
				return;
			}
			_action.zhao3 = action;
		}
		
		public function setCatch1(action:String = "摔1"):void {
			if (!_mc.checkFrame(action)) {
				return;
			}
			_action.catch1 = action;
		}
		
		public function setCatch2(action:String = "摔2"):void {
			if (!_mc.checkFrame(action)) {
				return;
			}
			_action.catch2 = action;
		}
		
		public function setBisha(action:String = "必杀", qi:int = 100):void {
			if (!_mc.checkFrame(action)) {
				return;
			}
			_action.bisha = action;
			_action.bishaQi = qi;
		}
		
		public function setBishaUP(action:String = "上必杀", qi:int = 100):void {
			if (!_mc.checkFrame(action)) {
				return;
			}
			_action.bishaUP = action;
			_action.bishaUPQi = qi;
		}
		
		public function setBishaSUPER(action:String = "超必杀", qi:int = 300):void {
			if (!_mc.checkFrame(action)) {
				return;
			}
			_action.bishaSUPER = action;
			_action.bishaSUPERQi = qi;
		}
		
		public function setAttackAIR(action:String = "跳砍"):void {
			if (!_mc.checkFrame(action)) {
				return;
			}
			_action.attackAIR = action;
		}
		
		public function setSkillAIR(action:String = "跳招"):void {
			if (!_mc.checkFrame(action)) {
				return;
			}
			_action.skillAIR = action;
		}
		
		public function setBishaAIR(action:String = "空中必杀", qi:int = 100):void {
			if (!_mc.checkFrame(action)) {
				return;
			}
			_action.bishaAIR = action;
			_action.bishaAIRQi = qi;
		}
		
		public function setTouchFloor(action:String = "落地", breakAct:Boolean = true):void {
			if (!_mc.checkFrame(action)) {
				return;
			}
			_action.touchFloor = action;
			_action.touchFloorBreakAct = breakAct;
		}
		
		public function setWankai():void {
			if (_mc.checkFrame("万解")) {
				_action.wanKai = "万解";
			}
			if (_mc.checkFrame("万解W")) {
				_action.wanKaiW = "万解W";
			}
			if (_mc.checkFrame("万解S")) {
				_action.wanKaiS = "万解S";
			}
		}
		
		public function setHitTarget(checker:String, action:String):void {
			_action.hitTarget = action;
			_action.hitTargetChecker = checker;
		}
		
		public function setHurtAction(action:String):void {
			_action.hurtAction = action;
			_fighter.actionState = FighterActionState.HURT_ACT_ING;
		}
		
		public function move(x:Number = 0, y:Number = 0):void {
			if (x == 0 && y == 0) {
				stopMove();
				return;
			}
			
			if (_fighter.isInAir && x != 0) {
				_action.airMove = false;
			}
			
			x *= _fighter.direct;
			_fighter.setVelocity(x, y);
		}
		
		public function movePercent(x:Number = 0, y:Number = 0):void {
			move(_fighter.speed * x, _fighter.speed * y);
		}
		
		public function stopMove():void {
			_fighter.setVelocity(0, 0);
		}
		
		public function damping(x:Number = 0, y:Number = 0):void {
			_fighter.setDamping(x, y);
		}
		
		public function dampingPercent(x:Number = 0, y:Number = 0):void {
			_fighter.setDamping(_fighter.speed * x, _fighter.speed * y);
		}
		
		public function endAct():void {
			_action.clearAction();
			_fighter.actionState = FighterActionState.FREEZE;
			
			setSteelBody(false);
			if (_moveTargetParam != null) {
				moveTarget(null);
			}
		}
		
		public function fire(mcName:String, params:Object = null):void {
			var mc:MovieClip = _mc.getChildByName(mcName) as MovieClip;
			if (mc) {
				if (!params) {
					params = {};
				}
				
				params.mc = mc;
				params.hitVO = _fighter.getCtrler().hitModel.getHitVOByDisplayName(mcName);
				FighterEventDispatcher.dispatchEvent(_fighter, FighterEvent.FIRE_BULLET, params);
			}
			else {
				_fighter.setAnimateFrameOut(function ():void {
					fire(mcName, params);
				}, 1);
			}
		}
		
		public function addAttacker(mcName:String, params:Object = null):void {
			var mc:MovieClip = _mc.getChildByName(mcName) as MovieClip;
			if (mc) {
				if (!params) {
					params = {};
				}
				
				params.mc = mc;
				params.hitVO = _fighter.getCtrler().hitModel.getHitVOByDisplayName(mcName);
				FighterEventDispatcher.dispatchEvent(_fighter, FighterEvent.ADD_ATTACKER, params);
			}
			else {
				_fighter.setAnimateFrameOut(function ():void {
					addAttacker(mcName, params);
				}, 1);
			}
		}
		
		public function isApplyG(v:Boolean):void {
			_fighter.isApplyG = v;
		}
		
		public function gotoAndPlay(frame:String):void {
			_mc.goFrame(frame, true);
		}
		
		public function gotoAndStop(frame:String):void {
			_mc.goFrame(frame, false);
		}
		
		public function hurtFly(x:Number, y:Number):void {
			_mc.playHurtFly(x * _fighter.direct, y, false);
			_action.isHurtFlying = true;
			_fighter.actionState = FighterActionState.HURT_FLYING;
			
			_hurtDownFrame = 0;
			_isFalling = false;
		}
		
		public function moveMC(mmc:DisplayObject, x:Object = null, y:Object = null):void {
			var target:IGameSprite = _fighter.getCurrentTarget();
			
			if (x) {
				if (x is Number) {
					mmc.x = _fighter.x + x;
				}
				else if (x.target != undefined && target) {
					mmc.x = target.x - _fighter.x;
					if (isNaN(Number(x.target))) {
						mmc.x += Number(x.target);
					}
				}
			}
			if (y) {
				if (y is Number) {
					mmc.y = _fighter.y + y;
				}
				else if (y.target != undefined && target) {
					mmc.y = target.y - _fighter.y + Number(y);
					if (isNaN(Number(y.target))) {
						mmc.y += Number(y.target);
					}
				}
			}
		}
		
		public function justHitToPlay(
			hitid:String, frame:String,
			noIdle:Boolean = false, inCludeDefense:Boolean = false):void 
		{
			if (_fighter.getCtrler().justHit(hitid, inCludeDefense)) {
				_mc.goFrame(frame);
			}
			else if (noIdle) {
				idle();
			}
		}
		
		public function getAttacker(name:String):FighterAttackerCtrler {
			var attacker:FighterAttacker = GameCtrler.I.getAttacker(name, _fighter.team.id);
			if (attacker) {
				return attacker.getCtrler();
			}
			
			return null;
		}
		
		public function moveTarget(params:Object = null):void {
			// 关闭吸附
			if (!params && _moveTargetParam) {
				_moveTargetParam.clear();
				_moveTargetParam = null;
				
				return;
			}
			
			_moveTargetParam = new MoveTargetParamVO(params);
			_moveTargetParam.setTarget(_fighter.getCurrentTarget());
		}
		
		public function render():void {
			if (_ghostStepIng) {
				return;
			}
			
			if (_justDefenseFrame > 0) {
				_justDefenseFrame--;
			}
			
			_action.render();
			
			if (_moveTargetParam) {
				renderMoveTarget();
			}
			
			if (_actionCtrler) {
				_actionCtrler.render();
			}
			
			if (_action.isHurtFlying) {
				renderHurtFlying();
				return;
			}
			
			if (_action.isHurting) {
				renderHurt();
				return;
			}
			
			if (_action.isDefenseHiting) {
				renderDefense(false, true);
				return;
			}
			
			if (_action.hitTarget) {
				renderCheckTargetHit();
			}
			
			if (renderWanKaiCtrl()) {
				return;
			}
			
			if (_fighter && _fighter.isInAir || 
				_doingAirAction && !_action.touchFloorBreakAct) 
			{
				renderAirAction();
			}
			else {
				renderFloorAction();
			}
		}
		
		private function renderHurtFlying():void {
			if (!_fighter.isInAir) {
				_isTouchFloor = true;
			}
			if (!_fighter.isAlive) {
				return;
			}
			if (_fighter.actionState == FighterActionState.HURT_DOWN_TAN) {
				_hurtDownFrame = 1;
			}
			
			if (_hurtDownFrame > 0 && ++_hurtDownFrame < 20) {
				if (_actionCtrler.dashJump()) {
					doHurtDownJump();
					
					_hurtDownFrame = 0;
				}
			}
		}
		
		private function renderAssist():void {
			if (_fighter.actionState != FighterActionState.NORMAL && 
				_fighter.actionState != FighterActionState.DEFENCE_ING) 
			{
				return;
			}
			
			if (_actionCtrler.assist() && !_fighter.isUsedPassiveCdIng()) {
				if (_fighter.fzqi >= _fighter.fzqiMax) {
					_fighter.fzqi = 0;
					
					FighterEventDispatcher.dispatchEvent(_fighter, FighterEvent.ADD_ASSISTER);
				}
			}
		}
		
		private function renderFloorAction():void {
			if (!_isTouchFloor) {
				touchFloor();
			}
			
			if (!_actionCtrler || !_actionCtrler.enabled()) {
				if (_mc.currentFrameName == "走" || _mc.currentFrameName == "防御") {
					idle();
				}
				return;
			}
			
			renderAssist();
			if (_action.catch1 && _actionCtrler.catch1()) {
				doCatch(_action.catch1);
			}
			if (_action.catch2 && _actionCtrler.catch2()) {
				doCatch(_action.catch2);
			}
			if (_action.bishaSUPER && _actionCtrler.bishaSUPER()) {
				doBisha(_action.bishaSUPER, _action.bishaSUPERQi, true);
			}
			if (_action.bishaUP && _actionCtrler.bishaUP()) {
				doBisha(_action.bishaUP, _action.bishaUPQi);
			}
			if (_action.bisha && _actionCtrler.bisha()) {
				doBisha(_action.bisha, _action.bishaQi);
			}
			if (_action.skill2 && _actionCtrler.skill2()) {
				doSkill(_action.skill2);
			}
			if (_action.skill1 && _actionCtrler.skill1()) {
				doSkill(_action.skill1);
			}
			if (_action.zhao3 && _actionCtrler.zhao3()) {
				doSkill(_action.zhao3);
			}
			if (_action.zhao2 && _actionCtrler.zhao2()) {
				doSkill(_action.zhao2);
			}
			if (_action.attack && _actionCtrler.attack()) {
				doAttack(_action.attack);
			}
			if (_action.zhao1 && _actionCtrler.zhao1()) {
				doSkill(_action.zhao1);
			}
			if (_action.defense && _actionCtrler.defense()) {
				doDefense();
			}
			if (_action.dash && _actionCtrler.dash()) {
				doDash(_action.dash);
			}
			if (_action.moveLeft && _actionCtrler.moveLEFT()) {
				doMove(_action.moveLeft, -1);
			}
			if (_action.moveRight && _actionCtrler.moveRIGHT()) {
				doMove(_action.moveRight, 1);
			}
			if (_action.jump && _actionCtrler.jump()) {
				doJump(_action.jump);
			}
			if (_action.jumpDown && _actionCtrler.jumpDown()) {
				doJumpDown(_action.jumpDown);
			}
			if (_action.isMoving) {
				renderMoving();
			}
			if (_action.isDefensing) {
				renderDefense();
			}
			
			
			if (FighterActionState.allowGhostStep(_fighter.actionState)) {
				if (_actionCtrler.ghostStep()) {
					doGhostStep();
				}
				if (_actionCtrler.ghostJump()) {
					doGhostJump();
				}
			}
			
			if (FighterActionState.isAttacking(_fighter.actionState)) {
				if (_action.attackAIR && _actionCtrler.attackAIR()) {
					doAirAttack(_action.attackAIR);
				}
				if (_action.skillAIR && _actionCtrler.skillAIR()) {
					doAirSkill(_action.skillAIR);
				}
				if (_action.bishaAIR && _actionCtrler.bishaAIR()) {
					doAirBisha(_action.bishaAIR, _action.bishaAIRQi);
				}
			}
		}
		
		private function renderWanKaiCtrl():Boolean {
			if (!_actionCtrler || !_actionCtrler.enabled()) {
				return false;
			}
			if (_actionCtrler.wanKaiW()) {
				return checkDoWankai(_action.wanKaiW, "万解W");
			}
			if (_actionCtrler.wanKaiS()) {
				return checkDoWankai(_action.wanKaiS, "万解S");
			}
			if (_actionCtrler.wanKai()) {
				return checkDoWankai(_action.wanKai, "万解");
			}
			
			return false;
		}
		
		private function checkDoWankai(action:String, attackingAct:String):Boolean {
			if (action) {
				doWaiKaiAction(action);
				return true;
			}
			
			if (_mc.currentFrameName == "防御") {
				doWaiKaiAction(attackingAct);
				return true;
			}
			
			if (_doingAction == "砍1") {
				if (_doActionFrame < 2) {
					doWaiKaiAction(attackingAct);
					return true;
				}
			}
			
			return false;
		}
		
		public function renderAnimate():void {
			if (_justHurtResume) {
				_fighter.isAllowBeHit = true;
				_justHurtResume = false;
			}
			
			renderBeHitGap();
			if (_mc) {
				_mc.renderAnimate();
			}
			if (_actionCtrler) {
				_actionCtrler.renderAnimate();
			}
			if (_ghostStepIng) {
				renderGhostStep();
				return;
			}
			
			if (_action) {
				if (_action.isHurting) {
					renderHurtAnimate();
				}
				if (_action.isDefenseHiting) {
					renderDefensHiting();
				}
				if (_action.isJumping) {
					renderJumpAnimate();
				}
				if (_doingAction) {
					_doActionFrame++;
				}
				if (_action.isDefensing) {
					renderDefenseAnimate();
				}
			}
			if (_mc && _mc.currentFrameName == "站立") {
				if (++_autoDirectFrame > 5) {
					_fighter.getCtrler().setDirectToTarget();
					_autoDirectFrame = 0;
				}
			}
		}
		
		private function renderAirAction():void {
			if (!_action.isJumping) {
				fall();
			}
			
			_isTouchFloor = false;
			if (!_actionCtrler || !_actionCtrler.enabled()) {
				return;
			}
			
			
			if (_action.attackAIR && _actionCtrler.attackAIR()) {
				doAirAttack(_action.attackAIR);
			}
			if (_action.skillAIR && _actionCtrler.skillAIR()) {
				doAirSkill(_action.skillAIR);
			}
			if (_action.bishaAIR && _actionCtrler.bishaAIR()) {
				doAirBisha(_action.bishaAIR, _action.bishaAIRQi);
			}
			if (_action.jump && _actionCtrler.jump()) {
				doAirJump(_action.jump);
			}
			if (_action.jumpQuick && _actionCtrler.jumpQuick()) {
				doAirJump(_action.jumpQuick);
			}
			
			
			if (FighterActionState.isAttacking(_fighter.actionState)) {
				if (_action.bishaSUPER && _actionCtrler.bishaSUPER()) {
					doBisha(_action.bishaSUPER, _action.bishaSUPERQi, true);
				}
				if (_action.bishaUP && _actionCtrler.bishaUP()) {
					doBisha(_action.bishaUP, _action.bishaUPQi);
				}
				if (_action.bisha && _actionCtrler.bisha()) {
					doBisha(_action.bisha, _action.bishaQi);
				}
				if (_action.skill2 && _actionCtrler.skill2()) {
					doSkill(_action.skill2);
				}
				if (_action.skill1 && _actionCtrler.skill1()) {
					doSkill(_action.skill1);
				}
				if (_action.zhao3 && _actionCtrler.zhao3()) {
					doSkill(_action.zhao3);
				}
				if (_action.zhao2 && _actionCtrler.zhao2()) {
					doSkill(_action.zhao2);
				}
				if (_action.attack && _actionCtrler.attack()) {
					doAttack(_action.attack);
				}
				if (_action.zhao1 && _actionCtrler.zhao1()) {
					doSkill(_action.zhao1);
				}
			}
			
			
			if (FighterActionState.allowGhostStep(_fighter.actionState)) {
				if (_actionCtrler.ghostJump()) {
					doGhostJump();
				}
				if (_actionCtrler.ghostJumpDown()) {
					doGhostJumpDown();
				}
			}
			if (_action.dash && _actionCtrler.dash()) {
				doDashAir(_action.dash);
			}
			if (_action.airMove) {
				doAirMove();
			}
		}
		
		private function renderMoveTarget():void {
			var aimX:Number;
			var aimY:Number;
			
			var target:IGameSprite = _moveTargetParam.target;
			if (!target) {
				return;
			}
			
			if (_moveTargetParam.followMcName) {
				var mc:DisplayObject = _mc.getChildByName(_moveTargetParam.followMcName);
				if (!mc) {
					return;
				}
				
				aimX = _fighter.x + mc.x * _fighter.direct;
				aimY = _fighter.y + mc.y;
			}
			else {
				if (!isNaN(_moveTargetParam.x)) {
					aimX = _moveTargetParam.x;
				}
				if (!isNaN(_moveTargetParam.y)) {
					aimY = _moveTargetParam.y;
				}
			}
			if (_moveTargetParam.speed) {
				if (_moveTargetParam.speed.x > 0 && !isNaN(aimX)) {
					if (target.x > aimX + _moveTargetParam.speed.x) {
						target.x -= _moveTargetParam.speed.x;
					}
					if (target.x < aimX - _moveTargetParam.speed.x) {
						target.x += _moveTargetParam.speed.x;
					}
					if (target.y > aimY + _moveTargetParam.speed.y) {
						if (target is BaseGameSprite) {
							(target as BaseGameSprite).setVecY(-_moveTargetParam.speed.y);
							(target as BaseGameSprite).setDampingY(1);
						}
						else {
							target.y -= _moveTargetParam.speed.y;
						}
					}
					if (target.y < aimY - _moveTargetParam.speed.y) {
						if (target is BaseGameSprite) {
							(target as BaseGameSprite).setVecY(_moveTargetParam.speed.y);
							(target as BaseGameSprite).setDampingY(1);
						}
						else {
							target.y += _moveTargetParam.speed.y;
						}
					}
				}
			}
			else {
				if (!isNaN(aimX)) {
					target.x = aimX;
				}
				if (!isNaN(aimY)) {
					target.y = aimY;
				}
			}
		}
		
		private function fall():void {
			if (_isFalling) {
				return;
			}
			if (_doingAction) {
				return;
			}
			
			_action.clearState();
			_action.clearAction();
			
			setAirAllAct();
			setJump();
			
			_isFalling = true;
			_doingAirAction = null;
			_isTouchFloor = false;
			_isDefense = false;
			_fighter.setVecX(0);
			
			setTouchFloor("落地", true);
			_mc.goFrame("落", false);
		}
		
		public function touchFloor():void {
			if (!_fighter.isAlive) {
				return;
			}
			
			var act:String = _action.touchFloor;
			if (_isFalling) {
				if (!act) {
					act = "落地";
				}
			}
			
			if (act == null) {
				return;
			}
			
			var delayParam:Object = act == "落地" ? {
				call : setAttack,
				delay: 1
			} : null;
			
			doAction(act, false, delayParam);
			effectCtrler.touchFloor();
			
			_action.airHitTimes = _fighter.airHitTimes;
			_action.jumpTimes = _fighter.jumpTimes;
			
			_isTouchFloor = true;
			_isFalling = false;
		}
		
		private function doAction(action:String, airAct:Boolean = false, delayParam:Object = null):void {
			if (action == null) {
				return;
			}
			
			effectCtrler.endShadow();
			effectCtrler.endShake();
			
			_fighter.setVelocity(0, 0);
			
			_action.isMoving = false;
			_action.isDefensing = false;
			_action.isDashing = false;
			
			_doingAction = action;
			_doingAirAction = airAct ? action : null;
			
			_action.clearAction();
			
			_isFalling = false;
			_isDefense = false;
			
			_fighter.isAllowBeHit = true;
			_fighter.isCross = false;
			_fighter.isApplyG = true;
			
			_doActionFrame = 0;
			
			_mc.goFrame(action, true, 0, delayParam);
			_fighter.dispatchEvent(new FighterEvent(FighterEvent.DO_ACTION));
		}
		
		private function setMoveAction():void {
			_action.clearAction();
			_action.isMoving = true;
			
			setMove();
			setAttack();
			setZhao1();
			setZhao3();
			setSkill2();
			setJump();
			setDash();
			setBisha();
			setBishaUP();
			setDefense();
			setCatch1();
			setCatch2();
		}
		
		private function renderMoving():void {
			if (_actionCtrler.moveLEFT()) {
				_fighter.direct = -1;
				move(_fighter.speed);
			}
			else if (_actionCtrler.moveRIGHT()) {
				_fighter.direct = 1;
				move(_fighter.speed);
			}
			else {
				idle();
			}
		}
		
		private function doMove(action:String, direct:int = 1):void {
			if (_action.isMoving) {
				return;
			}
			
			_mc.goFrame(action, true);
			_fighter.actionState = 0;
			setMoveAction();
		}
		
		private function doAirMove():void {
			if (_actionCtrler.moveLEFT()) {
				_fighter.move(-_fighter.speed);
			}
			if (_actionCtrler.moveRIGHT()) {
				_fighter.move(_fighter.speed);
			}
		}
		
		private function renderDefense(setActions:Boolean = true, isJustDefense:Boolean = false):void {
			if (_actionCtrler.moveLEFT()) {
				if (_fighter.direct != -1) {
					_fighter.direct = -1;
					setDefenseAction(setActions, isJustDefense);
				}
			}
			if (_actionCtrler.moveRIGHT()) {
				if (_fighter.direct != 1) {
					_fighter.direct = 1;
					setDefenseAction(setActions, isJustDefense);
				}
			}
		}
		
		private function renderDefenseAnimate():void {
			if (_action.isDefenseHiting) {
				return;
			}
			if (_defenseFrameDelay-- > 0) {
				return;
			}
			if (_actionCtrler.enabled() && Boolean(_actionCtrler.defense())) {
				if (!_isDefense) {
					_isDefense = true;
				}
				
				return;
			}
			
			if (_defenseFrameDelay > -5) {
				return;
			}
			_action.isDefensing = false;
			_mc.goFrame("防御恢复", false, 0, {
				call : idle,
				delay: 1
			});
		}
		
		private function setDefenseAction(setActions:Boolean = true, isJustDefense:Boolean = false):void {
			if (setActions) {
				_action.clearAction();
				_action.clearState();
				_action.isDefensing = true;
				setSkill1();
				setZhao2();
				setBishaSUPER();
				setJumpDown();
			}
			if (isJustDefense) {
				_isDefense = true;
			}
			else {
				_isDefense = _justDefenseFrame > 0;
			}
			
			_defenseFrameDelay = 1;
			_mc.goFrame("防御", true, 3);
		}
		
		private function doDefense():void {
			if (_action.isDefensing) {
				return;
			}
			
			_fighter.actionState = FighterActionState.DEFENCE_ING;
			dampingPercent(1, 1);
			setDefenseAction();
		}
		
		private function doDash(action:String):void {
			if (!_fighter.hasEnergy(20, true)) {
				return;
			}
			
			_fighter.useEnergy(20);
			
			if (_actionCtrler.moveLEFT()) {
				_fighter.direct = -1;
			}
			if (_actionCtrler.moveRIGHT()) {
				_fighter.direct = 1;
			}
			
			doAction(action);
			_fighter.actionState = FighterActionState.DASH_ING;
			_fighter.isAllowBeHit = false;
			
			isApplyG(false);
		}
		
		private function doDashAir(action:String):void {
			if (_action.jumpTimes < 1) {
				return;
			}
			if (!_fighter.hasEnergy(30, true)) {
				return;
			}
			
			_fighter.useEnergy(30);
			
			doAction(action);
			
			_fighter.actionState = FighterActionState.DASH_ING;
			_fighter.isAllowBeHit = false;
			isApplyG(false);
			_action.jumpTimes = 0;
		}
		
		private function doJump(action:String):void {
			if (_action.jumpTimes <= 0) {
				return;
			}
			
			_action.clearAction();
			_action.clearState();
			
			_doingAction = null;
			_doingAirAction = null;
			
			_mc.goFrame("起跳", false);
			_jumpDelayFrame = 2;
			_action.isJumping = true;
			
			_fighter.actionState = FighterActionState.JUMP_ING;
		}
		
		private function doJumpDown(acion:String):void {
			if (_fighter.isTouchBottom) {
				return;
			}
			
			_action.clear();
			_action.jumpTimes = 0;
			
			_fighter.setVecY(5);
			_fighter.setDamping(0, 1);
			_fighter.y += 1;
			
			_isDefense = false;
			_mc.goFrame(acion, false);
			
			setTouchFloor();
		}
		
		private function doAirJump(action:String):void {
			if (_action.jumpTimes <= 0) {
				return;
			}
			
			_action.clearAction();
			_action.clearState();
			
			_doingAction = null;
			_doingAirAction = null;
			_jumpDelayFrame = 1;
			_action.isJumping = true;
			
			_fighter.actionState = FighterActionState.JUMP_ING;
		}
		
		public function renderJumpAnimate():void {
			if (_doingAction) {
				return;
			}
			
			if (_jumpDelayFrame > 0) {
				_jumpDelayFrame--;
				
				if (_jumpDelayFrame == 0) {
					_isFalling = false;
					_action.jumpTimes--;
					
					_mc.goFrame("跳", false);
					_fighter.jump();
					setAirAllAct();
					
					if (_fighter.isInAir) {
						effectCtrler.jumpAir();
					}
					else {
						effectCtrler.jump();
					}
				}
				return;
			}
			
			if (_mc.getCurrentFrameCount() == 2) {
				setJumpQuick();
			}
			
			var vecy:Number = _fighter.getVecY();
			if (_mc.currentFrameName == "跳中") {
				if (_mc.getCurrentFrameCount() >= 4) {
					setJump();
				}
			}
			else if (vecy > -_fighter.jumpPower * 0.35) {
				_mc.goFrame("跳中", false);
			}
			
			if (vecy >= 0) {
				_action.isJumping = false;
				_isFalling = true;
			}
		}
		
		private function doAttack(action:String):void {
			doAction(action);
			_fighter.actionState = FighterActionState.ATTACK_ING;
		}
		
		private function doSkill(action:String):void {
			doAction(action);
			_fighter.actionState = FighterActionState.SKILL_ING;
		}
		
		private function doCatch(action:String):void {
			if (!allowCatch()) {
				return;
			}
			
			doAction(action);
			_fighter.actionState = FighterActionState.SKILL_ING;
		}
		
		private function doBisha(action:String, qi:int, isSuper:Boolean = false):void {
			if (!_fighter.useQi(qi)) {
				return;
			}
			
			_fighter.actionState = 
				isSuper ? 
				FighterActionState.BISHA_SUPER_ING : 
				FighterActionState.BISHA_ING
			;
			
			doAction(action);
		}
		
		private function doWaiKaiAction(action:String):void {
			if (!_mc.checkFrame(action)) {
				return;
			}
			if (!_fighter.useQi(300)) {
				return;
			}
			
			_fighter.actionState = FighterActionState.WAN_KAI_ING;
			doAction(action);
			_fighter.isAllowBeHit = false;
		}
		
		private function doAirAttack(action:String):void {
			if (_doingAction == null && _action.airHitTimes <= 0) {
				return;
			}
			
			_fighter.addDamping(0, 3);
			_action.airHitTimes--;
			_action.jumpTimes = 0;
			
			doAction(action, true);
			
			_fighter.actionState = FighterActionState.ATTACK_ING;
		}
		
		private function doAirSkill(action:String):void {
			if (_doingAction == null && _action.airHitTimes <= 0) {
				return;
			}
			
			if (_action.isJumping) {
				var act:String = null;
				
				if (_actionCtrler.zhao3()) {
					act = "跳招-上";
				}
				if (_actionCtrler.zhao2()) {
					act = "跳招-下";
				}
				if (act && _mc.checkFrame(act)) {
					action = act;
				}
			}
			
			_action.airHitTimes = 0;
			_action.jumpTimes = 0;
			doAction(action, true);
			
			_fighter.actionState = FighterActionState.SKILL_ING;
		}
		
		private function doAirBisha(action:String, qi:int):void {
			if (_doingAction == null && _action.airHitTimes <= 0) {
				return;
			}
			if (!_fighter.useQi(qi)) {
				return;
			}
			
			_fighter.actionState = FighterActionState.BISHA_ING;
			_action.airHitTimes = 0;
			doAction(action, true);
		}
		
		public function beHit(hitvo:HitVO, hitRect:Rectangle = null):void {
			if (_action.hurtAction) {
				doAction(_action.hurtAction);
				return;
			}
			if (_moveTargetParam != null) {
				moveTarget(null);
			}
			
			if (_fighter.getIsTouchSide()) {
				if (hitvo.owner && hitvo.owner is BaseGameSprite) {
					var ownersp:BaseGameSprite = hitvo.owner as BaseGameSprite;
					
					if (Math.abs(_fighter.x - hitvo.owner.x) < 100) {
						const dampingX:Number = 0.3;
						
						var isSelfOnTargetLeft:Boolean = _fighter.x < ownersp.x;
						var direct:int = isSelfOnTargetLeft ? 1 : -1;
						
						if (isSelfOnTargetLeft && ownersp.direct == 1 || 
							!isSelfOnTargetLeft && ownersp.direct == -1) 
						{
							direct = 0;
						}
						
						var vecx:Number = hitvo.hitx * direct * 1.4;
						if (vecx > 20) {
							vecx = 20;
						}
						if (vecx < -20) {
							vecx = -20;
						}
						ownersp.setVec2(vecx, 0, dampingX, 0);
					}
				}
			}
			if (_isDefense) {
				if (hitvo.isBreakDef && hitvo.hitType == HitType.CATCH) {
					doHurt(hitvo, hitRect);
					
					return;
				}
				
				if (hitvo.checkDirect && hitvo.owner) {
					if (checkDefDirect(hitvo.owner)) {
						doHurt(hitvo, hitRect);
						
						return;
					}
				}
				
				doDefenseHit(hitvo, hitRect);
			}
			else if (_fighter.isSteelBody && _fighter.isAlive) {
				doSteelHurt(hitvo, hitRect);
			}
			else {
				doHurt(hitvo, hitRect);
			}
		}
		
		private function checkDefDirect(hiter:IGameSprite):Boolean {
			if (_fighter.x < hiter.x - 5) {
				return _fighter.direct < 0 && hiter.direct < 0;
			}
			if (_fighter.x > hiter.x + 5) {
				return _fighter.direct > 0 && hiter.direct > 0;
			}
			
			return false;
		}
		
		private function doSteelHurt(hitvo:HitVO, hitRect:Rectangle):void {
			if (!_fighter.isSuperSteelBody && 
				(_fighter.energyOverLoad || hitvo.isBisha() || hitvo.isCatch())) 
			{
				doHurt(hitvo, hitRect);
				return;
			}
			
			_fighter.hurtHit = hitvo;
			
			// 钢身减伤
			if (_fighter.isSuperSteelBody) {
				_fighter.loseHp(hitvo.getDamage() * 0.3);
			}
			else {
				_fighter.loseHp(hitvo.getDamage() * 0.65);
			}
			
			if (_fighter.isAlive && GameLogic.checkFighterDie(_fighter)) {
				FighterEventDispatcher.dispatchEvent(_fighter, FighterEvent.DIE);
				_fighter.isAlive = false;
				
				doHurt(hitvo, hitRect);
				return;
			}
			if (hitvo.hurtType == HitType.KAN) {
				_beHitGap = 10;
			}
			else {
				_beHitGap = 4;
			}
			
			// 钢身耗耐
			if (_fighter.isSuperSteelBody) {
				_fighter.useEnergy(hitvo.getDamage() * 0.2);
			}
			else if (hitvo.isBreakDef) {
				_fighter.useEnergy(hitvo.getDamage());
			}
			else {
				_fighter.useEnergy(hitvo.getDamage() * 0.4);
			}
			
			_fighter.isAllowBeHit = false;
			if (!_fighter.isSuperSteelBody) {
				var hitx:Number = hitvo.hitx;
				var hity:Number = hitvo.hity;
				
				if (hitvo.owner) {
					hitx *= hitvo.owner.direct;
				}
				
				var vev2X:Number = hitx;
				var vev2Y:Number = hity;
				if (hitvo.isBreakDef) {
					vev2X *= 2;
					vev2Y *= 2;
				}
				
				_fighter.setVec2(vev2X, vev2Y, Math.abs(hitx * 0.1), Math.abs(hity * 0.1));
			}
			if (hitvo && hitRect) {
				EffectCtrl.I.doSteelHitEffect(hitvo, hitRect, _fighter);
			}
		}
		
		private function doHurt(hitvo:HitVO, hitRect:Rectangle):void {
			effectCtrler.endShadow();
			effectCtrler.endShake();
			
			_fighter.hurtHit = hitvo;
			_fighter.loseHp(hitvo.getDamage());
			
			if (_fighter.isAlive && GameLogic.checkFighterDie(_fighter)) {
				FighterEventDispatcher.dispatchEvent(_fighter, FighterEvent.DIE);
				_fighter.isAlive = false;
			}
			
			_beHitGap = 4;
			_fighter.isCross = false;
			_fighter.isAllowBeHit = false;
			_fighter.isApplyG = true;
			_isDefense = false;
			
			var hitx:Number = hitvo.hitx;
			var hity:Number = hitvo.hity;
			if (hitvo.owner) {
				hitx *= hitvo.owner.direct;
			}
			if (_fighter.isInAir) {
				if (hity <= 0) {
					hity -= 3;
				}
			}
			else if (hity < 0) {
				hity -= 6;
				_isTouchFloor = false;
			}
			
			_action.clearState();
			_doingAirAction = null;
			_doingAction = null;
			setSteelBody(false);
			
			if (hitvo.hurtType == 0) {
				_action.isHurting = true;
				_hurtHoldFrame = Math.round(hitvo.hurtTime / 1000 * 30) + GameConfig.HURT_FRAME_OFFSET;
				if (_hurtHoldFrame < 4) {
					_hurtHoldFrame = 4;
				}
				if (hitvo.hitType == HitType.CATCH) {
					_mc.goFrame("被打", false);
				}
				else {
					_mc.goFrame("被打", true, 7);
				}
				
				_fighter.actionState = FighterActionState.HURT_ING;
				_fighter.setVelocity(hitx, hity);
				_fighter.setDamping(0.1, 0.5);
				if (_fighter.isAlive && HitType.isHeavy(hitvo.hitType)) {
					_fighter.getCtrler().getVoiceCtrl().playVoice(0, 0.5);
				}
			}
			if (hitvo.hurtType == 1) {
				_action.isHurtFlying = true;
				_fighter.actionState = FighterActionState.HURT_FLYING;
				_hurtDownFrame = 0;
				_mc.playHurtFly(hitx, hity);
				if (_fighter.isAlive) {
					_fighter.getCtrler().getVoiceCtrl().playVoice(FighterVoice.HURT_FLY, 1);
				}
				else {
					_fighter.getCtrler().getVoiceCtrl().playVoice(FighterVoice.DIE, 1);
				}
			}
			
			if (hitvo && hitRect) {
				EffectCtrl.I.doHitEffect(hitvo, hitRect, _fighter);
			}
			
			_isFalling = false;
		}
		
		private function renderHurt():void {
			if (!_fighter.isAlive) {
				return;
			}
			
			renderHurtBreak();
		}
		
		/**
		 * 检测能否进行 灵压爆发/替身
		 */
		public function isCanHurtBreak():Boolean {
			if (!_fighter.hasEnergy(50)       ||
				_fighter.qi < 100) 
			{
				return false;
			}
			
			var lastHitvo:HitVO   = _fighter.getLastHurtHitVO();
			var bishaHit :Boolean = lastHitvo && lastHitvo.isBisha();
			var breakHit :Boolean = _fighter.hurtBreakHit();
			var damage   :int     = _fighter.currentHurtDamage();
			
			return !bishaHit && !breakHit && !(damage > 210);
		}
		
		private function renderHurtBreak():void {
			if (!_actionCtrler.specailSkill() || !isCanHurtBreak()) {
				return;
			}
			
			_fighter.useQi(100);
			_fighter.useEnergy(100);
			
			if (_fighter.data.comicType == 1) {
				_fighter.replaceSkill();
			}
			else {
				_fighter.energyExplode();
			}
			FighterEventDispatcher.dispatchEvent(_fighter, FighterEvent.HURT_RESUME);
		}
		
		private function renderHurtAnimate():void {
			if (_hurtHoldFrame-- <= 0) {
				if (!_fighter.isAlive) {
					_action.clearState();
					
					if (_fighter.isInAir) {
						var vec:Point = _fighter.getVec2();
						hurtFly(vec.x, vec.y);
					}
					else {
						_mc.playHurtDown();
					}
					_fighter.getCtrler().getVoiceCtrl().playVoice(FighterVoice.DIE, 1);
				}
				else {
					hurtResume();
				}
			}
		}
		
		private function hurtResume():void {
			if (!_fighter.isInAir && !_isTouchFloor) {
				_isTouchFloor = true;
			}
			
			idle();
			FighterEventDispatcher.dispatchEvent(_fighter, FighterEvent.HURT_RESUME);
		}
		
		private function renderBeHitGap():void {
			if (_beHitGap > 0) {
				if (--_beHitGap <= 0) {
					_fighter.isAllowBeHit = true;
				}
			}
		}
		
		private function doDefenseHit(hitvo:HitVO, hitRect:Rectangle):void {
			_fighter.loseHp(hitvo.getDamage() * GameConfig.DEFENSE_LOSE_HP_RATE);
			
			if (_fighter.isAlive && GameLogic.checkFighterDie(_fighter)) {
				FighterEventDispatcher.dispatchEvent(_fighter, FighterEvent.DIE);
				_fighter.isAlive = false;
				doHurt(hitvo, hitRect);
				
				return;
			}
			
			_fighter.defenseHit = hitvo;
			
			var defEnergy:int = 0;
			if (hitvo.isBreakDef) {
				defEnergy = 90;
			}
			else {
				defEnergy = hitvo.getDamage() / 5;
				if (defEnergy > 50) {
					defEnergy = 50;
				}
			}
			
			if (!_fighter.hasEnergy(defEnergy, false)) {
				_fighter.useEnergy(defEnergy);
				doBreakDefense(hitvo, hitRect);
				
				return;
			}
			
			_fighter.useEnergy(defEnergy);
			_beHitGap = 4;
			_fighter.isAllowBeHit = false;
			
			var hitx:Number = hitvo.hitx;
			if (hitvo.owner) {
				hitx *= hitvo.owner.direct;
			}
			
			_action.isDefenseHiting = true;
			if (hitvo.hurtType == 0) {
				_defenseHoldFrame = hitvo.hurtTime / 1000 * GameConfig.FPS_GAME / 5;
				if (_defenseHoldFrame < 5) {
					_defenseHoldFrame = 5;
				}
				if (_defenseHoldFrame > 10) {
					_defenseHoldFrame = 10;
				}
			}
			else {
				_defenseHoldFrame = 10;
				_beHitGap = 8;
			}
			_fighter.setVelocity(hitx, 0);
			_fighter.setDamping(1, 0);
			if (hitvo && hitRect) {
				EffectCtrl.I.doDefenseEffect(hitvo, hitRect, _fighter.defenseType);
			}
		}
		
		private function doBreakDefense(hitvo:HitVO, hitRect:Rectangle):void {
			_fighter.loseHp(hitvo.getDamage() / 10);
			
			if (hitvo.hurtType == 0) {
				_beHitGap = 4;
			}
			if (hitvo.hurtType == 1) {
				_beHitGap = 10;
			}
			
			_fighter.isAllowBeHit = false;
			_fighter.energyOverLoad = false;
			_isDefense = false;
			
			var hitx:Number = hitvo.hitx;
			if (hitx < 5) {
				hitx = 5;
			}
			if (hitx > 10) {
				hitx = 10;
			}
			if (hitvo.owner) {
				hitx *= hitvo.owner.direct;
			}
			
			_action.clearState();
			_action.isHurting = true;
			_hurtHoldFrame = 42;
			
			_mc.goFrame("被打", true, 7);
			
			_fighter.actionState = FighterActionState.HURT_ING;
			_fighter.setVelocity(hitx);
			_fighter.setDamping(0.1);
			
			if (hitvo && hitRect) {
				var effectx:Number = hitRect.x + hitRect.width / 2;
				var effecty:Number = hitRect.y + hitRect.height / 2;
				
				EffectCtrl.I.doDefenseEffect(hitvo, hitRect, _fighter.defenseType);
				EffectCtrl.I.doEffectById("break_def", effectx, effecty, _fighter.direct);
			}
		}
		
		private function renderDefensHiting():void {
			if (_defenseHoldFrame > 0) {
				_defenseHoldFrame--;
			}
			else if (_fighter.getVecX() == 0) {
				_action.isDefenseHiting = false;
			}
		}
		
		private function renderCheckTargetHit():void {
			var checkerName:String = _action.hitTargetChecker;
			if (!checkerName) {
				return;
			}
			
			var rect:Rectangle = _fighter.getCtrler().getHitCheckRect(checkerName);
			if (!rect) {
				return;
			}
			
			var targets:Vector.<IGameSprite> = _fighter.getTargets();
			if (!targets) {
				return;
			}
			
			for (var i:int = 0; i < targets.length; i++) {
				if (targets[i] is FighterMain) {
					var body:Rectangle = targets[i].getBodyArea();
					if (body && rect.intersects(body)) {
						doAction(_action.hitTarget);
					}
				}
			}
		}
		
		private function allowCatch():Boolean {
			var target:IGameSprite = _fighter.getCurrentTarget();
			if (!target) {
				return false;
			}
			
			if (target is FighterMain) {
				if ((target as FighterMain).actionState == FighterActionState.HURT_ING) {
					return false;
				}
			}
			
			var targetBody:Rectangle = target.getBodyArea();
			var selfBody:Rectangle = _fighter.getBodyArea();
			if (!targetBody || !selfBody) {
				return false;
			}
			
			if (_fighter.isCheckedRender && _fighter.isRenderBeforeTarget) {
				var nextPos:Point = getTargetNextPos();
				if (nextPos) {
					targetBody.x += nextPos.x;
					targetBody.y += nextPos.y;
				}
			}
			
			var disX:Number = 0;
			var disY:Number = Math.abs(_fighter.y - target.y);
			if (selfBody.x < targetBody.x) {
				if (_fighter.direct < 0) {
					return false;
				}
				disX = targetBody.x - (selfBody.x + selfBody.width);
			}
			else {
				if (_fighter.direct > 0) {
					return false;
				}
				disX = selfBody.x - (targetBody.x + targetBody.width);
			}
			
			return disX < 2 && disY < 1;
		}
		
		private function getTargetNextPos():Point {
			if (!_fighter.isCheckedRender) {
				return null;
			}
			
			var target:IGameSprite = _fighter.getCurrentTarget();
			if (!target || !(target is BaseGameSprite)) {
				return null;
			}
			
			var targetSp:BaseGameSprite = target as BaseGameSprite;
			
			var nextX:Number = 0;
			var nextY:Number = 0;
			if (targetSp.getVecX()) {
				nextX += targetSp.getVecX();
			}
			if (targetSp.getVecY()) {
				nextY += targetSp.getVecY();
			}
			
			var vec2:Point = targetSp.getVec2();
			if (vec2.x && vec2.y) {
				nextX += vec2.x;
				nextY += vec2.y;
			}
			
			nextX *= GameConfig.SPEED_PLUS_DEFAULT;
			nextY *= GameConfig.SPEED_PLUS_DEFAULT;
			
			return new Point(nextX, nextY);
		}
		
		private function doHurtDownJump():void {
			if (_doingAction == "起身") {
				return;
			}
			if (_fighter.currentHurtDamage() > 240) {
				return;
			}
			if (!_fighter.hasEnergy(30)) {
				return;
			}
			
			_mc.stopHurtFly();
			_fighter.useEnergy(30);
			
			var vecx:Number = _fighter.getVecX();
			doAction("起身");
			
			_fighter.isAllowBeHit = false;
			_fighter.setVelocity(vecx);
			_fighter.setDamping(vecx * 0.1);
			
			FighterEventDispatcher.dispatchEvent(_fighter, FighterEvent.HURT_RESUME);
		}
		
		public function sayIntro():void {
			_fighter.actionState = FighterActionState.KAI_CHANG;
			_mc.goFrame("开场");
		}
		
		public function doWin():void {
			_fighter.actionState = FighterActionState.WIN;
			_mc.goFrame("胜利");
		}
		
		public function doLose():void {
			_fighter.actionState = FighterActionState.LOSE;
			_mc.goFrame("失败");
		}
		
		private function doGhostStep():void {
			if (_isContinuousGhostStep && startGhostStep()) {
				move(8, 0);
				
				_mc.goFrame("走", true);
				_ghostType = 0;
			}
		}
		
		private function doGhostJump():void {
			if (startGhostStep()) {
				move(0, -12);
				damping(0, 0.1);
				
				_mc.goFrame("跳", false);
				_action.jumpTimes--;
				_ghostType = 1;
			}
		}
		
		private function doGhostJumpDown():void {
			if (startGhostStep()) {
				move(0, 15);
				_mc.goFrame("落", false);
				_ghostType = 2;
			}
		}
		
		private function startGhostStep():Boolean {
			if (_fighter.qi < 60) {
				return false;
			}
			if (!_fighter.hasEnergy(80, true)) {
				return false;
			}
			
			_fighter.useQi(60);
			_fighter.useEnergy(80);
			_fighter.getCtrler().setDirectToTarget();
			
			_ghostStepIng = true;
			_ghostStepFrame = 30 * 0.4;
			
			_fighter.isAllowBeHit = false;
			_fighter.isCross = true;
			
			effectCtrler.ghostStep();
			_isContinuousGhostStep = false;
			
			return true;
		}
		
		private function renderGhostStep():void {
			if (_ghostStepFrame-- <= 0) {
				if (_ghostType == 1) {
					
					var vecy:Number = _fighter.getVecY();
					_action.isJumping = false;
					
					endGhostStep();
					
					_fighter.setVelocity(0, vecy);
					_fighter.setDamping(0, -vecy / 10);
					
					setAirMove(true);
					
					return;
				}
				endGhostStep();
			}
			
			if (_ghostType == 2) {
				if (GameLogic.isTouchBottomFloor(_fighter)) {
					endGhostStep();
				}
			}
		}
		
		private function endGhostStep():void {
			if (_ghostStepFrame > 0) {
				_fighter.delayCall(recoverIsContinuousGhostStep, _ghostStepFrame);
			}
			else {
				recoverIsContinuousGhostStep();
			}
			
			_ghostStepIng = false;
			effectCtrler.endGhostStep();
			
			_fighter.getCtrler().setDirectToTarget();
			idle();
		}
		
		private function recoverIsContinuousGhostStep():void {
			_isContinuousGhostStep = true;
		}
	}
}
