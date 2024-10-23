/**
 * 已重建完成
 */
package net.play5d.game.obvn.fighter {
	
	/**
	 * 人物动作状态
	 */
	public class FighterActionState {
		
		public static const NORMAL         :int = 0;
		public static const FREEZE         :int = 40;
		
		public static const ATTACK_ING     :int = 10;
		public static const SKILL_ING      :int = 11;
		
		public static const BISHA_ING      :int = 12;
		public static const BISHA_SUPER_ING:int = 13;
		
		public static const JUMP_ING       :int = 14;
		public static const DASH_ING       :int = 15;
		public static const HURT_ACT_ING   :int = 16;
		public static const DEFENCE_ING    :int = 20;
		
		public static const HURT_ING       :int = 21;
		public static const HURT_FLYING    :int = 22;
		public static const HURT_DOWN      :int = 23;
		public static const HURT_DOWN_TAN  :int = 24;
		
		public static const DEAD           :int = 30;
		public static const WAN_KAI_ING    :int = 50;
		public static const KAI_CHANG      :int = 60;
		
		public static const WIN            :int = 61;
		public static const LOSE           :int = 62;
		
		
		public static function isAllowWinState(v:int):Boolean {
//			return v != BISHA_ING && v != BISHA_SUPER_ING && v != WAN_KAI_ING;
			return allowGhostStep(v);
		}
		
		public static function isBishaIng(v:int):Boolean {
			return [BISHA_ING, BISHA_SUPER_ING].indexOf(v) != -1;
		}
		
		public static function isAttacking(v:int):Boolean {
			return [ATTACK_ING, SKILL_ING, BISHA_ING, BISHA_SUPER_ING].indexOf(v) != -1;
		}
		
		public static function allowGhostStep(v:int):Boolean {
			return v != BISHA_ING && v != BISHA_SUPER_ING && v != WAN_KAI_ING;
		}
		
		/**
		 * 是否处于受伤状态
		 */
		public static function isHurting(v:int):Boolean {
			return [HURT_ING, HURT_FLYING, HURT_DOWN, HURT_DOWN_TAN].indexOf(v) != -1;
		}
		
		/**
		 * 是否处于击飞状态
		 */
		public static function isHurtFlying(v:int):Boolean {
			return [HURT_FLYING, HURT_DOWN, HURT_DOWN_TAN].indexOf(v) != -1;
		}
	}
}
