/**
 * 已重建完成
 */
package net.play5d.game.obvn.data {
	import net.play5d.game.obvn.input.GameInputType;
	
	/**
	 * 游戏模式类
	 */
	public class GameMode {
		
		public static const TEAM_ACRADE:int = 10;				// 小队冒险
		public static const TEAM_VS_PEOPLE:int = 11;			// 小队与2p对战
		public static const TEAM_VS_CPU:int = 12;				// 小队与CPU对战
		public static const TEAM_WATCH:int = 13;				// 小队观战
		
		public static const SINGLE_ACRADE:int = 20;				// 单人冒险
		public static const SINGLE_VS_PEOPLE:int = 21;			// 单人与2p对战
		public static const SINGLE_VS_CPU:int = 22;				// 单人与CPU对战
		public static const SINGLE_WATCH:int = 23;				// 单人观战
		
//		public static const SURVIVOR:int = 30;
		
		public static const TRAINING:int = 40;					// 练习模式
		
		public static var currentMode:int;						// 当前模式
		
		/**
		 * 得到队伍
		 */
		public static function getTeams():Array {
			return [{
				id  : 1,
				name: GameInputType.P1
			}, {
				id  : 2,
				name: GameInputType.P2
			}];
		}
		
		public static function isTeamMode():Boolean {
			return currentMode == TEAM_ACRADE || 
				currentMode == TEAM_VS_PEOPLE || 
				currentMode == TEAM_VS_CPU || 
				currentMode == TEAM_WATCH;
		}
		
		public static function isSingleMode():Boolean {
			return currentMode == SINGLE_ACRADE || 
				currentMode == SINGLE_VS_PEOPLE || 
				currentMode == SINGLE_VS_CPU || 
				currentMode == SINGLE_WATCH;
		}
		
		public static function isVsPeople():Boolean {
			return currentMode == TEAM_VS_PEOPLE || 
				currentMode == SINGLE_VS_PEOPLE;
		}
		
		public static function isVsCPU(includeTraining:Boolean = true):Boolean {
			return currentMode == TEAM_VS_CPU || 
				currentMode == SINGLE_VS_CPU || 
				includeTraining && currentMode == TRAINING || 
				currentMode == TEAM_WATCH || 
				currentMode == SINGLE_WATCH;
		}
		
		public static function isWatch():Boolean {
			return currentMode == TEAM_WATCH || 
				currentMode == SINGLE_WATCH;
		}
		
		public static function isAcrade():Boolean {
			return currentMode == TEAM_ACRADE || currentMode == SINGLE_ACRADE/* || currentMode == SURVIVOR*/;
		}
	}
}
