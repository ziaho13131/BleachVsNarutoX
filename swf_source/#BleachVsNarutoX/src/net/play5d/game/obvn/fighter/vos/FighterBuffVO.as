/**
 * 已重建完成
 */
package net.play5d.game.obvn.fighter.vos {
	import net.play5d.game.obvn.GameConfig;
	
	/**
	 * 角色BUFF值对象
	 */
	public class FighterBuffVO {
		
		
		public var param:String;
		public var resumeValue:Number = 0;
		public var finished:Boolean = false;
		
		private var _holdFrame:Number = 1;
		
		public function FighterBuffVO(param:String, hold:Number = 1) {
			this.param = param;
			this._holdFrame = hold * GameConfig.FPS_GAME;
			this.finished = false;
		}
		
		public function setHold(v:Number):void {
			_holdFrame = v * GameConfig.FPS_GAME;
			finished = false;
		}
		
		public function render():Boolean {
			if (finished) {
				return true;
			}
			
			if (--_holdFrame <= 0) {
				finished = true;
				return true;
			}
			
			return false;
		}
	}
}
