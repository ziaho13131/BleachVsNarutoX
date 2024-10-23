/**
 * 已重建完成
 */
package net.play5d.game.obvn.fighter.ctrler {
	import net.play5d.game.obvn.ctrl.game_ctrler.GameCtrler;
	import net.play5d.game.obvn.input.GameInputer;
	import net.play5d.game.obvn.interfaces.IFighterActionCtrl;
	
	/**
	 * 角色键盘控制
	 */
	public class FighterKeyCtrler implements IFighterActionCtrl {
		
		public var inputType:String;
		public var classicMode:Boolean = false;
		
		private var _justDown:int = 0;
		
		public function initlize():void {
			if (!classicMode) {
				_justDown = 2;
				GameInputer.listenKeys(inputType, ["attack", "jump", "dash", "skill", "superSkill"], 2);
				return;
			}
			
			_justDown = 0;
		}
		
		public function render():void {}
		
		public function renderAnimate():void {}
		
		public function destory():void {
			if (!classicMode) {
				GameInputer.unListenKeys(inputType, 2);
			}
		}
		
		public function enabled():Boolean {
			return GameCtrler.I.actionEnable;
		}
		
		public function moveLEFT():Boolean {
			return GameInputer.left(inputType, 0) && !GameInputer.right(inputType, 0);
		}
		
		public function moveRIGHT():Boolean {
			return GameInputer.right(inputType, 0) && !GameInputer.left(inputType, 0);
		}
		
		public function defense():Boolean {
			return GameInputer.down(inputType, 0);
		}
		
		public function attack():Boolean {
			return GameInputer.attack(inputType, _justDown) && 
				!(GameInputer.up(inputType, 0) || 
					GameInputer.down(inputType,0) || 
					GameInputer.jump(inputType, 0));
		}
		
		public function jump():Boolean {
			return GameInputer.jump(inputType, _justDown) && !GameInputer.attack(inputType, 0);
		}
		
		public function jumpQuick():Boolean {
			if (classicMode) {
				return false;
			}
			
			return GameInputer.jump(inputType, _justDown) && !GameInputer.attack(inputType, 0);
		}
		
		public function jumpDown():Boolean {
			return GameInputer.down(inputType, 0) && GameInputer.jump(inputType, _justDown);
		}
		
		public function dash():Boolean {
			return GameInputer.dash(inputType, _justDown) && !GameInputer.down(inputType, 0);
		}
		
		public function dashJump():Boolean {
			return GameInputer.dash(inputType, _justDown);
		}
		
		public function skill1():Boolean {
			return GameInputer.down(inputType, 0) && GameInputer.attack(inputType, _justDown);
		}
		
		public function skill2():Boolean {
			return GameInputer.up(inputType, 0) && GameInputer.attack(inputType, _justDown);
		}
		
		public function zhao1():Boolean {
			return GameInputer.skill(inputType, _justDown) && 
				!GameInputer.up(inputType, 0) && 
				!GameInputer.down(inputType, 0);
		}
		
		public function zhao2():Boolean {
			return GameInputer.down(inputType, 0) && GameInputer.skill(inputType, _justDown);
		}
		
		public function zhao3():Boolean {
			return GameInputer.up(inputType, 0) && GameInputer.skill(inputType, _justDown);
		}
		
		public function catch1():Boolean {
			return GameInputer.attack(inputType, 2) && 
				(GameInputer.left(inputType, 0) || 
					GameInputer.right(inputType, 0));
		}
		
		public function catch2():Boolean {
			return GameInputer.skill(inputType, 2) && 
				(GameInputer.left(inputType, 0) || 
					GameInputer.right(inputType, 0));
		}
		
		public function bisha():Boolean {
			return GameInputer.superSkill(inputType, _justDown) && 
				!(GameInputer.up(inputType, 0) || 
					GameInputer.down(inputType, 0));
		}
		
		public function bishaUP():Boolean {
			return GameInputer.superSkill(inputType, _justDown) && GameInputer.up(inputType, 0);
		}
		
		public function bishaSUPER():Boolean {
			return GameInputer.superSkill(inputType, _justDown) && GameInputer.down(inputType, 0);
		}
		
		public function assist():Boolean {
			return GameInputer.special(inputType, 0);
		}
		
		public function specailSkill():Boolean {
			return GameInputer.special(inputType, 0);
		}
		
		public function attackAIR():Boolean {
			return GameInputer.attack(inputType, _justDown);
		}
		
		public function skillAIR():Boolean {
			return GameInputer.skill(inputType, _justDown);
		}
		
		public function bishaAIR():Boolean {
			return GameInputer.superSkill(inputType, _justDown);
		}
		
		public function wanKai():Boolean {
			return GameInputer.wankai(inputType, 0) && 
				!(GameInputer.up(inputType, 0) || 
					GameInputer.down(inputType, 0));
		}
		
		public function wanKaiW():Boolean {
			return GameInputer.up(inputType, 0) && GameInputer.wankai(inputType, 0);
		}
		
		public function wanKaiS():Boolean {
			return GameInputer.down(inputType, 0) && GameInputer.wankai(inputType, 0);
		}
		
		public function ghostStep():Boolean {
			return GameInputer.dash(inputType, _justDown) && GameInputer.down(inputType, 0);
		}
		
		public function ghostJump():Boolean {
			return GameInputer.dash(inputType, _justDown) && GameInputer.up(inputType, 0);
		}
		
		public function ghostJumpDown():Boolean {
			return GameInputer.dash(inputType, _justDown) && GameInputer.down(inputType, 0);
		}
	}
}
