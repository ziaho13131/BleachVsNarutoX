/**
 * 已重建完成
 */
package net.play5d.game.obvn.ui.fight {
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	
	import net.play5d.game.obvn.GameConfig;
	import net.play5d.game.obvn.fighter.FighterActionState;
	import net.play5d.game.obvn.fighter.FighterMain;
	
	/**
	 * 角色血条类
	 */
	public class FighterHpBar {
		
		private var _ui:MovieClip;
		private var _bar:DisplayObject;
		private var _redbar:DisplayObject;
		private var _fighter:FighterMain;
		private var _hprate:Number = 1;
		
		private var _redBarMoving:Boolean;
		private var _redBarMoveDelay:int;
		private var _justHurtFly:Boolean;
		
		public function FighterHpBar(ui:MovieClip) {
			_ui = ui;
			_bar = _ui.bar;
			_redbar = _ui.redbar;
		}
		
		public function get ui():DisplayObject {
			return _ui;
		}
		
		public function destory():void {
			_fighter = null;
		}
		
		public function setFighter(v:FighterMain):void {
			_fighter = v;
		}
		
		public function render():void {
			var rate:Number = _fighter.hp / _fighter.hpMax;
			
			if (_redBarMoving && rate != _hprate) {
				_redbar.scaleX = _hprate;
				_redBarMoving = false;
			}
			
			_hprate = rate;
			
			////////////////////////////////////////////////////////////
			/*
			var diff   :Number = _hprate - _bar.scaleX;
			var addRate:Number = diff < 0 ? 0.4 : 0.04;
			
			if (Math.abs(diff) < 0.01) {
				_bar.scaleX = _hprate;
			}
			else {
				_bar.scaleX += diff * addRate;
			}
			*/
			
			_bar.scaleX = _hprate;
			
			////////////////////////////////////////////////////////////
			
			switch (_fighter.actionState) {
				// 红条不会立马开始减少
				case FighterActionState.HURT_ING:
				case FighterActionState.HURT_FLYING:
					_redBarMoveDelay = 100;
					
					break;
				// 红条开始减少
				case FighterActionState.HURT_DOWN:
				case FighterActionState.HURT_DOWN_TAN:
					if (_redBarMoveDelay > 0) {
						if (!_justHurtFly) {
							_redBarMoveDelay = 1.5 * GameConfig.FPS_GAME;
							_justHurtFly = true;
							
							break;
						}
						if (_redBarMoveDelay > 0) {
							_redBarMoveDelay--;
							
							break;
						}
						
						break;
					}
					
					break;
				default:
					_redBarMoveDelay = 0;
					_justHurtFly = false;
			}
			
			if (_redBarMoveDelay <= 0) {
				var diffRed   :Number = _hprate - _redbar.scaleX;
				var addRateRed:Number = diffRed < 0 ? 0.1 : 0.02;
				
				if (Math.abs(diffRed) < 0.01) {
					_redbar.scaleX = _hprate;
					_redBarMoving = false;
				}
				else {
					_redbar.scaleX += diffRed * addRateRed;
					_redBarMoving = true;
				}
			}
		}
	}
}
