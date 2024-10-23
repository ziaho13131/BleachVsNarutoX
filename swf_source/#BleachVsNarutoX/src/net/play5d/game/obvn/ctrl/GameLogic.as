/**
 * 已重建完成
 */
package net.play5d.game.obvn.ctrl {
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import net.play5d.game.obvn.GameConfig;
	import net.play5d.game.obvn.ctrl.game_ctrler.GameCtrler;
	import net.play5d.game.obvn.data.GameData;
	import net.play5d.game.obvn.data.GameMode;
	import net.play5d.game.obvn.data.MessionModel;
	import net.play5d.game.obvn.data.MessionStageVO;
	import net.play5d.game.obvn.data.SelectCharListConfigVO;
	import net.play5d.game.obvn.data.SelectCharListItemVO;
	import net.play5d.game.obvn.event.GameEvent;
	import net.play5d.game.obvn.fighter.FighterActionState;
	import net.play5d.game.obvn.fighter.FighterMain;
	import net.play5d.game.obvn.fighter.events.FighterEvent;
	import net.play5d.game.obvn.fighter.events.FighterEventDispatcher;
	import net.play5d.game.obvn.fighter.models.HitVO;
	import net.play5d.game.obvn.interfaces.BaseGameSprite;
	import net.play5d.game.obvn.interfaces.IGameSprite;
	import net.play5d.game.obvn.map.FloorVO;
	import net.play5d.game.obvn.map.MapMain;
	import net.play5d.game.obvn.stage.GameCamera;
	import net.play5d.game.obvn.ui.select.SelectIndexUI;
	import net.play5d.game.obvn.utils.ResUtils;
	
	/**
	 * 游戏逻辑
	 */
	public class GameLogic {
		
		private static var _map:MapMain;
		private static var _camera:GameCamera;
		private static var _floorContact:Dictionary = new Dictionary();
		
		private static var _hitsObj:Object = {};
		
		public static function initGameLogic(map:MapMain, camera:GameCamera):void {
			_map = map;
			_camera = camera;
		}
		
		public static function clear():void {
			_map = null;
			_camera = null;
		}
		
		public static function isInAir(target:BaseGameSprite):Boolean {
			if (!_map) {
				trace("error:map is null!");
				
				return false;
			}
			if (target.getVecY() < 0) {
				target.isTouchBottom = false;
				
				return true;
			}
			if (target.y > _map.playerBottom - 12) {
				target.y = _map.playerBottom;
				target.isTouchBottom = true;
				
				return false;
			}
			
			target.isTouchBottom = false;
			var allowHitAirFloor:Boolean = target.getVecY() < 5 * GameConfig.SPEED_PLUS;
			if (!allowHitAirFloor) {
				return true;
			}
			
			var floorSpd:Number = 10 * GameConfig.SPEED_PLUS_DEFAULT;
			var fv:FloorVO = _floorContact[target];
			if (fv) {
				if (fv.hitTest(target.x, target.y, floorSpd)) {
					target.y = fv.y;
					return false;
				}
				
				delete _floorContact[target];
				return true;
			}
			
			fv = _map.getFloorHitTest(target.x, target.y, floorSpd);
			if (fv) {
				target.y = fv.y;
				_floorContact[target] = fv;
				
				return false;
			}
			
			return true;
		}
		
		public static function isTouchBottomFloor(target:IGameSprite):Boolean {
			if (!_map) {
				trace("GameLogic.isTouchBottomFloor :: map is null!");
				
				return false;
			}
			return target.y > _map.playerBottom;
		}
		
		public static function isOutRange(target:IGameSprite):Boolean {
			if (!_map) {
				trace("GameLogic.isTouchBottomFloor :: map is null!");
				
				return false;
			}
			return target.x > _map.right + 20 || target.x < _map.left - 20 || target.y > _map.bottom + 20;
		}
		
		public static function addHits(id:Object, targetID:Object, uiID:int):int {
			if (_hitsObj[id] == undefined) {
				_hitsObj[id] = {
					hits    : 0,
					targetID: targetID,
					uiID    : uiID
				};
			}
			
			_hitsObj[id].targetID = targetID;
			_hitsObj[id].hits++;
			
			return _hitsObj[id].hits;
		}
		
//		public static function clearHits(id:Object):void {
//			_hitsObj[id].hits = 0;
//			_hitsObj[id].targetID = null;
//			_hitsObj[id].uiID = null;
//		}
		
		public static function getHitsObj(id:Object):Object {
			return _hitsObj[id];
		}
		
		public static function getHitsObjByTargetId(id:Object):Object {
			for each(var o:Object in _hitsObj) {
				if (o.targetID == id) {
					return o;
				}
			}
			
			return null;
		}
		
		public static function clearHitsByTargetId(id:Object):void {
			for (var i:String in _hitsObj) {
				if (_hitsObj[i].targetID == id) {
					delete _hitsObj[i];
				}
			}
		}
		
		public static function checkFighterDie(v:FighterMain):Boolean {
			if (GameMode.currentMode == GameMode.TRAINING) {
				return false;
			}
			
			return v.hp <= 0;
		}
		
		public static function hitTarget(hitvo:HitVO, attacker:IGameSprite, target:IGameSprite):void {
			if (!attacker || !target) {
				return;
			}
			if (!(attacker is FighterMain) || !(target is FighterMain)) {
				return;
			}
			if ((target as FighterMain).actionState != FighterActionState.HURT_ING && (target as FighterMain).actionState != FighterActionState.HURT_FLYING) {
				return;
			}
			
			var param:Object = {};
			param.target = target;
			param.hitvo = hitvo;
			
			FighterEventDispatcher.dispatchEvent(attacker as FighterMain, FighterEvent.HIT_TARGET, param);
		}
		
		public static function addScoreByHitTarget(hitvo:HitVO):void {
			var baseScore:int = hitvo.power;
			var score:int = baseScore;
			
			if (hitvo.isBisha()) {
				score = baseScore * 2;
			}
			if (hitvo.id == "sh1" || hitvo.id == "sh2") {
				score += 500;
			}
			if (hitvo.isBreakDef) {
				score += 200;
			}
			if (hitvo.hurtType == 1) {
				score += 200;
			}
			
			var hitsObj:Object = getHitsObj(1);
			var hits:int = hitsObj ? hitsObj.hits : 0;
			if (hits < 4) {
				score += hits * 50;
			}
			else {
				score += hits * 100;
			}
			
			addScore(score);
			GameEvent.dispatchEvent(GameEvent.SCORE_UPDATE);
		}
		
		public static function addScoreByKO():void {
			var curFighter:FighterMain = GameCtrler.I.gameRunData.p1FighterGroup.currentFighter;
			
			if (curFighter.lastHitVO && curFighter.lastHitVO.isBisha()) {
				addScore(2000);
			}
			if (curFighter.hp == curFighter.hpMax) {
				addScore(20000);
			}
			else {
				addScore(3000);
			}
			
			GameEvent.dispatchEvent(GameEvent.SCORE_UPDATE);
		}
		
		public static function addScoreByPassMission():void {
			if (GameMode.currentMode == GameMode.TEAM_ACRADE && 
				GameCtrler.I.gameRunData.p1FighterGroup.currentFighter == GameCtrler.I.gameRunData.p1FighterGroup.fighter1) 
			{
				addScore(15000);
			}
			else {
				addScore(5000);
			}
		}
		
		private static function addScore(v:int):void {
			var rate:Number = GameData.I.config.keyInputMode == 0 ? 1 : 0.8;
			
			GameData.I.score += v * rate;
		}
		
		public static function loseScoreByContinue():void {
			GameData.I.score -= 10000;
			
			if (GameData.I.score < 0) {
				GameData.I.score = 0;
			}
		}
		
		public static function fixGameSpritePosition(sp:IGameSprite):void {
			if (sp.isDestoryed()) {
				return;
			}
			
			if (!sp.allowCrossMapXY()) {
				var left:Number = _map.left + 10;
				var right:Number = _map.right - 10;
				
				var offsetX:Number = 10;
				
				var camzoom:Number = _camera.getZoom();
				var camRect:Rectangle = _camera.getScreenRect();
				
				if (sp is FighterMain) {
					if ((sp as FighterMain).getVecX() != 0 || 
						(sp as FighterMain).isInAir) 
					{
						if (camzoom == _camera.autoZoomMin) {
							var camLeft:Number = camRect.x + offsetX;
							var camRight:Number = camLeft + camRect.width - offsetX;
							
							if (left < camLeft) {
								left = camLeft;
							}
							if (right > camRight) {
								right = camRight;
							}
						}
					}
				}
				
				var isTouchSide:Boolean = false;
				if (sp.x <= left) {
					sp.x = left;
					isTouchSide = true;
				}
				if (sp.x >= right) {
					sp.x = right;
					isTouchSide = true;
				}
				
				sp.setIsTouchSide(isTouchSide);
			}
			if (!sp.allowCrossMapBottom()) {
				if (sp.y > _map.bottom) {
					sp.y = _map.bottom;
				}
			}
		}
		
		public static function resetFighterHP(v:FighterMain):void {
			var messionRate:Number = 1;
			
			if (GameMode.isAcrade() && MessionModel.I.getCurrentMessionStage()) {
				messionRate = MessionModel.I.getCurrentMessionStage().hpRate;
			}
			if (v.customHpMax > 0) {
				v.hp = v.hpMax = v.customHpMax * GameData.I.config.fighterHP * messionRate;
			}
			else {
				v.hp = v.hpMax = 1000 * GameData.I.config.fighterHP * messionRate;
			}
			
			v.isAlive = true;
		}
		
		public static function setMessionEnemyAttack(v:FighterMain):void {
			var mv:MessionStageVO = MessionModel.I.getCurrentMessionStage();
			if (mv) {
				v.attackRate = mv.attackRate;
			}
		}
		
		public static function canSelectFighter(id:String):Boolean {
			var charList:SelectCharListConfigVO = GameData.I.config.select_config.charList;
			
			for each(var c:SelectCharListItemVO in charList.list) {
				if (c.fighterID == id) {
					return true;
				}
			}
			
			return false;
		}
		
		public static function canSelectAssist(id:String):Boolean {
			var assistList:SelectCharListConfigVO = GameData.I.config.select_config.assistList;
			
			for each(var c:SelectCharListItemVO in assistList.list) {
				if (c.fighterID == id) {
					return true;
				}
			}
			
			return false;
		}
		
//		public static function setGameMode(v:int):void {
//			if (v == 1) {
//				GameData.I.loadSelect("assets/config/salect.xml");
//				ResUtils.WINNER = "winner_stg_mc2";
//				SelectIndexUI.SHOW_MODE = 1;
//			}
//			else {
//				GameData.I.loadSelect("assets/config/select.xml");
//				ResUtils.WINNER = "winner_stg_mc";
//				SelectIndexUI.SHOW_MODE = 0;
//			}
//		}
	}
}
