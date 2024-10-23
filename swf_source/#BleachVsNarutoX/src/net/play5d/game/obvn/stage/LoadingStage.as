/**
 * 已重建完成
 */
package net.play5d.game.obvn.stage {
//	import com.greensock.TweenLite;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.DataEvent;
	import flash.utils.setTimeout;
	
	import net.play5d.game.obvn.Debugger;
	import net.play5d.game.obvn.MainGame;
	import net.play5d.game.obvn.ctrl.AssetManager;
	import net.play5d.game.obvn.ctrl.GameLoader;
	import net.play5d.game.obvn.ctrl.GameRender;
	import net.play5d.game.obvn.ctrl.SoundCtrl;
	import net.play5d.game.obvn.ctrl.StateCtrl;
	import net.play5d.game.obvn.ctrl.game_ctrler.GameCtrler;
	import net.play5d.game.obvn.data.FighterModel;
	import net.play5d.game.obvn.data.FighterVO;
	import net.play5d.game.obvn.data.GameData;
	import net.play5d.game.obvn.data.GameRunFighterGroup;
	import net.play5d.game.obvn.data.MapModel;
	import net.play5d.game.obvn.data.MapVO;
	import net.play5d.game.obvn.data.SelectVO;
	import net.play5d.game.obvn.fighter.Assister;
	import net.play5d.game.obvn.fighter.FighterMain;
	import net.play5d.game.obvn.input.GameInputer;
	import net.play5d.game.obvn.map.MapMain;
	import net.play5d.game.obvn.ui.GameUI;
	import net.play5d.game.obvn.ui.select.SelectIndexUI;
	import net.play5d.game.obvn.utils.ResUtils;
	import net.play5d.kyo.stage.IStage;
	
	/**
	 * 加载场景
	 */
	public class LoadingStage implements IStage {
		
		public static var AUTO_START_GAME:Boolean = true;
		
		private var _ui:MovieClip;
		private var _sltUI:MovieClip;
		private var _loadQueue:Array;
		private var _curMsg:String;
		private var _loadCount:int;
		private var _destoryed:Boolean;
		private var _loadFin:Boolean;
		private var _selectIndexUI:SelectIndexUI;
		
		private var _loadedFighterCache:Object = {};
		private var _currentLoadBack:Function;
		
		private var _gameFinished:Boolean;
		
		public function get display():DisplayObject {
			return _ui;
		}
		
//		public function p1SelectFinish():Boolean {
//			return _selectIndexUI.p1Finish();
//		}
//
//		public function p2SelectFinish():Boolean {
//			return _selectIndexUI.p2Finish();
//		}
//
//		public function selectFinish():Boolean {
//			return _selectIndexUI.isFinish();
//		}
//
//		public function getSort():Array {
//			return [_selectIndexUI.getP1Order(), _selectIndexUI.getP2Order()];
//		}
//
//		public function setOrder(player:int, v:Array):void {
//			if (player == 1) {
//				_selectIndexUI.setP1Order(v);
//			}
//			if (player == 2) {
//				_selectIndexUI.setP2Order(v);
//			}
//		}
		
		public function build():void {
			MainGame.I.stage.dispatchEvent(new DataEvent(
				"5d_message",
				false,
				false,
				JSON.stringify(["loading_start"])
			));
			
			GameRender.add(render);
			GameInputer.focus();
			GameInputer.enabled = true;
			
			SoundCtrl.I.BGM(AssetManager.I.getSound("loading"));
			
			_ui = ResUtils.I.createDisplayObject(ResUtils.I.fight, "loading_fight_mc");
			_sltUI = _ui.sltui;
			_selectIndexUI = new SelectIndexUI();
			_selectIndexUI.onFinish = finish;
			_sltUI.addChild(_selectIndexUI);
			
			_loadQueue = [];
			
			var p1selt:SelectVO = GameData.I.p1Select;
			var p2selt:SelectVO = GameData.I.p2Select;
			var fighters:Array = [{
				id    : p1selt.fighter1,
				runobj: {
					id: "p1"
				}
			}, {
				id    : p1selt.fighter2,
				runobj: {
					id: "p1"
				}
			}, {
				id    : p1selt.fighter3,
				runobj: {
					id: "p1"
				}
			}, {
				id    : p2selt.fighter1,
				runobj: {
					id: "p2"
				}
			}, {
				id    : p2selt.fighter2,
				runobj: {
					id: "p2"
				}
			}, {
				id    : p2selt.fighter3,
				runobj: {
					id: "p2"
				}
			}];
			var assisters:Array = [{
				id    : p1selt.fuzhu,
				runobj: {
					group: "p1FighterGroup",
					id   : "fuzhu"
				}
			}, {
				id    : p2selt.fuzhu,
				runobj: {
					group: "p2FighterGroup",
					id   : "fuzhu"
				}
			}];
			
			var fightBGMs:Array = [];
			
			var i:int;
			var o:Object;
			var fighterName:String;
			var fighter:FighterVO;
			for (i = 0; i < fighters.length; i++) {
				o = fighters[i];
				if (!o.id) {
					continue;
				}
				
				fighterName = o.id;
				fighter = FighterModel.I.getFighter(o.id);
				
				if (fighter) {
					if (fighter.bgm) {
						fightBGMs.push({
							id  : fighter.id,
							url : fighter.bgm,
							rate: fighter.bgmRate
						});
					}
					
					fighterName = fighter.name;
				}
				_loadQueue.push({
					msg   : "正在加载角色：" + fighterName,
					func  : GameLoader.loadFighter,
					params: [
						o.id, 
						function (fighter:FighterMain, runobj:Object):void {
							if (_destoryed) {
								return;
							}
							
							cacheFighter(fighter, runobj.id, fighter.data.id);
							loadNext();
						}, 
						loadFail, 
						loadProcess,
						o.runobj
					]
				});
			}
			for (i = 0; i < assisters.length; i++) {
				o = assisters[i];
				if (!o.id) {
					continue;
				}
				
				fighter = FighterModel.I.getFighter(o.id);
				fighterName = fighter ? fighter.name : o.id;
				
				_loadQueue.push({
					msg   : "正在加载辅助角色：" + fighterName,
					func  : GameLoader.loadAssister,
					params: [
						o.id, 
						function (fighter:Assister, runobj:Object):void {
							if (_destoryed) {
								return;
							}
							
							GameCtrler.I.gameRunData[runobj.group][runobj.id] = fighter;
							loadNext();
						}, 
						loadFail, 
						loadProcess, 
						o.runobj
					]
				});
			}
			
			var map:MapVO = MapModel.I.getMap(GameData.I.selectMap);
			var mapName:String = map ? map.name : GameData.I.selectMap;
			_loadQueue.push({
				msg   : "正在加载场景：" + mapName,
				func  : GameLoader.loadMap,
				params: [
					GameData.I.selectMap, 
					function (map:MapMain):void {
						if (_destoryed) {
							return;
						}
						
						if (map.data && map.data.bgm) {
							fightBGMs.push({
								id  : "map",
								url : map.data.bgm,
								rate: 1
							});
						}
						
						GameCtrler.I.gameRunData.map = map;
						loadNext();
					}, 
					loadFail
				]
			});
			
			if (fightBGMs.length > 0) {
				_loadQueue.push({
					msg   : "正在加载BGM",
					func  : SoundCtrl.I.loadFightBGM,
					params: [
						fightBGMs, 
						loadNext, 
						loadFail, 
						loadProcess
					]
				});
			}
			_loadCount = _loadQueue.length;
			setTimeout(loadNext, 1000);
		}
		
		private static function render():void {
			if (GameInputer.back(1)) {
				if (GameUI.showingDialog()) {
					GameUI.closeConfrim();
				}
				else {
					GameUI.confirm("BACK TITLE", "返回到主菜单？", MainGame.I.goMenu);
				}
			}
		}
		
		private function loadNext():void {
			if (!_loadQueue || _loadQueue.length < 1) {
				loadFin();
				return;
			}
			
			var o:Object = _loadQueue.shift();
			updateMsg(o.msg);
			_currentLoadBack = o.back;
			o.func.apply(null, o.params);
		}
		
//		private function loadFighterComplete(fighter:FighterMain):void {
//			if (_currentLoadBack) {
//				_currentLoadBack(fighter);
//				_currentLoadBack = null;
//			}
//			loadNext();
//		}
		
		private function loadFin():void {
//			TweenLite.to(_sltUI, 1, {
//				y         : 80,
//				onComplete: function ():void {
//					setTimeout(delayCall, 2000);
//				}
//			});
			
			setTimeout(function ():void {
				_loadFin = true;
				finish();
			}, 1000);
		}
		
		private function finish():void {
			if (_destoryed) {
				return;
			}
			
			if (!_selectIndexUI.isFinish() || !_loadFin) {
				return;
			}
			
			if (!AUTO_START_GAME) {
				return;
			}
			
			if (_gameFinished) {
				return;
			}
			
			_gameFinished = true;
			var sort1:Array = _selectIndexUI.getP1Order();
			var sort2:Array = _selectIndexUI.getP2Order();
			
			gotoGame(sort1, sort2);
		}
		
		public function gotoGame(sort1:Array, sort2:Array):void {
			var p1group:GameRunFighterGroup = GameCtrler.I.gameRunData.p1FighterGroup;
			var p2group:GameRunFighterGroup = GameCtrler.I.gameRunData.p2FighterGroup;
			
			p1group.fighter1 = getCacheFighter("p1", sort1[0]);
			p1group.fighter2 = getCacheFighter("p1", sort1[1]);
			p1group.fighter3 = getCacheFighter("p1", sort1[2]);
			p2group.fighter1 = getCacheFighter("p2", sort2[0]);
			p2group.fighter2 = getCacheFighter("p2", sort2[1]);
			p2group.fighter3 = getCacheFighter("p2", sort2[2]);
			
			p1group.currentFighter = p1group.fighter1;
			p2group.currentFighter = p2group.fighter1;
			
			MainGame.I.stage.dispatchEvent(new DataEvent(
				"5d_message",
				false,
				false,
				JSON.stringify(["loading_finish"])
			));
			
			StateCtrl.I.transIn(MainGame.I.goGame, false);
		}
		
		private function getCacheFighter(player:String, id:String):FighterMain {
			if (id == null) {
				return null;
			}
			
			var cacheId:String = player + "_" + id;
			var fighter:FighterMain = _loadedFighterCache[cacheId] as FighterMain;
			if (!fighter) {
				throw new Error("LoadingStage.getCacheFighter :: Not find fighter:" + cacheId);
			}
			
			return fighter;
		}
		
		private function cacheFighter(fighter:FighterMain, player:String, id:String):void {
			var cacheId:String = player + "_" + id;
			
			_loadedFighterCache[cacheId] = fighter;
		}
		
		private static function loadFail(msg:String):void {
			Debugger.errorMsg(msg);
		}
		
		private function loadProcess(v:Number):void {
			_sltUI.bar.bar.scaleX = v;
		}
		
		private function updateMsg(msg:String = null):void {
			if (msg) {
				_curMsg = msg;
			}
			
			var cur:int = _loadCount - _loadQueue.length;
			_sltUI.bar.txt.text = _curMsg + "(" + cur + "/" + _loadCount + ")";
		}
		
		public function afterBuild():void {
			StateCtrl.I.transOut();
		}
		
		public function destory(back:Function = null):void {
			_destoryed = true;
			if (_selectIndexUI) {
				_selectIndexUI.destory();
				_selectIndexUI = null;
			}
			
			SoundCtrl.I.BGM(null);
			_loadedFighterCache = null;
			_loadQueue = null;
			
			GameInputer.clearInput();
			GameRender.remove(render);
			GameUI.closeConfrim();
		}
	}
}
