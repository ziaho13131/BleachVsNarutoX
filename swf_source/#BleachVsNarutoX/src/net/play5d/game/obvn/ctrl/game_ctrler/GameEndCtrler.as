/**
 * 已重建完成
 */
package net.play5d.game.obvn.ctrl.game_ctrler {
	import net.play5d.game.obvn.GameConfig;
	import net.play5d.game.obvn.ctrl.StateCtrl;
	import net.play5d.game.obvn.data.GameMode;
	import net.play5d.game.obvn.data.GameRunDataVO;
	import net.play5d.game.obvn.fighter.FighterActionState;
	import net.play5d.game.obvn.fighter.FighterMain;
	import net.play5d.game.obvn.ui.GameUI;
	
	/**
	 * 游戏结束控制器
	 */
	public class GameEndCtrler {
	
		private var _winner:FighterMain;				// 胜利者
		private var _loser:FighterMain;					// 失败者
		
		private var _step:int;
		private var _holdFrame:int;
		
		private var _isRender:Boolean;
		
		private var _drawGame:Boolean;					// 是否平局
		
		public function initlize(winner:FighterMain, loser:FighterMain):void {
			GameCtrler.I.gameRunData.setAllowLoseHP(false);
			
			_winner = winner;
			_loser = loser;
			
			_step = 0;
			_isRender = true;
		}
		
		public function drawGame():void {
			GameCtrler.I.gameRunData.setAllowLoseHP(false);
			
			_drawGame = true;
			
			_step = 0;
			_isRender = true;
		}
		
		public function destory():void {
			_winner = null;
			_loser = null;
		}
		
		public function render():Boolean {
			if (!_isRender) {
				return false;
			}
			if (_holdFrame-- > 0) {
				return false;
			}
			if (_drawGame) {
				return renderDrawGame();
			}
			
			return renderEND();
		}
		
		private function renderDrawGame():Boolean {
			switch (_step) {
				case 0:
					GameUI.I.getUI().showEnd(function ():void {
						_holdFrame = 0;
					}, {
						drawGame: true
					});
					
					_step = 1;
					_holdFrame = 10 * GameConfig.FPS_GAME;
					break;
				case 1:
					_isRender = false;
					GameUI.I.getUI().clearStartAndEnd();
					return true;
			}
			
			return false;
		}
		
		private function renderEND():Boolean {
			switch (_step) {
				case 0:
					GameUI.I.getUI().showEnd(function ():void {
						_holdFrame = 0;
					}, {
						winner: _winner,
						loser : _loser
					});
					_step = 1;
					_holdFrame = 10 * GameConfig.FPS_GAME;
					break;
				case 1:
					if (!FighterActionState.isAllowWinState(_winner.actionState)) {
						return false;
					}
					_winner.win();
					_holdFrame = 3 * GameConfig.FPS_GAME;
					_step = 2;
					
					var rundata:GameRunDataVO = GameCtrler.I.gameRunData;
					var winner:FighterMain = rundata.lastWinner;
					if (GameMode.isTeamMode()) {
						var timeRate:Number = 
							rundata.gameTime == -1 
							? 1 
							: rundata.gameTime / rundata.gameTimeMax;
						var addPercent:Number = 0.165 * (timeRate + 1);
						addPercent = Number(addPercent.toFixed(2));
						
						// 增加已损失的百分比血量，最低 16.5%，最高 33%
						winner.getCtrler().addHpLosePercent(addPercent);
					}
					
					rundata.lastWinnerHp = winner.hp;
					break;
				case 2:
					_step = 22;
					
					_winner = null;
					_loser = null;
					
					StateCtrl.I.transIn(function ():void {
						_step = 3;
					}, false);
					
					break;
				case 3:
					_isRender = false;
					GameUI.I.getUI().clearStartAndEnd();
					GameUI.I.getUI().fadOut(false);
					
					return true;
			}
			return false;
		}
		
		public function skip():void {
			if (_step == 2) {
				_holdFrame = 0;
			}
		}
	}
}
