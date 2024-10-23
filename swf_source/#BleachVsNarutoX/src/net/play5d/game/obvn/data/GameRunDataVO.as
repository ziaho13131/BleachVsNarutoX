/**
 * 已重建完成
 */
package net.play5d.game.obvn.data {
	import net.play5d.game.obvn.fighter.FighterMain;
	import net.play5d.game.obvn.map.MapMain;
	
	/**
	 * 游戏运行数据值对象
	 */
	public class GameRunDataVO {
		
		
		public const p1FighterGroup:GameRunFighterGroup = new GameRunFighterGroup();
		public const p2FighterGroup:GameRunFighterGroup = new GameRunFighterGroup();
		
		public var map:MapMain;
		public var p1Wins:int = 0;
		public var p2Wins:int = 0;
		
		public var lastWinnerTeam:TeamVO;
		public var continueLoser:FighterMain;
		public var lastWinner:FighterMain;
		public var lastWinnerHp:int = 1000;
		public var lastLoserData:FighterVO;
		public var lastLoserQi:int = 0;
		
		public var round:int = 1;
		public var gameTime:int;
		public var gameTimeMax:int;
		public var isTimerOver:Boolean;
		public var isDrawGame:Boolean;
		
		public function getWins(f:FighterMain):int {
			switch (f.team.id) {
				case 1:
					return p1Wins;
				case 2:
					return p2Wins;
				default:
					return 0;
			}
		}
		
		public function reset():void {
			p1Wins = 0;
			p2Wins = 0;
			round = 1;
			lastWinnerTeam = null;
			lastWinner = null;
			lastLoserData = null;
			lastLoserQi = 0;
			isTimerOver = false;
			isDrawGame = false;
			lastWinnerHp = GameData.I.config.fighterHP;
			gameTimeMax = GameData.I.config.fightTime;
			gameTime = gameTimeMax;
			continueLoser = null;
		}
		
		public function clear():void {
			map = null;
			lastWinnerTeam = null;
			lastWinner = null;
			lastLoserData = null;
			continueLoser = null;
		}
		
		public function nextRound():void {
			round++;
			gameTime = gameTimeMax;
			isTimerOver = false;
		}
		
		public function setAllowLoseHP(v:Boolean):void {
			if (p1FighterGroup) {
				p1FighterGroup.currentFighter.isAllowLoseHP = v;
			}
			if (p2FighterGroup) {
				p2FighterGroup.currentFighter.isAllowLoseHP = v;
			}
		}
	}
}
