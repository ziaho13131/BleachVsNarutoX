/**
 * 已重建完成
 */
package net.play5d.game.obvn.views.effects {
	import flash.geom.ColorTransform;
	
	import net.play5d.game.obvn.data.EffectVO;
	import net.play5d.game.obvn.fighter.FighterActionState;
	import net.play5d.game.obvn.fighter.FighterMain;
	import net.play5d.game.obvn.interfaces.IGameSprite;
	
	/**
	 * 特殊效果（冰冻，火焰，雷电等）
	 */
	public class SpecialEffectView extends EffectView {
		
		private var _fighter:FighterMain;						// 目标 FighterMain
		private var _finished:Boolean;							// 是否结束
		
		public function SpecialEffectView(data:EffectVO) {
			super(data);
		}
		
		override public function setTarget(v:IGameSprite):void {
			super.setTarget(v);
			
			if (v is FighterMain) {
				_fighter = v as FighterMain;
				if (_data.targetColorOffset) {
					var ct:ColorTransform = new ColorTransform();
					ct.redOffset = _data.targetColorOffset[0];
					ct.greenOffset = _data.targetColorOffset[1];
					ct.blueOffset = _data.targetColorOffset[2];
					
					_fighter.changeColor(ct);
				}
			}
		}
		
		override public function start(x:Number = 0, y:Number = 0, direct:int = 1):void {
			super.start(x, y, direct);
			
			_finished = false;
		}
		
		override public function render():void {
			super.render();
			
			if (_finished) {
				return;
			}
			if (!_fighter) {
				return;
			}
			
			switch (_fighter.actionState) {
				case FighterActionState.HURT_DOWN:
				case FighterActionState.HURT_DOWN_TAN:
				case FighterActionState.NORMAL:
					gotoAndPlay("finish");
					_finished = true;
					
					if (_data.targetColorOffset) {
						_fighter.resumeColor();
					}
					
					break;
				default:
					setPos(_fighter.x, _fighter.y);
			}
		}
	}
}
