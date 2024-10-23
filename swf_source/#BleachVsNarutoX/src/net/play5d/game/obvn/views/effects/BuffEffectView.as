/**
 * 已重建完成
 */
package net.play5d.game.obvn.views.effects {
	import flash.geom.ColorTransform;
	
	import net.play5d.game.obvn.data.EffectVO;
	import net.play5d.game.obvn.fighter.FighterMain;
	import net.play5d.game.obvn.fighter.vos.FighterBuffVO;
	import net.play5d.game.obvn.interfaces.IGameSprite;
	
	/**
	 * BUFF 特效元件
	 */
	public class BuffEffectView extends EffectView {
		
		private var _fighter:FighterMain;				// 目标FighterMain
		private var _buff:FighterBuffVO;				// 效果 BUFF
		
		public function BuffEffectView(data:EffectVO) {
			super(data);
			loopPlay = true;
		}
		
		public function setBuff(v:FighterBuffVO):void {
			_buff = v;
		}
		
//		private function hasColorData():Boolean {
//			return _fighter && _data.targetColorOffset;
//		}
		
		override public function setTarget(v:IGameSprite):void {
			super.setTarget(v);
			
			if (v is FighterMain) {
				_fighter = v as FighterMain;
			}
			
			// 已有光圈，变色就多余了
//			if (hasColorData()) {
//				var ct:ColorTransform = new ColorTransform();
//				
//				ct.redOffset   = _data.targetColorOffset[0];
//				ct.greenOffset = _data.targetColorOffset[1];
//				ct.blueOffset  = _data.targetColorOffset[2];
//				
//				_fighter.changeColor(ct);
//			}
		}
		
		override public function render():void {
			super.render();
			
			// Buff 效果结束或者角色死亡，移除效果
			if (_buff.finished || !(_fighter && _fighter.isAlive)) {
//				// 恢复颜色
//				if (hasColorData()) {
//					_fighter.resumeColor();
//				}
				
				remove();
				
				return;
			}
			
			setPos(_fighter.x, _fighter.y);
		}
	}
}
