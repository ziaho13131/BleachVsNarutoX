/**
 * 已重建完成
 */
package net.play5d.game.obvn.fighter.models {
	import flash.geom.Rectangle;
	
	import net.play5d.game.obvn.data.HitType;
	import net.play5d.game.obvn.interfaces.IGameSprite;
	import net.play5d.kyo.utils.KyoUtils;
	
	/**
	 * 攻击值对象
	 */
	public class HitVO {
		
		public var id:String;
		
		public var owner:IGameSprite;
		public var power:Number = 0;
		public var powerRate:Number = 1;
		public var hitType:int = 1;
		public var isBreakDef:Boolean = false;
		public var hitx:Number = 0;
		public var hity:Number = 0;
		public var hurtTime:Number = 300;
		
		public var hurtType:int = 0;
		
		public var checkDirect:Boolean = true;
		public var currentArea:Rectangle;
		
		private var _cloneKey:Array = [
			"id", 
			"owner", "power", "powerRate", "hitType", "isBreakDef", "hitx", "hity", "hurtTime", 
			"hurtType", 
			"currentArea", "checkDirect"
		];
		
		public function HitVO(o:Object = null) {
			KyoUtils.setValueByObject(this, o);
			
			if (hitType == HitType.KAN) {
				if (hurtTime < 100) {
					hurtTime = 100;
				}
			}
		}
		
		public function clone():HitVO {
			var hv:HitVO = new HitVO();
			KyoUtils.cloneValue(hv, this, _cloneKey);
			
			return hv;
		}
		
		public function isBisha():Boolean {
			if (id == null) {
				return false;
			}
			
			return id.indexOf("bs") != -1 || 
				id.indexOf("sbs") != -1 || 
				id.indexOf("cbs") != -1 || 
				id.indexOf("kbs") != -1
			;
		}
		
		public function isCatch():Boolean {
			return hitType == HitType.CATCH && isBreakDef;
		}
		
		public function getDamage():int {
			return power * powerRate;
		}
	}
}
