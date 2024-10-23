/**
 * 已重建完成
 */
package net.play5d.game.obvn.views.effects {
	import flash.geom.ColorTransform;
	
	import net.play5d.game.obvn.ctrl.EffectCtrl;
	import net.play5d.game.obvn.data.EffectVO;
	import net.play5d.game.obvn.fighter.FighterMain;
	import net.play5d.game.obvn.interfaces.IGameSprite;
	
	/**
	 * 钢身特效
	 */
	public class SteelHitEffect extends EffectView {
		
		
		private var _fighter:FighterMain;							// 目标 FighterMain
		
		public function SteelHitEffect(data:EffectVO) {
			super(data);
		}
		
		/**
		 * 设置目标
		 */
		override public function setTarget(v:IGameSprite):void {
			super.setTarget(v);
			
			if (v is FighterMain) {
				_fighter = v as FighterMain;
				if (_fighter.isSteelBody) {
					var ct:ColorTransform = new ColorTransform();
					ct.redOffset = 150;
					ct.greenOffset = 150;
					ct.blueOffset = 150;
					
					if (_fighter.isSuperSteelBody) {
						ct.blueOffset = 0;
						EffectCtrl.I.shine(0xFFFF00, 0.3);
					}
					
					_fighter.changeColor(ct);
					EffectCtrl.I.setOnFreezeOver(function ():void {
						_fighter.resumeColor();
					});
				}
			}
		}
	}
}
