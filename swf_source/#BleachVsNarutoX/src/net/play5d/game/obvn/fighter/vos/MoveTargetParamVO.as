/**
 * 已重建完成
 */
package net.play5d.game.obvn.fighter.vos {
	import flash.geom.Point;
	
	import net.play5d.game.obvn.GameConfig;
	import net.play5d.game.obvn.fighter.FighterActionState;
	import net.play5d.game.obvn.fighter.FighterMain;
	import net.play5d.game.obvn.interfaces.BaseGameSprite;
	import net.play5d.game.obvn.interfaces.IGameSprite;
	
	/**
	 * 移动参数值对象
	 */
	public class MoveTargetParamVO {
		
		public var x:Number;
		public var y:Number;
		public var followMcName:String;
		
		public var target:IGameSprite;
		public var speed:Point;
		
		public function MoveTargetParamVO(params:Object = null) {
			if (!params) {
				return;
			}
			
			x = params.x != undefined ? params.x : 0;
			y = params.y != undefined ? params.y : 0;
			followMcName = params.followmc != undefined ? params.followmc : null;
			
			if (params.speed) {
				speed = new Point();
				if (params.speed is Number) {
					speed.x = speed.y = params.speed * GameConfig.SPEED_PLUS;
				}
				else {
					speed.x = params.speed.x != undefined ? params.speed.x * GameConfig.SPEED_PLUS : 0;
					speed.y = params.speed.y != undefined ? params.speed.y * GameConfig.SPEED_PLUS : 0;
				}
			}
		}
		
		public function setTarget(v:IGameSprite):void {
			target = v;
		}
		
		public function clear():void {
			if (!target) {
				return;
			}
			
			if (target is BaseGameSprite) {
				(target as BaseGameSprite).isApplyG = true;
			}
			if (target is FighterMain && 
				(target as FighterMain).actionState == FighterActionState.HURT_FLYING) 
			{
				(target as FighterMain).getCtrler().moveOnce(0, -5);
			}
		}
	}
}
