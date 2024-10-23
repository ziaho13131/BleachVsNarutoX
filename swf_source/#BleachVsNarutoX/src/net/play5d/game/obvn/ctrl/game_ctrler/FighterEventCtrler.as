/**
 * 已重建完成
 */
package net.play5d.game.obvn.ctrl.game_ctrler {
	import net.play5d.game.obvn.ctrl.EffectCtrl;
	import net.play5d.game.obvn.ctrl.GameLogic;
	import net.play5d.game.obvn.data.GameMode;
	import net.play5d.game.obvn.data.GameRunFighterGroup;
	import net.play5d.game.obvn.data.TeamVO;
	import net.play5d.game.obvn.fighter.Assister;
	import net.play5d.game.obvn.fighter.Bullet;
	import net.play5d.game.obvn.fighter.FighterAttacker;
	import net.play5d.game.obvn.fighter.FighterMain;
	import net.play5d.game.obvn.fighter.events.FighterEvent;
	import net.play5d.game.obvn.fighter.events.FighterEventDispatcher;
	import net.play5d.game.obvn.interfaces.BaseGameSprite;
	import net.play5d.game.obvn.interfaces.IGameSprite;
	import net.play5d.game.obvn.utils.MCUtils;
	
	/**
	 * 角色事件控制
	 */
	public class FighterEventCtrler {
		
		private var _attackers:Array = [];					// 攻击对象集合
		
		/**
		 * 初始化
		 */
		public function initlize():void {
			FighterEventDispatcher.removeAllListeners();
			FighterEventDispatcher.addEventListener(FighterEvent.FIRE_BULLET, fireBullet);
			FighterEventDispatcher.addEventListener(FighterEvent.ADD_ATTACKER, addAttacker);
			FighterEventDispatcher.addEventListener(FighterEvent.ADD_ASSISTER, addAssister);
			FighterEventDispatcher.addEventListener(FighterEvent.HIT_TARGET, onHitTarget);
			FighterEventDispatcher.addEventListener(FighterEvent.HURT_RESUME, onHurtResume);
			FighterEventDispatcher.addEventListener(FighterEvent.HURT_DOWN, onHurtDown);
			FighterEventDispatcher.addEventListener(FighterEvent.DIE, onDie);
		}
		
		public static function destory():void {
			FighterEventDispatcher.removeAllListeners();
		}
		
		/**
		 * 发射飞行道具
		 */
		private static function fireBullet(event:FighterEvent):void {
			var params:Object = event.params;
			if (!params || !params.mc) {
				return;
			}
			
			var bullet:Bullet = new Bullet(params.mc, params);
			bullet.onRemove = removeBullet;
			bullet.setHitVO(params.hitVO);
			
			// 修改飞行道具变色
			// 飞行道具有可能由主人物或辅助或独立道具发出
			var owner:BaseGameSprite = event.fighter;
			if (owner.team.id == 2) {
				var p1Group:GameRunFighterGroup = GameCtrler.I.gameRunData.p1FighterGroup;
				var p2Group:GameRunFighterGroup = GameCtrler.I.gameRunData.p2FighterGroup;
				
				var p1Id:String = null;
				var p2Id:String = null;
				
				if (owner is FighterMain) {
					p1Id = p1Group.currentFighter.data.id;
					p2Id = p2Group.currentFighter.data.id;
				}
				else if (owner is Assister) {
					p1Id = p1Group.fuzhu.data.id;
					p2Id = p2Group.fuzhu.data.id;
				}
				// 发射飞行道具的也可能是独立道具
				else if (owner is FighterAttacker) {
					var owner2:IGameSprite = (owner as FighterAttacker).getOwner();
					if (owner2 is FighterMain) {
						p1Id = p1Group.currentFighter.data.id;
						p2Id = p2Group.currentFighter.data.id;
					}
					else if (owner2 is Assister){
						p1Id = p1Group.fuzhu.data.id;
						p2Id = p2Group.fuzhu.data.id;
					}
				}
				
				if (p1Id && p2Id && p1Id == p2Id) {
					MCUtils.changeColor(bullet);
				}
			}
			
			GameCtrler.I.addGameSprite(event.fighter.team.id, bullet);
		}
		
		/**
		 * 移除飞行道具
		 */
		private static function removeBullet(bullet:Bullet):void {
			GameCtrler.I.removeGameSprite(bullet);
		}
		
		/**
		 * 增加独立道具
		 */
		private function addAttacker(event:FighterEvent):void {
			var params:Object = event.params;
			if (!params || !params.mc) {
				return;
			}
			
			var attacker:FighterAttacker = new FighterAttacker(params.mc, params);
			attacker.onRemove = removeAttacker;
			attacker.setOwner(event.fighter);
			attacker.init();
			
			// 修改独立道具变色
			// 独立道具有可能由主人物或辅助发出
			var owner:BaseGameSprite = event.fighter;
			if (owner.team.id == 2) {
				var p1Group:GameRunFighterGroup = GameCtrler.I.gameRunData.p1FighterGroup;
				var p2Group:GameRunFighterGroup = GameCtrler.I.gameRunData.p2FighterGroup;
				
				var p1Id:String = null;
				var p2Id:String = null;
				
				if (owner is FighterMain) {
					p1Id = p1Group.currentFighter.data.id;
					p2Id = p2Group.currentFighter.data.id;
				}
				else if (owner is Assister) {
					p1Id = p1Group.fuzhu.data.id;
					p2Id = p2Group.fuzhu.data.id;
				}
				
				if (p1Id && p2Id && p1Id == p2Id) {
					MCUtils.changeColor(attacker);
				}
			}
			
			_attackers.push(attacker);
			GameCtrler.I.addGameSprite(event.fighter.team.id, attacker);
		}
		
		/**
		 * 增加辅助
		 */
		private static function addAssister(event:FighterEvent):void {
			var fighter:FighterMain = event.fighter as FighterMain;
			var group:GameRunFighterGroup = 
				fighter.team.id == 1
				? GameCtrler.I.gameRunData.p1FighterGroup
				: GameCtrler.I.gameRunData.p2FighterGroup;
			var assistant:Assister = group.fuzhu;
			assistant.setOwner(fighter);
			assistant.direct = fighter.direct;
			assistant.x = fighter.x - 30 * assistant.direct;
			assistant.y = fighter.y;
			assistant.onRemove = removeAssister;
			
			// 辅助只有可能被主人物发出
			var p1Id:String = GameCtrler.I.gameRunData.p1FighterGroup.fuzhu.data.id;
			var p2Id:String = GameCtrler.I.gameRunData.p2FighterGroup.fuzhu.data.id;
			if (fighter.team.id == 2 && p1Id == p2Id) {
				MCUtils.changeColor(assistant);
			}
			
			GameCtrler.I.addGameSprite(event.fighter.team.id, assistant);
			EffectCtrl.I.assisterEffect(assistant);
			
			assistant.goFight();
		}
		
		/**
		 * 移除辅助
		 */
		private static function removeAssister(assister:Assister):void {
			GameCtrler.I.removeGameSprite(assister);
		}
		
		/**
		 * 移除独立道具
		 */
		private function removeAttacker(attacker:FighterAttacker):void {
			GameCtrler.I.removeGameSprite(attacker);
			
			var id:int = _attackers.indexOf(attacker);
			if (id != -1) {
				_attackers.splice(id, 1);
			}
		}
		
		/**
		 * 得到 FighterAttacker
		 * @param name 名称
		 * @param team 队伍 id
		 */
		public function getAttacker(name:String, team:int):FighterAttacker {
			for each(var i:FighterAttacker in _attackers) {
				if (i.name == name && i.team.id == team) {
					return i;
				}
			}
			return null;
		}
		
		private static function onHitTarget(e:FighterEvent):void {
			addHits(e.fighter as FighterMain, e.params.target);
			
			if (GameMode.isAcrade() && e.fighter.team.id == 1) {
				GameLogic.addScoreByHitTarget(e.params.hitvo);
			}
		}
		
		private static function onHurtResume(e:FighterEvent):void {
			removeHits(e.fighter.id);
		}
		
		private static function onHurtDown(e:FighterEvent):void {
			removeHits(e.fighter.id);
		}
		
		private static function addHits(fighter:FighterMain, target:IGameSprite):void {
			var targetId:String = null;
			if (target && target is BaseGameSprite) {
				targetId = (target as BaseGameSprite).id;
			}
			var uiId:int = fighter.team.id;
			var hits:int = GameLogic.addHits(fighter.id, targetId, uiId);
			if (hits > 1) {
				GameCtrler.I.gameState.gameUI.getUI().showHits(hits, uiId);
			}
		}
		
		private static function removeHits(targetId:String):void {
			var o:Object = GameLogic.getHitsObjByTargetId(targetId);
			if (o) {
				GameCtrler.I.gameState.gameUI.getUI().hideHits(o.uiID);
			}
			
			GameLogic.clearHitsByTargetId(targetId);
		}
		
		private static function onDie(e:FighterEvent):void {
			var winner:FighterMain = null;
			var loser:FighterMain = e.fighter as FighterMain;
			
			var team:TeamVO = GameCtrler.I.getEnemyTeam(e.fighter);
			if (team) {
				for each(var i:IGameSprite in team.children) {
					if (i is FighterMain) {
						winner = i as FighterMain;
						break;
					}
				}
			}
			
			GameCtrler.I.gameEnd(winner, loser);
		}
	}
}
