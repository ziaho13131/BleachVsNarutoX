/**
 * 已重建完成
 */
package net.play5d.game.obvn.ctrl.game_ctrler {
	import net.play5d.game.obvn.GameConfig;
	import net.play5d.game.obvn.ctrl.StateCtrl;
	import net.play5d.game.obvn.data.GameRunFighterGroup;
	import net.play5d.game.obvn.fighter.Assister;
	import net.play5d.game.obvn.fighter.FighterActionState;
	import net.play5d.game.obvn.fighter.FighterMain;
	
	/**
	 * 练习模式控制器
	 */
	public class TrainingCtrler {
		
		public static var RECOVER_HP:Boolean = true;
		public static var RECOVER_QI:Boolean = true;
		public static var RECOVER_FZ_QI:Boolean = true;
		
		private var _trainAddDelay:Object;
		private var _fighters:Array;
		
		public function initlize(fighters:Array):void {
			_fighters = fighters;
			
			for each(var i:FighterMain in _fighters) {
				i.qi = i.qiMax;
			}
			
			_trainAddDelay = {};
			StateCtrl.I.transOut(null, true);
		}
		
		public function destory():void {
			_fighters = null;
			_trainAddDelay = null;
		}
		
		public function render():void {
			for each(var i:FighterMain in _fighters) {
				var hpid:String = i.id + "_hp";
				if (FighterActionState.isHurting(i.actionState)) {
					_trainAddDelay[hpid] = 1.5 * GameConfig.FPS_GAME;
				}
				else if (_trainAddDelay[hpid] != undefined && _trainAddDelay[hpid] > 0) {
					_trainAddDelay[hpid]--;
					if (_trainAddDelay[hpid] <= 0 && RECOVER_HP) {
						i.hp = i.hpMax;
					}
				}
				else if (i.hp == i.hpMax) {
					_trainAddDelay[hpid] = 0;
				}
				else {
					_trainAddDelay[hpid] = 2 * GameConfig.FPS_GAME;
				}
				
				var qiid:String = i.id + "_qi";
				if (_trainAddDelay[qiid] != undefined && _trainAddDelay[qiid] > 0) {
					_trainAddDelay[qiid]--;
					if (_trainAddDelay[qiid] <= 0 && RECOVER_QI) {
						i.qi = i.qiMax;
					}
				}
				else if (i.qi == i.qiMax) {
					_trainAddDelay[qiid] = 0;
				}
				else {
					_trainAddDelay[qiid] = 2 * GameConfig.FPS_GAME;
				}
				
				var fzid:String = i.id + "fz";
				if (_trainAddDelay[fzid] != undefined && _trainAddDelay[fzid] > 0) {
					_trainAddDelay[fzid]--;
					if (_trainAddDelay[fzid] <= 0 && RECOVER_FZ_QI) {
//						i.fzqi = i.fzqiMax;
						
						// 检测辅助如果还在场上，不恢复满气量
						var teamId:int = i.team.id;
						var group:GameRunFighterGroup = 
							GameCtrler.I.gameRunData["p" + teamId + "FighterGroup"] 
							as GameRunFighterGroup;
						var assistant:Assister = group.fuzhu;
						
						if (!assistant.isOnStage) {
							i.fzqi = i.fzqiMax;
						}
					}
				}
				else if (i.fzqi == i.fzqiMax) {
					_trainAddDelay[fzid] = 0;
				}
				else {
					_trainAddDelay[fzid] = 2 * GameConfig.FPS_GAME;
				}
			}
		}
	}
}
