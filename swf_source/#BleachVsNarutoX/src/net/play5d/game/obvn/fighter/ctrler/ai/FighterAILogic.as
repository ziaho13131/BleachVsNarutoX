/**
 * 已重建完成
 */
package net.play5d.game.obvn.fighter.ctrler.ai {
	import flash.geom.Point;
	
	import net.play5d.game.obvn.GameConfig;
	import net.play5d.game.obvn.fighter.Assister;
	import net.play5d.game.obvn.fighter.Bullet;
	import net.play5d.game.obvn.fighter.FighterActionState;
	import net.play5d.game.obvn.fighter.FighterAttacker;
	import net.play5d.game.obvn.fighter.FighterMain;
	import net.play5d.game.obvn.interfaces.IGameSprite;
	
	/**
	 * 游戏AI逻辑
	 */
	public class FighterAILogic extends FighterAILogicBase {
		
		public var moveLeft:Boolean;
		public var moveRight:Boolean;
		public var jump:Boolean;
		public var jumpDown:Boolean;
		public var dash:Boolean;
		public var downJump:Boolean;
		public var defense:Boolean;
		
		private var _moveKeep:Number = 40;
		private var _catchMoveKeep:Number = 15;
		private var _dashKeep:Number = 250;
		private var _jumpKeep:Number = 50;
		
		public var attack:Boolean;
		public var attackAIR:Boolean;
		public var skillAIR:Boolean;
		public var bishaAIR:Boolean;
		public var skill1:Boolean;
		public var skill2:Boolean;
		public var zhao1:Boolean;
		public var zhao2:Boolean;
		public var zhao3:Boolean;
		public var catch1:Boolean;
		public var catch2:Boolean;
		public var bisha:Boolean;
		public var bishaUP:Boolean;
		public var bishaSUPER:Boolean;
		
		public var assist:Boolean;
		public var specialSkill:Boolean;
		public var ghostStep:Boolean;
		public var ghostJump:Boolean;
		public var ghostJumpDowm:Boolean;
		
		private var _moveFrame:int;
		
		private var _defenseFrame:int;
		
		private var _ghostFrame:int;
		
		public function FighterAILogic(AILevel:int, fighter:FighterMain) {
			super(AILevel, fighter);
		}
		
		override public function render():void {
			super.render();
			if (!_fighter || !_target) {
				return;
			}
			
			updateMoveAI();
			updateJumpAI();
			updateJumpDownAI();
			updateHurtAI();
			updateDefenseAI();
			updateSpecialSkill();
			updateGhostStep();
		}
		
		override protected function updateActionAI():void {
			updateDashAI();
			updateAttackAI();
			updateSkill();
			updateBisha();
			updateCache();
			updateAssist();
		}
		
		private function updateHurtAI():void {
			downJump = false;
			
			var downJumpObj:Object = {};
			downJumpObj["defult"] = [0, 0, 0.5, 1, 3, 5];
			
			const BISHA:Array = [0, 1, 2, 4, 6, 10];
			downJumpObj[FighterActionState.BISHA_SUPER_ING] = BISHA;
			downJumpObj[FighterActionState.BISHA_ING] = BISHA;
			downJump = getAIByFighterState(downJumpObj);
		}
		
		private function updateMoveAI():void {
			var moving:Boolean = false;
			
			moveLeft = false;
			moveRight = false;
			
			var isDefensing:Boolean = _fighter.actionState == FighterActionState.DEFENCE_ING;
			var targetIsSuperSteelBody:Boolean = _targetFighter.isSuperSteelBody;
			if (isDefensing) {
				var defenseMove:Boolean = getAIResult(1, 2, 3, 4, 5, 6);
				if (defenseMove) {
					if (_fighter.x > _target.x + 1) {
						moveLeft = true;
					}
					if (_fighter.x < _target.x - 1) {
						moveRight = true;
					}
				}
				return;
			}
			if (_moveFrame < GameConfig.FPS_GAME) {
				_moveFrame++;
				moving = true;
			}
			else {
				var moveObj:Object = {};
				moveObj["defult"] = [3, 5, 7, 8, 9, 10];
				moveObj[FighterActionState.ATTACK_ING] = [2, 4, 5, 3, 1, 0.5];
				moveObj[FighterActionState.SKILL_ING] = [2, 4, 3, 2, 0.5, 0.2];
				
				const BISHA:Array = [2, 1, 0, 0, 0, 0];
				moveObj[FighterActionState.BISHA_SUPER_ING] = BISHA;
				moveObj[FighterActionState.BISHA_ING] = BISHA;
				
				const HURT:Array = [4, 2, 1, 0.5, 0, 0];
				moveObj[FighterActionState.HURT_FLYING] = HURT;
				moveObj[FighterActionState.HURT_DOWN] = HURT;
				moveObj[FighterActionState.HURT_DOWN_TAN] = HURT;
				
				moving = getAIByFighterState(moveObj);
				if (moving) {
					_moveFrame = 0;
				}
			}
			if (moving) {
				if (targetIsSuperSteelBody) {
					if (_fighter.x > _target.x) {
						moveRight = true;
					}
					else {
						moveLeft = true;
					}
				}
				else {
					var moveKeep:Number = catch1 || catch2 ? _catchMoveKeep : _moveKeep;
					if (_fighter.x > _target.x + moveKeep) {
						moveLeft = true;
					}
					if (_fighter.x < _target.x - moveKeep) {
						moveRight = true;
					}
				}
			}
			if (!moveLeft && !moveRight) {
				_moveFrame = GameConfig.FPS_GAME;
				if (_fighter.direct == _target.direct) {
					if (_fighter.x > _target.x) {
						moveLeft = true;
					}
					else {
						moveRight = true;
					}
				}
			}
		}
		
		private function updateJumpAI():void {
			var jumpObj:Object = {};
			jump = false;
			
			if (_isConting) {
				jumpObj["defult"] = [1, 2, 3, 2, 1, 0];
				jumpObj[FighterActionState.HURT_ING] = [0, 1, 2, 3, 4, 5];
			}
			else if (_fighter.y > _target.y + _jumpKeep) {
				jumpObj["defult"] = [8, 6, 5, 4, 3, 2];
				
				const RATE:Array = [4, 3, 2, 1, 0.5, 0];
				jumpObj[FighterActionState.BISHA_SUPER_ING] = RATE;
				jumpObj[FighterActionState.BISHA_ING] = RATE;
				jumpObj[FighterActionState.HURT_FLYING] = RATE;
				jumpObj[FighterActionState.HURT_DOWN] = RATE;
				jumpObj[FighterActionState.HURT_DOWN_TAN] = RATE;
			}
			else {
				jumpObj["defult"] = [2, 1, 0.5, 0, 0, 0];
			}
			
			jump = getAIByFighterState(jumpObj);
			if (_isConting && jump) {
				addContOrder("jump", 10);
			}
		}
		
		private function updateJumpDownAI():void {
			var jumpObj:Object = {};
			jumpDown = false;
			
			if (_fighter.y < _target.y - _jumpKeep) {
				jumpObj["defult"] = [8, 6, 5, 4, 3, 2];
				const BISHA:Array = [4, 3, 2, 1, 0.5, 0];
				jumpObj[FighterActionState.BISHA_SUPER_ING] = BISHA;
				jumpObj[FighterActionState.BISHA_ING] = BISHA;
			}
			else {
				jumpObj["defult"] = [2, 1, 0.5, 0, 0, 0];
			}
			
			jumpDown = getAIByFighterState(jumpObj);
		}
		
		private function updateDashAI():void {
			dash = false;
			
			var RATE:Array;
			var dashObj:Object = {};
			
			var dis:Number = getTargetDistance(_target).x;
			var direct:Number = _target.x > _fighter.x ? 1 : -1;
			var targetIsSuperSteelBody:Boolean = _targetFighter.isSuperSteelBody;
			if (_fighter.energy < 40) {
				if (dis > _dashKeep && _fighter.direct == direct) {
					dashObj["defult"] = [0, 0, 0.1, 0.5, 0, 0];
					
					RATE = [0, 0.05, 0.3, 1, 0, 0];
					dashObj[FighterActionState.SKILL_ING] = RATE;
					dashObj[FighterActionState.ATTACK_ING] = RATE;
					RATE = [0, 0, 0, 0, 0, 0];
					dashObj[FighterActionState.BISHA_SUPER_ING] = RATE;
					dashObj[FighterActionState.BISHA_ING] = RATE;
				}
				else {
					RATE = [0, 0, 0, 0, 0, 0];
					dashObj["defult"] = RATE;
					dashObj[FighterActionState.BISHA_SUPER_ING] = RATE;
					dashObj[FighterActionState.BISHA_ING] = RATE;
					dashObj[FighterActionState.SKILL_ING] = RATE;
					dashObj[FighterActionState.ATTACK_ING] = RATE;
				}
			}
			else if (dis > _dashKeep && _fighter.direct == _target.direct) {
				if (targetIsSuperSteelBody) {
					RATE = [0, 0, 0, 0, 0, 0];
					dashObj["defult"] = RATE;
					dashObj[FighterActionState.ATTACK_ING] = RATE;
					dashObj[FighterActionState.SKILL_ING] = RATE;
					dashObj[FighterActionState.BISHA_SUPER_ING] = RATE;
					dashObj[FighterActionState.BISHA_ING] = RATE;
				}
				else {
					dashObj["defult"] = [0, 1, 2, 4, 6, 8];
					dashObj[FighterActionState.ATTACK_ING] = [0, 0, 0, 0.5, 1, 2];
					dashObj[FighterActionState.SKILL_ING] = [1, 0.5, 0, 0, 0, 0];
					RATE = [0, 0, 0, 0, 0, 0];
					dashObj[FighterActionState.BISHA_SUPER_ING] = RATE;
					dashObj[FighterActionState.BISHA_ING] = RATE;
				}
			}
			else {
				RATE = [0, 0, 0, 0, 0, 0];
				dashObj["defult"] = RATE;
				dashObj[FighterActionState.BISHA_SUPER_ING] = RATE;
				dashObj[FighterActionState.BISHA_ING] = RATE;
				dashObj[FighterActionState.SKILL_ING] = RATE;
				dashObj[FighterActionState.ATTACK_ING] = RATE;
			}
			
			const HURT:Array = [4, 3, 2, 1, 0.5, 0];
			dashObj[FighterActionState.HURT_FLYING] = HURT;
			dashObj[FighterActionState.HURT_DOWN] = HURT;
			dashObj[FighterActionState.HURT_DOWN_TAN] = HURT;
			
			dash = getAIByFighterState(dashObj);
		}
		
		private function updateDefenseAI():void {
			if (_fighter.energy < 20 || 
				/* 刚身不执行防御 */
				_fighter.isSuperSteelBody || 
				/* 使用过幽步不执行防御 */
				_ghostFrame > 0 ) 
			{
				defense = false;
				return;
			}
			
			if (defense) {
				var ctobj:Object = {};
				ctobj["defult"] = [2, 4, 5, 6, 8, 10];
				ctobj[FighterActionState.FREEZE] = [5, 4, 3, 2, 1, 0];
				ctobj[FighterActionState.NORMAL] = [2, 1, 1, 0, 0, 0];
				
				const DEFENCE:Array = [0, 0, 0, 0, 0, 0];
				ctobj[FighterActionState.DEFENCE_ING] = DEFENCE;
				ctobj[FighterActionState.HURT_ING] = DEFENCE;
				ctobj[FighterActionState.HURT_FLYING] = DEFENCE;
				ctobj[FighterActionState.HURT_DOWN] = DEFENCE;
				
				defense = getAIByFighterState(ctobj);
				if (defense) {
					return;
				}
			}
			var distance:Point = getTargetDistance(_target);
			var resultObj:Object = {};
			resultObj["defult"] = [0, 0, 0, 0, 0, 0];
			if (distance.x < 80 && distance.y < 80) {
				resultObj[FighterActionState.ATTACK_ING] = [1, 2, 4, 6, 8, 10];
			}
			else {
				resultObj[FighterActionState.ATTACK_ING] = [1, 2, 3, 2, 1, 0];
			}
			resultObj[FighterActionState.SKILL_ING] = [1, 3, 5, 7, 9, 10];
			const BISHA:Array = [2, 4, 6, 8, 10, 10];
			resultObj[FighterActionState.BISHA_SUPER_ING] = BISHA;
			resultObj[FighterActionState.BISHA_ING] = BISHA;
			defense = getAIByFighterState(resultObj);
			if (defense) {
				return;
			}
			var targets:Vector.<IGameSprite> = _fighter.getTargets();
//			var _loc9_:* = targets;
			for each(var i:IGameSprite in targets) {
				if (i == _target) {
					continue;
				}
				
				if (i is FighterAttacker && (i as FighterAttacker).isAttacking) {
					defense = getAIResult(2, 4, 6, 8, 10, 10);
					if (defense) {
						return;
					}
				}
				if (i is Bullet && (i as Bullet).isAttacking()) {
					var dis:Point = getTargetDistance(i);
					if (dis.x < 200 && dis.y < 200) {
						defense = getAIResult(2, 4, 6, 8, 10, 10);
					}
					else {
						defense = getAIResult(0.5, 1, 2, 3, 2, 0);
					}
					if (defense) {
						return;
					}
				}
				if (i is Assister && (i as Assister).isAttacking) {
					defense = getAIResult(2, 4, 6, 8, 10, 10);
					if (defense) {
						return;
					}
				}
			}
		}
		
		private function updateAttackAI():void {
			attack = false;
			attackAIR = false;
			
			if (!_fighterAction.attack && !_fighterAction.attackAIR) {
				return;
			}
			if (!targetCanBeHit() || _targetFighter.isSuperSteelBody) {
				return;
			}
			if (_isConting && _targetFighter.actionState != FighterActionState.HURT_ING) {
				return;
			}
			
			var attackObj:Object = {};
			attackObj.defult = _isConting ? [1, 2, 3, 6, 9, 10] : [0.5, 1, 4, 6, 8, 10];
			attackObj[FighterActionState.DEFENCE_ING] = [0.5, 1, 3, 2, 2, 0];
			attackObj[FighterActionState.HURT_ACT_ING] = [0.5, 1, 1, 0.5, 0, 0.1];
			attackObj[FighterActionState.ATTACK_ING] = [0.5, 1, 1, 0, 0, 0];
			
			const RATE:Array = [0, 0, 0, 0, 0, 0];
			attackObj[FighterActionState.BISHA_SUPER_ING] = RATE;
			attackObj[FighterActionState.BISHA_ING] = RATE;
			attackObj[FighterActionState.SKILL_ING] = RATE;
			
			var result:Boolean = getAIByFighterState(attackObj);
			if (!result) {
				return;
			}
			
			var order:int = 10;
			if (_isConting) {
				attack = true;
				attackAIR = _fighter.y < _target.y;
				
				var curAction:String = _fighter.getCtrler().getMcCtrl().getCurAction();
				if (curAction == "砍1") {
					order = 200;
				}
			}
			else {
				attack = targetInRange("kanmian");
				attackAIR = targetInRange("tkanmian");
				order = 300;
			}
			
			if (attack) {
				addContOrder("attack", order);
			}
			if (attackAIR) {
				addContOrder("attackAIR", order);
			}
		}
		
		private function updateSkill():void {
			skill1 = 
				_fighterAction.skill1 && 
				getSkillAI("skill1", "kj1", "kj1mian", 10)
			;
			skill2 = 
				_fighterAction.skill2 && 
				getSkillAI("skill2", "kj2", "kj2mian", 10)
			;
			zhao1 = 
				_fighterAction.zhao1 && 
				getSkillAI("zhao1", "zh1", "zh1mian", 10)
			;
			zhao2 = 
				_fighterAction.zhao2 && 
				getSkillAI("zhao2", "zh2", "zh2mian", 10)
			;
			zhao3 = 
				_fighterAction.zhao3 && 
				getSkillAI("zhao3", "zh3", "zh3mian", 10)
			;
			skillAIR = 
				_fighterAction.skillAIR && 
				getSkillAI("skillAIR", "tz", "tzmian", 15)
			;
		}
		
		private function getSkillAI(id:String, hitId:String, range:String, order:int):Boolean {
			var skillObj:Object = {};
			var result:Boolean;
			
			if (isBreakAct(hitId)) {
				skillObj.defult = _isConting ? [0.1, 0.2, 0.5, 3, 6, 10] : [0, 0.2, 0.5, 2, 1, 0];
				skillObj[FighterActionState.DEFENCE_ING] = _isConting ? [0, 0.2, 0.7, 5, 7, 9] : [0.1, 0.2, 0.5, 1, 2, 2];
			}
			else {
				skillObj.defult = _isConting ? [0, 0, 0.1, 1, 5, 10] : [0.1, 0.5, 1, 3, 2, 0.2];
				skillObj[FighterActionState.DEFENCE_ING] = [0, 0, 1, 1, 0, 0];
			}
			skillObj[FighterActionState.HURT_ACT_ING] = [0.5, 1, 0.5, 0, 0, 0];
			skillObj[FighterActionState.ATTACK_ING] = [0, 0, 0, 1, 1, 2];
			
			const RATE:Array = [0, 0, 0, 0, 0, 0];
			skillObj[FighterActionState.BISHA_SUPER_ING] = RATE;
			skillObj[FighterActionState.BISHA_ING] =  RATE;
			skillObj[FighterActionState.SKILL_ING] = RATE;
			
			result = getAIByFighterState(skillObj) && targetCanBeHit() && targetInRange(range);
			if (result && _isConting) {
				addContOrder(id, isHitDownAct(hitId) ? order : order + 100);
			}
			
			return result;
		}
		
		public function updateBisha():void {
			bisha = false;
			bishaUP = false;
			bishaSUPER = false;
			bishaAIR = false;
			
			if (_targetFighter.isSuperSteelBody || 
				_targetFighter.actionState != FighterActionState.HURT_ING || 
				_fighter.qi < 200 || 
				!_isConting) 
			{
				return;
			}
			bisha = _fighterAction.bisha && getBishaAI("bisha", "bs", "bsmian", 100, 100);
			bishaUP = _fighterAction.bishaUP && getBishaAI("bishaUP", "sbs", "sbsmian", 100, 100);
			bishaSUPER = _fighterAction.bishaSUPER && getBishaAI("bishaSUPER", "cbs", "cbsmian", 300, 200);
			bishaAIR = _fighterAction.bishaAIR && getBishaAI("bishaAIR", "kbs", "kbsmian", 100, 210);
		}
		
		private function getBishaAI(id:String, hitId:String, range:String, qi:int, order:int):Boolean {
			var bishaObj:Object = {};
			var result:Boolean = false;
			
			if (_fighter.qi >= qi) {
				if (isBreakAct(hitId)) {
					bishaObj.defult = _isConting ? [0, 0, 0.3, 2, 5, 10] : [0.1, 0.2, 0.5, 2, 2, 2];
					bishaObj[FighterActionState.DEFENCE_ING] = _isConting ? [0, 0, 0.5, 3, 7, 9] : [0.1, 0.2, 1, 6, 8, 10];
				}
				else {
					bishaObj.defult = _isConting ? [0, 0, 0.5, 4, 8, 10] : [0.2, 0.5, 1, 2, 2, 0];
					bishaObj[FighterActionState.HURT_ING] = [0.2, 0.5, 1, 3, 5, 6];
					bishaObj[FighterActionState.JUMP_ING] = [0.2, 0.5, 1, 3, 4, 4];
					bishaObj[FighterActionState.DEFENCE_ING] = _isConting ? [0.2, 0.5, 1, 3, 2, 1] : [0.2, 0.5, 1, 2, 1, 0];
				}
				bishaObj[FighterActionState.HURT_ACT_ING] = [0.2, 0.5, 0, 0, 0, 0];
				bishaObj[FighterActionState.ATTACK_ING] = [0, 0.2, 0.5, 2, 1, 1];
				
				const RATE:Array = [0, 0, 0, 0, 0, 0];
				bishaObj[FighterActionState.BISHA_SUPER_ING] = RATE;
				bishaObj[FighterActionState.BISHA_ING] = RATE;
				bishaObj[FighterActionState.SKILL_ING] = RATE;
				
				result = getAIByFighterState(bishaObj) && targetCanBeHit() && targetInRange(range);
			}
			if (result && _isConting) {
				addContOrder(id, order);
			}
			
			return result;
		}
		
		private function updateCache():void {
			catch1 = false;
			catch2 = false;
			
			if (_targetFighter && 
				FighterActionState.isHurting(_targetFighter.actionState)) 
			{
				return;
			}
			
			var cacheObj:Object = {};
			var dis:Point = getTargetDistance(_target);
			if (dis.x < 50) {
				cacheObj.defult = [0, 0.5, 1, 3, 2, 1];
				cacheObj[FighterActionState.DEFENCE_ING] = [1, 2, 4, 5, 7, 10];
			}
			else {
				cacheObj.defult = [0, 0.5, 1, 0, 0, 0];
				cacheObj[FighterActionState.DEFENCE_ING] = [1, 2, 3, 4, 3, 2];
			}
			
			catch1 = getAIByFighterState(cacheObj) && targetCanBeHit();
			catch2 = getAIByFighterState(cacheObj) && targetCanBeHit();
			if (catch1) {
				addContOrder("catch1", 150);
			}
			if (catch2) {
				addContOrder("catch2", 110);
			}
		}
		
		private function updateSpecialSkill():void {
			specialSkill = false;
			
			if (_fighter.actionState != FighterActionState.HURT_ING) {
				return;
			}
			if (_fighter.hp > _fighter.hpMax * 0.75) {
				return;
			}
			if (_fighter.qi < 120) {
				return;
			}
			if (_fighter.data.comicType == 0) {
				var dis:Point = getTargetDistance(_target);
				if (dis.x > 80 || dis.y > 80) {
					return;
				}
			}
			
			var breakObj:Object = {};
			breakObj.defult = [0, 0, 0, 0, 0, 0];
			breakObj[FighterActionState.ATTACK_ING] = [0, 0, 0, 0.5, 1, 2];
			breakObj[FighterActionState.SKILL_ING] = [0, 0, 0, 0, 0.5, 1];
			
			specialSkill = getAIByFighterState(breakObj);
		}
		
		private function updateAssist():void {
			assist = false;
			
			var callObj:Object = {};
			callObj.defult = [0, 0, 0, 0, 0, 0];
			
			const RATE:Array = [0, 0, 0, 0.5, 1, 2];
			callObj[FighterActionState.BISHA_ING] = RATE;
			callObj[FighterActionState.BISHA_SUPER_ING] = RATE;
			callObj[FighterActionState.JUMP_ING] = RATE;
			callObj[FighterActionState.DASH_ING] = RATE;
			assist = getAIByFighterState(callObj);
		}
		
		private function updateGhostStep():void {
			ghostStep = false;
			ghostJump = false;
			ghostJumpDowm = false;
			
			if (_ghostFrame > 0) {
				_ghostFrame--;
				return;
			}
			
			var dis:Point = getTargetDistance(_target);
			if (dis.x > 80 || dis.y > 40) {
				return;
			}
			if (_fighter.qi < 80) {
				return;
			}
			
			var ghostStepObj:Object = {};
			ghostStepObj.defult = [0, 0, 0, 0, 0, 0];
			// 处在后摇状态
			if (_fighter.actionState == FighterActionState.FREEZE) {
				ghostStepObj[FighterActionState.ATTACK_ING] = [0, 0, 0, 0.5, 1, 2];
				ghostStepObj[FighterActionState.SKILL_ING] = [0, 0, 0.5, 1, 3, 5];
				ghostStepObj[FighterActionState.BISHA_ING] = [0, 0, 1, 2, 4, 8];
				ghostStep = getAIByFighterState(ghostStepObj);
				
				// 防止电脑连续幽步
				if (ghostStep) {
					_ghostFrame = 300;
				}
			}
		}
	}
}
