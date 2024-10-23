/**
 * 已重建完成
 */
package net.play5d.game.obvn.stage {
	import com.greensock.TweenLite;
	import com.greensock.easing.Back;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.DataEvent;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	
	import net.play5d.game.obvn.Debugger;
	import net.play5d.game.obvn.GameConfig;
	import net.play5d.game.obvn.MainGame;
	import net.play5d.game.obvn.ctrl.AssetManager;
	import net.play5d.game.obvn.ctrl.GameLogic;
	import net.play5d.game.obvn.ctrl.GameRender;
	import net.play5d.game.obvn.ctrl.SoundCtrl;
	import net.play5d.game.obvn.ctrl.StateCtrl;
	import net.play5d.game.obvn.data.AssisterModel;
	import net.play5d.game.obvn.data.FighterModel;
	import net.play5d.game.obvn.data.FighterVO;
	import net.play5d.game.obvn.data.GameData;
	import net.play5d.game.obvn.data.GameMode;
	import net.play5d.game.obvn.data.MessionModel;
	import net.play5d.game.obvn.data.SelectCharListConfigVO;
	import net.play5d.game.obvn.data.SelectCharListItemVO;
	import net.play5d.game.obvn.data.SelectStageConfigVO;
	import net.play5d.game.obvn.data.SelectVO;
	import net.play5d.game.obvn.event.GameEvent;
	import net.play5d.game.obvn.input.GameInputType;
	import net.play5d.game.obvn.input.GameInputer;
	import net.play5d.game.obvn.ui.GameUI;
	import net.play5d.game.obvn.ui.select.MapSelectUI;
	import net.play5d.game.obvn.ui.select.SelectFighterItem;
	import net.play5d.game.obvn.ui.select.SelectUIFactory;
	import net.play5d.game.obvn.ui.select.SelectedFighterGroup;
	import net.play5d.game.obvn.ui.select.SelecterItemUI;
	import net.play5d.game.obvn.utils.KeyBoarder;
	import net.play5d.game.obvn.utils.ResUtils;
	import net.play5d.kyo.stage.IStage;
	import net.play5d.kyo.utils.KyoRandom;
	
	/**
	 * 选择角色场景
	 */
	public class SelectFighterStage implements IStage {
		
		public static var AUTO_FINISH:Boolean = true;
		private static const SELECT_STATE_FIGHTER:int = 0;
		private static const SELECT_STATE_ASSIST:int = 1;
		private static const SELECT_STATE_MAP:int = 2;
		
		
		private var _selectState:int;
		private var _ui:MovieClip;
		private var _config:SelectStageConfigVO;
		private var _curListConfig:SelectCharListConfigVO;
		private var _itemObj:Object;
		
		private var _p1Slt:SelecterItemUI;
		private var _p2Slt:SelecterItemUI;
		
		private var _p1SelectedGroup:SelectedFighterGroup;
		private var _p2SelectedGroup:SelectedFighterGroup;
		private var _mapSelectUI:MapSelectUI;
		
		private var _curStep:int = 0;
		private var _tweenTime:int = 500;
		private var _twoPlayerSelectFin:Boolean;
		
		public function get display():DisplayObject {
			return _ui;
		}
		
		public function build():void {
			_ui = ResUtils.I.createDisplayObject(ResUtils.I.select, ResUtils.SELECT);
			_config = GameData.I.config.select_config;
			
			GameRender.add(render);
			GameInputer.focus();
			GameInputer.enabled = false;
			
			nextStep();
			
			SoundCtrl.I.BGM(AssetManager.I.getSound("select"));
			
			StateCtrl.I.clearTrans();
			KeyBoarder.focus();
			MainGame.I.stage.dispatchEvent(new DataEvent(
				"5d_message",
				false,
				false,
				JSON.stringify(["select_fighter"])
			));
		}
		
		private function initFighter():void {
			trace("init select fighter");
			
			clear();
			_selectState = SELECT_STATE_FIGHTER;
			buildList(_config.charList);
			
			GameData.I.p1Select = new SelectVO();
			if (GameMode.isVsPeople() || GameMode.isVsCPU()) {
				GameData.I.p2Select = new SelectVO();
			}
			GameInputer.enabled = false;
			
			setTimeout(initSelecter, _tweenTime);
		}
		
		private function initAssist():void {
			trace("init select assist");
			
			clear();
			_selectState = SELECT_STATE_ASSIST;
			buildList(_config.assistList);
			GameInputer.enabled = false;
			
			setTimeout(initSelecter, _tweenTime);
		}
		
		private function fadOutList(back:Function = null):void {
			GameInputer.enabled = false;
			
			var outX:Number = GameConfig.GAME_SIZE.x / 2 - 30;
			var outY:Number = GameConfig.GAME_SIZE.y / 2 - 30;
			
			for each(var i:SelectFighterItem in _itemObj) {
				var delay:Number = Math.random() * 0.1;
				TweenLite.to(i.ui, 0.2, {
					x     : outX,
					y     : outY,
					scaleX: 0,
					scaleY: 0,
					delay : delay
				});
			}
			
			if (back != null) {
				TweenLite.delayedCall(0.3, back);
			}
		}
		
		private function clear():void {
			if (_itemObj) {
				for each(var i:SelectFighterItem in _itemObj) {
					i.removeEventListener(MouseEvent.MOUSE_OVER, selectFighterMouseHandler);
					i.removeEventListener(MouseEvent.CLICK, selectFighterMouseHandler);
					
					i.destory();
				}
				_itemObj = null;
			}
			if (_p1Slt) {
				_p1Slt.destory();
				_p1Slt = null;
			}
			if (_p2Slt) {
				_p2Slt.destory();
				_p2Slt = null;
			}
			if (_mapSelectUI) {
				_mapSelectUI.destory();
				_mapSelectUI = null;
			}
			if (_p1SelectedGroup) {
				_p1SelectedGroup.destory();
				_p1SelectedGroup = null;
			}
			if (_p2SelectedGroup) {
				_p2SelectedGroup.destory();
				_p2SelectedGroup = null;
			}
		}
		
		private function buildList(list:SelectCharListConfigVO):void {
			var startX:Number = _config.x + _config.left;
			var startY:Number = _config.y + _config.top;
			
			var gapX:Number = 
				list.HCount > 1 ? 
				(_config.width - _config.unitSize.x - _config.left - _config.right) / (list.HCount - 1) : 
				0;
			var gapY:Number = 
				list.VCount > 1 ? 
				(_config.height - _config.unitSize.y - _config.top - _config.bottom) / (list.VCount - 1) : 
				0;
			
			var charList:Array = list.list;
			_curListConfig = list;
			_itemObj = {};
			
			var initX:Number = GameConfig.GAME_SIZE.x / 2 - 30;
			var initY:Number = GameConfig.GAME_SIZE.y / 2 - 30;
			for (var i:int = 0; i < charList.length; i++) {
				var s:SelectCharListItemVO = charList[i] as SelectCharListItemVO;
				
				var sf:SelectFighterItem = addFighterItem(s);
				if (!sf) {
					continue;
				}
				
				var tx:Number = startX + gapX * sf.selectData.x;
				var ty:Number = startY + gapY * sf.selectData.y;
				if (sf.selectData.offset) {
					tx += sf.selectData.offset.x;
					ty += sf.selectData.offset.y;
				}
				sf.ui.scaleX = 0;
				sf.ui.scaleY = 0;
				sf.ui.x = initX;
				sf.ui.y = initY;
				
				var delay:Number = Math.random() * (_tweenTime - 300) / 1000;
				TweenLite.to(sf.ui, 0.3, {
					x     : tx,
					y     : ty,
					delay : delay,
					scaleX: 1,
					scaleY: 1,
					ease  : Back.easeOut
				});
			}
		}
		
		private function addFighterItem(sv:SelectCharListItemVO):SelectFighterItem {
			if (!sv.fighterID) {
				return null;
			}
			
			var fv:FighterVO = 
				_selectState == SELECT_STATE_ASSIST ? 
				AssisterModel.I.getAssister(sv.fighterID) : 
				FighterModel.I.getFighter(sv.fighterID)
			;
			if (!fv) {
				Debugger.log("SelectFighterStage.addFighterItem :: No fighter data was found:" + sv.fighterID);
				return null;
			}
			
			var si:SelectFighterItem = new SelectFighterItem(fv, sv);
			si.addEventListener(MouseEvent.MOUSE_OVER, selectFighterMouseHandler);
			si.addEventListener(MouseEvent.CLICK, selectFighterMouseHandler);
			
			_ui.addChild(si.ui);
			_itemObj[sv.x + "," + sv.y] = si;
			
			return si;
		}
		
		private function selectFighterMouseHandler(type:String, target:SelectFighterItem):void {
			if (!target || !target.selectData) {
				return;
			}
			
			switch (type) {
				case MouseEvent.MOUSE_OVER:
					doHover(target);
					break;
				case MouseEvent.CLICK:
					doSelect(target);
			}
		}
		
//		private function selectFighterTouchHandler(type:String, target:SelectFighterItem):void {
//			if (!target || !target.selectData) {
//				return;
//			}
//
//			var curSlt:SelecterItemUI = null;
//			if (_p1Slt && _p1Slt.enabled) {
//				curSlt = _p1Slt;
//			}
//			if (!curSlt && (_p2Slt && _p2Slt.enabled)) {
//				curSlt = _p2Slt;
//			}
//			if (!curSlt) {
//				return;
//			}
//
//			if (isHoverFighter(curSlt, target)) {
//				doSelect(target);
//				return;
//			}
//
//			doHover(target);
//		}
		
		private function doHover(target:SelectFighterItem):void {
			if (_p1Slt && _p1Slt.enabled) {
				if (_p1Slt.isSelected(target.selectData.fighterID)) {
					return;
				}
				
				moveToSelectFighter(_p1Slt, target);
				SoundCtrl.I.sndSelect();
				return;
			}
			
			if (_p2Slt && _p2Slt.enabled) {
				if (_p2Slt.isSelected(target.selectData.fighterID)) {
					return;
				}
				moveToSelectFighter(_p2Slt, target);
				SoundCtrl.I.sndSelect();
			}
		}
		
		private function doSelect(target:SelectFighterItem):void {
			if (_p1Slt && _p1Slt.enabled) {
				if (_p1Slt.isSelected(target.selectData.fighterID)) {
					return;
				}
				_p1Slt.select(playerSeltBack);
				SoundCtrl.I.sndConfrim();
				return;
			}
			
			if (_p2Slt && _p2Slt.enabled) {
				if (_p2Slt.isSelected(target.selectData.fighterID)) {
					return;
				}
				_p2Slt.select(playerSeltBack);
				SoundCtrl.I.sndConfrim();
			}
		}
		
		private function getFighterItem(x:int, y:int):SelectFighterItem {
			if (!_itemObj) {
				return null;
			}
			
			return _itemObj[x + "," + y];
		}
		
		private function initSelecter():void {
			GameInputer.enabled = true;
			if (GameMode.isVsPeople()) {
				initSelecterP1();
				initSelecterP2();
				_twoPlayerSelectFin = false;
				return;
			}
			
			initSelecterP1();
		}
		
		private function initSelecterP1():void {
			_p1Slt = SelectUIFactory.createSelecter(1);
			_p1Slt.isSelectAssist = _selectState == SELECT_STATE_ASSIST;
			_p1Slt.selectTimesCount = GameMode.isTeamMode() && !_p1Slt.isSelectAssist ? 3 : 1;
			
			_ui.addChild(_p1Slt.ui);
			_ui.addChild(_p1Slt.group);
			
			moveSlt(_p1Slt, 0, 0);
		}
		
		private function initSelecterP2():void {
			_p2Slt = SelectUIFactory.createSelecter(2);
			_p2Slt.isSelectAssist = _selectState == SELECT_STATE_ASSIST;
			
			_p2Slt.selectTimesCount = GameMode.isTeamMode() && !_p2Slt.isSelectAssist ? 3 : 1;
			_ui.addChild(_p2Slt.ui);
			_ui.addChild(_p2Slt.group);
			
			moveSlt(_p2Slt, 9, 0);
		}
		
		private function moveSlt(slt:SelecterItemUI, x:int, y:int, fix:Boolean = true):Boolean {
			var right:Boolean = false;
			var up:Boolean = false;
			var down:Boolean = false;
			var left:Boolean = false;
			
			var j:int = 0;
			var i:int = 0;
			var succ:Boolean = false;
			var sf:SelectFighterItem = getFighterItem(x, y)
			if (!sf || sf && slt.isSelected(sf.selectData.fighterID)) {
				if (!fix) {
					return true;
				}
				
				if (x > slt.x) {
					right = true;
					
					for (i = 0; i < _curListConfig.HCount; i++) {
						j = x + i;
						if (j > _curListConfig.HCount - 1) {
							j -= _curListConfig.HCount;
						}
						
						sf = getFighterItem(j, slt.y);
						if (sf && !slt.isSelected(sf.selectData.fighterID)) {
							break;
						}
					}
				}
				
				if (x < slt.x) {
					left = true;
					
					for (i = 0; i < _curListConfig.HCount; i++) {
						j = x - i;
						if (j < 0) {
							j = _curListConfig.HCount + j;
						}
						
						sf = getFighterItem(j, slt.y);
						if (sf && !slt.isSelected(sf.selectData.fighterID)) {
							break;
						}
					}
				}
				
				if (y > slt.y) {
					down = true;
					
					if (y > _curListConfig.VCount - 1) {
						y = 0;
					}
					
					for (i = y; i < _curListConfig.VCount; i++) {
						sf = getHLineFighter(slt.x, i);
						if (sf) {
							break;
						}
					}
				}
				
				if (y < slt.y) {
					up = true;
					
					if (y < 0) {
						y = _curListConfig.VCount - 1;
					}
					
					for (i = y; i >= 0; i--) {
						sf = getHLineFighter(slt.x, i);
						if (sf) {
							break;
						}
					}
				}
			}
			
			if (!sf) {
				return false;
			}
			
			slt.x = sf.selectData.x;
			slt.y = sf.selectData.y;
			
			if (slt.isSelected(sf.selectData.fighterID)) {
				if (up || down) {
					succ = moveSlt(slt, slt.x + 1, slt.y);
					if (!succ) {
						if (up) {
							moveSlt(slt, slt.x, slt.y - 1);
						}
						if (down) {
							moveSlt(slt, slt.x, slt.y + 1);
						}
					}
				}
				
				return true;
			}
			
			moveToSelectFighter(slt, sf);
			return true;
		}
		
//		private static function isHoverFighter(slt:SelecterItemUI, sf:SelectFighterItem):Boolean {
//			return slt.x == sf.selectData.x && slt.y == sf.selectData.y;
//		}
		
		private function moveToSelectFighter(slt:SelecterItemUI, sf:SelectFighterItem):void {
			slt.randoms = null;
			
			slt.x = sf.selectData.x;
			slt.y = sf.selectData.y;
			
			slt.moveTo(sf.ui.x, sf.ui.y);
			slt.currentFighter = sf.fighterData;
			
			if (slt.group) {
				slt.group.updateFighter(slt.currentFighter);
			}
			
			checkRandom(slt);
		}
		
		private function checkRandom(slt:SelecterItemUI):Boolean {
			if (slt.currentFighter.id.indexOf("random") != -1) {
				
				switch (_selectState) {
					case SELECT_STATE_FIGHTER:
						slt.randoms = FighterModel.I.getFighters(
							slt.currentFighter.comicType,
							function (fv:FighterVO):Boolean {
								return fv.id.indexOf("random") == -1 && 
									GameLogic.canSelectFighter(fv.id) && 
									!slt.selectVO.isSelected(fv.id);
							}
						);
						break;
					case SELECT_STATE_ASSIST:
						slt.randoms = AssisterModel.I.getAssisters(
							slt.currentFighter.comicType,
							function (fv:FighterVO):Boolean {
								return fv.id.indexOf("random") == -1 && 
									GameLogic.canSelectAssist(fv.id);
							}
						);
						break;
					default:
						return false;
				}
				
				slt.randFrame = 0;
				renderRandom(slt);
				
				return true;
			}
			return false;
		}
		
		private function getHLineFighter(startX:int, Y:int):SelectFighterItem {
			var sf:SelectFighterItem = null;
			
			var k:int = 0;
			while (true) {
				var X:int = startX + k;
				
				if (X >= 0 && X < _curListConfig.HCount) {
					sf = getFighterItem(X, Y);
					if (sf) {
						break;
					}
				}
				if (k == 0) {
					k = 1;
				}
				else if (k > 0) {
					k *= -1;
				}
				else {
					if (k < -_curListConfig.HCount) {
						return null;
					}
					
					k *= -1;
					k++;
				}
			}
			
			return sf;
		}
		
		private static function renderRandom(selt:SelecterItemUI):void {
			if (!selt.randoms) {
				return;
			}
			
			if (selt.randFrame > 0) {
				selt.randFrame = 0;
				return;
			}
			
			selt.randFrame++;
			selt.currentFighter = KyoRandom.getRandomInArray(selt.randoms, false);
			if (selt.group) {
				selt.group.updateFighter(selt.currentFighter);
			}
		}
		
		// 关闭对话框后的延时
		private var _closeDelay:int = 0;
		
		private function render():void {
			if (GameInputer.back(1)) {
				if (GameUI.showingDialog()) {
					GameUI.closeConfrim();
				}
				else {
					GameUI.confirm("BACK TITLE", "返回到主菜单？", MainGame.I.goMenu);
				}
			}
			
			if (GameUI.showingDialog()) {
				_closeDelay = 5;
				return;
			}
			else if (GameInputer.jump(GameInputType.P1, 1)) {
				GameUI.confirm("RESELECT", "重新选择？", MainGame.I.goSelect);
			}
			
			if (_closeDelay > 0) {
				_closeDelay--;
				return;
			}
			
			var type:String;
			if (_p1Slt && _p1Slt.enabled) {
				renderRandom(_p1Slt);
				
				type = _p1Slt.inputType;
				if (GameInputer.up(type, 1)) {
					moveSlt(_p1Slt, _p1Slt.x, _p1Slt.y - 1);
					SoundCtrl.I.sndSelect();
				}
				if (GameInputer.down(type, 1)) {
					moveSlt(_p1Slt, _p1Slt.x, _p1Slt.y + 1);
					SoundCtrl.I.sndSelect();
				}
				if (GameInputer.left(type, 1)) {
					moveSlt(_p1Slt, _p1Slt.x - 1, _p1Slt.y);
					SoundCtrl.I.sndSelect();
				}
				if (GameInputer.right(type, 1)) {
					moveSlt(_p1Slt, _p1Slt.x + 1, _p1Slt.y);
					SoundCtrl.I.sndSelect();
				}
				if (GameInputer.select(type, 1)) {
					_p1Slt.select(playerSeltBack);
					SoundCtrl.I.sndConfrim();
				}
			}
			
			if (_p2Slt && _p2Slt.enabled) {
				renderRandom(_p2Slt);
				
				type = _p2Slt.inputType;
				if (GameInputer.up(type, 1)) {
					moveSlt(_p2Slt, _p2Slt.x, _p2Slt.y - 1);
					SoundCtrl.I.sndSelect();
				}
				if (GameInputer.down(type, 1)) {
					moveSlt(_p2Slt, _p2Slt.x, _p2Slt.y + 1);
					SoundCtrl.I.sndSelect();
				}
				if (GameInputer.left(type, 1)) {
					moveSlt(_p2Slt, _p2Slt.x - 1, _p2Slt.y);
					SoundCtrl.I.sndSelect();
				}
				if (GameInputer.right(type, 1)) {
					moveSlt(_p2Slt, _p2Slt.x + 1, _p2Slt.y);
					SoundCtrl.I.sndSelect();
				}
				if (GameInputer.select(type, 1)) {
					_p2Slt.select(playerSeltBack);
					SoundCtrl.I.sndConfrim();
				}
			}
			
			if (_mapSelectUI && _mapSelectUI.enabled) {
				type = _mapSelectUI.inputType;
				
				if (GameInputer.left(type, 1)) {
					_mapSelectUI.prev();
					SoundCtrl.I.sndSelect();
				}
				if (GameInputer.right(type, 1)) {
					_mapSelectUI.next();
					SoundCtrl.I.sndSelect();
				}
				if (GameInputer.select(type, 1)) {
					_mapSelectUI.select(onMapSelect);
					SoundCtrl.I.sndConfrim();
				}
			}
		}
		
//		public function get p1SelectFinish():Boolean {
//			return _p1Slt && _p1Slt.selectFinish();
//		}
//
//		public function get p2SelectFinish():Boolean {
//			return _p2Slt && _p2Slt.selectFinish();
//		}
//
//		public function setSelect(player:int, selects:Array):void {
//			var selt:SelecterItemUI = player == 1 ? _p1Slt : _p2Slt;
//			selt.setCurrentSelect(selects);
//			selt.removeSelecter();
//			SoundCtrl.I.sndConfrim();
//		}
		
		private function playerSeltBack(selt:SelecterItemUI):void {
			if (selt.selectFinish()) {
				if (GameMode.isVsPeople()) {
					GameEvent.dispatchEvent(GameEvent.SELECT_FIGHTER_STEP, selt.getCurrentSelectes());
					
					var otherSlt:SelecterItemUI = selt == _p1Slt ? _p2Slt : _p1Slt;
					if (otherSlt && otherSlt.selectFinish() && !_twoPlayerSelectFin) {
						_twoPlayerSelectFin = true;
						if (!AUTO_FINISH) {
							return;
						}
						
						nextStep();
					}
				}
				else {
					nextStep();
				}
				
				selt.destory();
			}
			else if (!selt.randoms) {
				var move:int = selt == _p1Slt == 1 ? 1 : -1;
				moveSlt(selt, selt.x + move, selt.y, true);
			}
		}
		
		public function nextStep():void {
			switch (_curStep) {
				case 0:
					initFighter();
					_curStep = 1;
					break;
				case 1:
					if (GameMode.isVsCPU()) {
						_p1Slt.removeSelecter();
						_p1Slt.enabled = false;
						initSelecterP2();
						_p2Slt.inputType = GameInputType.P1;
						_curStep = 2;
						break;
					}
					
					fadOutList(initAssist);
					_curStep = 3;
					break;
				case 2:
					fadOutList(initAssist);
					_curStep = 3;
					break;
				case 3:
					if (GameMode.isVsCPU()) {
						_p1Slt.removeSelecter();
						_p1Slt.enabled = false;
						initSelecterP2();
						_p2Slt.inputType = GameInputType.P1;
						
						_curStep = 4;
						break;
					}
					if (GameMode.isVsCPU() || GameMode.isVsPeople()) {
						fadOutList(initMap);
						_curStep = 5;
						break;
					}
					
					startAcradeGame();
					break;
				case 4:
					_curStep = 5;
					
					fadOutList(initMap);
					break;
				case 5:
					selectFinish();
			}
		}
		
		private function initMap():void {
			trace("select map");
			
			MainGame.I.stage.dispatchEvent(new DataEvent("5d_message", false, false, JSON.stringify(["select_map"])));
			
			clear();
			GameInputer.enabled = false;
			_mapSelectUI = new MapSelectUI();
			_ui.addChild(_mapSelectUI);
			
			var oldX:Number = _mapSelectUI.x;
			var oldY:Number = _mapSelectUI.y;
			
			_mapSelectUI.scaleX = 0;
			_mapSelectUI.scaleY = 0;
			_mapSelectUI.x = GameConfig.GAME_SIZE.x / 2;
			_mapSelectUI.y = GameConfig.GAME_SIZE.y / 2;
			
			TweenLite.to(_mapSelectUI, 0.3, {
				x         : oldX,
				y         : oldY,
				scaleX    : 1,
				scaleY    : 1,
				ease      : Back.easeOut,
				onComplete: function ():void {
					if (_mapSelectUI) {
						_mapSelectUI.addMouseEvents(mapPrevHandler, mapNextHandler, mapConfrimHandler);
						_mapSelectUI.inputType = GameInputType.P1;
						_mapSelectUI.enabled = true;
					}
					
					GameInputer.enabled = true;
				}
			});
		}
		
		private function mapPrevHandler():void {
			_mapSelectUI.prev();
		}
		
		private function mapNextHandler():void {
			_mapSelectUI.next();
		}
		
		private function mapConfrimHandler():void {
			_mapSelectUI.select(onMapSelect);
		}
		
		private function onMapSelect():void {
			nextStep();
		}
		
		private static function startAcradeGame():void {
			MessionModel.I.initMession();
			selectFinish();
		}
		
		private static function selectFinish():void {
			GameEvent.dispatchEvent(GameEvent.SELECT_FIGHTER_FINISH);
			if (!AUTO_FINISH) {
				return;
			}
			
			goLoadGame();
			MainGame.I.stage.dispatchEvent(new DataEvent(
				"5d_message",
				false,
				false,
				JSON.stringify(["select_finish"])
			));
		}
		
		public static function goLoadGame():void {
			trace("start game!");
			
			StateCtrl.I.transIn(MainGame.I.loadGame);
		}
		
		public function afterBuild():void {}
		
		public function destory(back:Function = null):void {
			clear();
			
			GameRender.remove(render);
			GameInputer.enabled = false;
			
//			SoundCtrl.I.BGM(null);
			
			GameUI.closeConfrim();
		}
	}
}
