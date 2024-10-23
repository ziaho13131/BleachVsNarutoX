/**
 * 已重建完成
 */
package net.play5d.game.obvn.ui.fight {
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.media.SoundTransform;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import net.play5d.game.obvn.GameConfig;
	import net.play5d.game.obvn.ctrl.EffectCtrl;
	import net.play5d.game.obvn.ctrl.SoundCtrl;
	import net.play5d.game.obvn.ctrl.game_ctrler.GameCtrler;
	import net.play5d.game.obvn.data.GameData;
	import net.play5d.game.obvn.data.GameMode;
	import net.play5d.game.obvn.data.GameRunFighterGroup;
	import net.play5d.game.obvn.event.GameEvent;
	import net.play5d.game.obvn.fighter.FighterActionState;
	import net.play5d.game.obvn.fighter.FighterMain;
	import net.play5d.game.obvn.interfaces.IGameSprite;
	import net.play5d.game.obvn.interfaces.IGameUI;
	import net.play5d.game.obvn.ui.PauseDialog;
	import net.play5d.game.obvn.utils.MCUtils;
	import net.play5d.game.obvn.utils.ResUtils;
	
	/**
	 * 战斗UI
	 */
	public class FightUI implements IGameUI {
		
		public static var QI_BAR_MODE:int;
		
		public var ui:MovieClip;
		private var _fightbar:FightBar;
		private var _qibar1:QiBar;
		private var _qibar2:QiBar;
		private var _hits1:HitsUI;
		private var _hits2:HitsUI;
		
		private var _endParam:Object;
		private var _renderEnd:Boolean;
		private var _playOver:Boolean;
		private var _showWinnerDelay:int;
		private var _drawGame:Boolean;
		private var _isSlowDown:Boolean;
		private var _pauseDialog:PauseDialog;
		private var _flyTimer:Number = 0;
		
		private var _p1PosUI:MovieClip;
		private var _p2PosUI:MovieClip;
		
		public function FightUI() {
			ui = ResUtils.I.createDisplayObject(ResUtils.I.fight, "ui_fight");
			
			_fightbar = new FightBar(ui.hpbarmc);
			_qibar1 = new QiBar(ui.fzqi1);
			_qibar2 = new QiBar(ui.fzqi2);
			_hits1 = new HitsUI(ui.hits1);
			_hits2 = new HitsUI(ui.hits2);
			_qibar2.setDirect(-1);
			
			_p1PosUI = ResUtils.I.createDisplayObject(ResUtils.I.fight, "player_pos_p1");
			_p2PosUI = ResUtils.I.createDisplayObject(ResUtils.I.fight, "player_pos_p2");
			_p1PosUI.visible = false;
			_p2PosUI.visible = false;
			
			ui.addChild(_p1PosUI);
			ui.addChild(_p2PosUI);
			
			if (GameMode.isAcrade()) {
				trace("FightUI.initlize");
				_fightbar.initScore();
				
				GameEvent.addEventListener(GameEvent.SCORE_UPDATE, updateScore);
			}
		}
		
		public function initlize(p1:GameRunFighterGroup, p2:GameRunFighterGroup):void {
			_fightbar.setFighter(p1, p2);
			_qibar1.setFighter(p1.currentFighter, p1.fuzhu);
			_qibar2.setFighter(p2.currentFighter, p2.fuzhu);
			
			updateScore(null);
		}
		
		public function setVolume(v:Number):void {
			var st:SoundTransform = ui.soundTransform;
			st.volume = v;
			
			ui.soundTransform = st;
		}
		
		public function showWins(fighter:FighterMain, wins:int):void {
			_fightbar.showWin(fighter, wins);
		}
		
		private function updateScore(e:GameEvent):void {
			_fightbar.setScore(GameData.I.score);
		}
		
		public function destory():void {
			GameEvent.removeEventListener(GameEvent.SCORE_UPDATE, updateScore);
			
			if (_pauseDialog) {
				_pauseDialog.destory();
				_pauseDialog = null;
			}
			if (_fightbar) {
				_fightbar.destory();
				_fightbar = null;
			}
			if (_qibar1) {
				_qibar1.destory();
				_qibar1 = null;
			}
			if (_qibar2) {
				_qibar2.destory();
				_qibar2 = null;
			}
			if (_hits1) {
				_hits1.destory();
				_hits1 = null;
			}
			if (_hits2) {
				_hits2.destory();
				_hits2 = null;
			}
			if (ui) {
				try {
					MCUtils.stopAllMovieClips(ui);
					ui.removeChildren();
				}
				catch (e:Error) {
					trace(e);
				}
				
				ui = null;
			}
		}
		
		public function getUI():DisplayObject {
			return ui;
		}
		
		public function render():void {
			_fightbar.render();
			_qibar1.render();
			_qibar2.render();
			
			var zoom:Number = GameCtrler.I.gameState.camera.getZoom();
			renderPlayerPosUI(zoom);
			if (_renderEnd) {
				renderEnd();
			}
		}
		
//		private function renderQibarPos(zoom:Number):void {
//			if (QI_BAR_MODE != 0) {
//				return;
//			}
//			if (zoom < 1.5) {
//				_qibar1.moveTo(120, 60, 0.8);
//				_qibar2.moveTo(675, 60, 0.8);
//			}
//			else {
//				_qibar1.moveResume();
//				_qibar2.moveResume();
//			}
//		}
		
		public function renderAnimate():void {
			_fightbar.renderAnimate();
			_qibar1.renderAnimate();
			_qibar2.renderAnimate();
			renderStartAndKO();
		}
		
		private function renderStartAndKO():void {
			var stkomc:MovieClip = ui.startKOmc;
			if (!stkomc) {
				return;
			}
			var curLabel:String = stkomc.currentFrameLabel;
			if (curLabel) {
				if (curLabel == "stop") {
					return;
				}
				if (curLabel.indexOf("go:") != -1) {
					stkomc.gotoAndStop(curLabel.split("go:")[1]);
					return;
				}
			}
			
			stkomc.nextFrame();
		}
		
		public function fadIn(animate:Boolean = true):void {
			_fightbar.fadIn(animate);
			
			if (QI_BAR_MODE == FightQiBarMode.TOP) {
				_qibar1.fadIn(false);
				_qibar2.fadIn(false);
				_qibar1.setPosAndScale(120, 60, 0.8);
				_qibar2.setPosAndScale(675, 60, 0.8);
			}
			else {
				_qibar1.fadIn(animate);
				_qibar2.fadIn(animate);
			}
		}
		
		public function fadOut(animate:Boolean = true):void {
			_fightbar.fadOut(animate);
			_qibar1.fadOut(animate);
			_qibar2.fadOut(animate);
		}
		
		public function showHits(hits:int, id:int):void {
			var hitsui:HitsUI = id == 1 ? _hits1 : _hits2;
			hitsui.show(hits);
		}
		
		public function hideHits(id:int):void {
			var hitsui:HitsUI = id == 1 ? _hits1 : _hits2;
			hitsui.hide();
		}
		
		public function showStart(finishBack:Function = null, params:Object = null):void {
			fadIn();
			
			var round:int = GameCtrler.I.gameRunData.round;
			
			ui.startKOmc.y = -50;
			ui.startKOmc.$round = round;
			ui.startKOmc.gotoAndStop(round < 5 ? "start" : "start_final");
			
			ui.startKOmc.addEventListener("fight", onFight);
			if (finishBack != null) {
				ui.startKOmc.addEventListener(Event.COMPLETE, startComplete);
			}
			
			function onFight(e:Event):void {
				ui.startKOmc.removeEventListener("fight", onFight);
			}
			function startComplete(e:Event):void {
				ui.startKOmc.removeEventListener(Event.COMPLETE, startComplete);
				
				if (finishBack != null) {
					finishBack();
				}
			}
		}
		
		public function showEnd(finishBack:Function = null, params:Object = null):void {
			_endParam = params;
			if (!_endParam) {
				_endParam = {};
			}
			
			_endParam.finishBack = finishBack;
			_drawGame = params ? params.drawGame : false;
			
			_renderEnd = true;
			_playOver = false;
			
			if (GameCtrler.I.gameRunData.isTimerOver) {
				playTimeOver();
			}
			else {
				var loser:FighterMain = params ? params.loser : null;
				playKO(loser);
			}
		}
		
		private function playKO(loser:FighterMain = null):void {
			_showWinnerDelay = 0;
			EffectCtrl.I.freezeEnabled = false;
			_isSlowDown = false;
			
			if (loser) {
				EffectCtrl.I.doEffectById("hit_end", loser.x, loser.y);
				EffectCtrl.I.shine(0xFFFFFF, 0.5);
				
				GameCtrler.I.gameState.cameraFocusOne(loser.getDisplay());
			}
			
			GameCtrler.I.pause();
			
			var bsKO:Boolean = false;
			var p1:FighterMain = GameCtrler.I.gameRunData.p1FighterGroup.currentFighter;
			var p2:FighterMain = GameCtrler.I.gameRunData.p2FighterGroup.currentFighter;
			if (p1 && p2) {
				if (FighterActionState.isBishaIng(p1.actionState) || 
					FighterActionState.isBishaIng(p2.actionState)) 
				{
					bsKO = true;
					EffectCtrl.I.BGEffect("kobg", 2);
				}
			}
			
			EffectCtrl.I.shake(5, 0, 1.5);
			SoundCtrl.I.playSwcSound(snd_over_hit);
			
			setTimeout(playKO2, 500);
			function playKO2():void {
				ui.startKOmc.y = 0;
				ui.startKOmc.gotoAndStop("ko");
				ui.startKOmc.addEventListener(Event.COMPLETE, koBack);
				
				SoundCtrl.I.playSwcSound(bsKO ? snd_ko_bs : snd_ko);
				
				_qibar1.fadOut();
				_qibar2.fadOut();
			}
		}
		
		private function koBack(e:Event):void {
			EffectCtrl.I.freezeEnabled = true;
			ui.startKOmc.removeEventListener(Event.COMPLETE, koBack);
			_playOver = true;
			GameCtrler.I.resume();
			EffectCtrl.I.freezeEnabled = true;
		}
		
		private function playTimeOver():void {
			ui.startKOmc.y = 0;
			ui.startKOmc.gotoAndStop("timeover");
			ui.startKOmc.addEventListener(Event.COMPLETE, timeoverBack);
			
			_qibar1.fadOut();
			_qibar2.fadOut();
		}
		
		private function timeoverBack(e:Event):void {
			EffectCtrl.I.freezeEnabled = true;
			
			ui.startKOmc.removeEventListener(Event.COMPLETE, timeoverBack);
			if (_drawGame) {
				playDrawGame();
				_showWinnerDelay = 0;
				
				return;
			}
			_playOver = true;
			_showWinnerDelay = 1 * GameConfig.FPS_GAME;
		}
		
		private function playDrawGame():void {
			ui.startKOmc.gotoAndStop("drawgame");
			ui.startKOmc.addEventListener(Event.COMPLETE, drawGameBack);
		}
		
		private function drawGameBack(e:Event):void {
			ui.startKOmc.removeEventListener(Event.COMPLETE, drawGameBack);
			if (_endParam.finishBack != null) {
				_endParam.finishBack();
			}
		}
		
		private function renderEnd():void {
			if (!_playOver) {
				return;
			}
			if (!_endParam) {
				return;
			}
			
			if (_showWinnerDelay > 0) {
				_showWinnerDelay--;
				
				if (_showWinnerDelay <= 0) {
					var winner:FighterMain = _endParam.winner;
					
					if (winner) {
						GameCtrler.I.gameState.cameraFocusOne(winner.getDisplay());
						
						showWinner(winner);
						
						if (GameMode.isSingleMode()) {
							showWins(winner, GameCtrler.I.gameRunData.getWins(winner));
						}
						
						if (_endParam) {
							_endParam.finishBack();
						}
					}
					
					_renderEnd = false;
					_endParam = null;
				}
				
				return;
			}
			
			var loser:FighterMain = _endParam.loser;
			if (loser) {
				if (loser.actionState == FighterActionState.HURT_FLYING) {
					if (!_isSlowDown) {
						_isSlowDown = true;
						
						EffectCtrl.I.slowDown(2, 0);
						_flyTimer = getTimer();
					}
				}
				
				if (loser.actionState == FighterActionState.DEAD) {
					if (_isSlowDown) {
						
						if (getTimer() - _flyTimer < 2000) {
							_showWinnerDelay = 2 * GameConfig.FPS_GAME;
						}
						else {
							_showWinnerDelay = 1 * GameConfig.FPS_GAME;
						}
						EffectCtrl.I.slowDownResume();
					}
					else {
						_showWinnerDelay = 2 * GameConfig.FPS_GAME;
						EffectCtrl.I.slowDownResume();
					}
				}
			}
		}
		
		public function clearStartAndEnd():void {
			ui.startKOmc.gotoAndStop(1);
		}
		
		public function pause():void {
			if (!_pauseDialog) {
				_pauseDialog = new PauseDialog();
				ui.addChild(_pauseDialog);
			}
			
			_pauseDialog.show();
		}
		
		public function resume():void {
			if (!_pauseDialog) {
				return;
			}
			
			_pauseDialog.hide();
		}
		
		private function showWinner(winner:FighterMain, back:Function = null):void {
			ui.startKOmc.y = 30;
			
			var teamid:int = int(winner && winner.team ? winner.team.id : 1);
			switch (teamid) {
				case 1:
					ui.startKOmc.$winnerX = 30;
					break;
				case 2:
					ui.startKOmc.$winnerX = 546;
			}
			
			ui.startKOmc.$perfect = winner.hp >= winner.hpMax;
			ui.startKOmc.gotoAndStop("winner");
			if (back != null) {
				ui.startKOmc.addEventListener(Event.COMPLETE, winnerBack);
			}
			
			function winnerBack(e:Event):void {
				ui.startKOmc.removeEventListener(Event.COMPLETE, winnerBack);
				if (back != null) {
					back();
				}
			}
		}
		
		private function renderPlayerPosUI(zoom:Number):void {
			if (zoom > 1.8) {
				_p2PosUI.visible = false;
				_p1PosUI.visible = false;
				return;
			}
			
			var pos:Point;
			var p1:FighterMain = GameCtrler.I.gameRunData.p1FighterGroup.currentFighter;
			var p2:FighterMain = GameCtrler.I.gameRunData.p2FighterGroup.currentFighter;
			if (p1) {
				pos = getPlayerPos(p1);
				
				_p1PosUI.x = pos.x;
				_p1PosUI.y = pos.y;
				_p1PosUI.visible = true;
			}
			if (p2) {
				pos = getPlayerPos(p2);
				
				_p2PosUI.x = pos.x;
				_p2PosUI.y = pos.y;
				_p2PosUI.visible = true;
			}
		}
		
		private static function getPlayerPos(sp:IGameSprite):Point {
			var pos:Point = GameCtrler.I.gameState.getGameSpriteGlobalPosition(sp, 0, -50);
			
			if (pos.x < 20) {
				pos.x = 20;
			}
			if (pos.x > GameConfig.GAME_SIZE.x - 20) {
				pos.x = GameConfig.GAME_SIZE.x - 20;
			}
			if (pos.y < 60) {
				pos.y = 60;
			}
			if (pos.y > GameConfig.GAME_SIZE.y - 5) {
				pos.x = GameConfig.GAME_SIZE.x - 5;
			}
			
			return pos;
		}
	}
}
