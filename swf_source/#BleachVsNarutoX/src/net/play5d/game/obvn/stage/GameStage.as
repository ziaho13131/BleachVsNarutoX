/**
 * 已重建完成
 */
package net.play5d.game.obvn.stage {
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import net.play5d.game.obvn.GameConfig;
	import net.play5d.game.obvn.ctrl.EffectCtrl;
	import net.play5d.game.obvn.ctrl.GameLogic;
	import net.play5d.game.obvn.ctrl.game_ctrler.GameCtrler;
	import net.play5d.game.obvn.data.GameData;
	import net.play5d.game.obvn.data.GameMode;
	import net.play5d.game.obvn.data.GameRunFighterGroup;
	import net.play5d.game.obvn.fighter.FighterMain;
	import net.play5d.game.obvn.interfaces.IGameSprite;
	import net.play5d.game.obvn.map.MapMain;
	import net.play5d.game.obvn.ui.GameUI;
	import net.play5d.game.obvn.utils.MCUtils;
	import net.play5d.kyo.stage.IStage;
	
	/**
	 * 游戏场景
	 */
	public class GameStage extends Sprite implements IStage {
		
		private var _gameLayer:Sprite = new Sprite();
		private var _playerLayer:Sprite = new Sprite();
		private var _gameSprites:Vector.<IGameSprite> = new Vector.<IGameSprite>();
		
		private var _map:MapMain;
		public var camera:GameCamera;
		private var _cameraFocus:Array;
		
		public var gameUI:GameUI;
		
		public function GameStage() {
			_gameLayer.mouseEnabled = false;
			_gameLayer.mouseChildren = false;
		}
		
//		public function get gameLayer():Sprite {
//			return _gameLayer;
//		}
		
		public function getMap():MapMain {
			return _map;
		}
		
		public function setVisibleByClass(cls:Class, visible:*):void {
			for each(var d:IGameSprite in _gameSprites) {
				var className:String = getQualifiedClassName(d);
				var ds:Class = getDefinitionByName(className) as Class;
				if (ds == cls) {
					d.getDisplay().visible = visible;
				}
			}
		}
		
		public function get display():DisplayObject {
			return this;
		}
		
		public function getGameSpriteGlobalPosition(sp:IGameSprite, offsetX:Number = 0, offsetY:Number = 0):Point {
			var zoom:Number = camera.getZoom(true);
			var rect:Rectangle = camera.getScreenRect(true);
			
			return new Point(
				(-rect.x + sp.x + offsetX) * zoom, 
				(-rect.y + sp.y + offsetY) * zoom
			);
		}
		
		public function getGameSprites():Vector.<IGameSprite> {
			return _gameSprites;
		}
		
		public function addGameSprite(sp:IGameSprite):void {
			if (_gameSprites.indexOf(sp) != -1) {
				return;
			}
			
			_gameSprites.push(sp);
			_playerLayer.addChild(sp.getDisplay());
			
			sp.setSpeedRate(GameConfig.SPEED_PLUS);					// 修复辅助慢放BUG
			sp.setVolume(GameData.I.config.soundVolume);
		}
		
		public function addGameSpriteAt(sp:IGameSprite, index:int):void {
			if (_gameSprites.indexOf(sp) != -1) {
				return;
			}
			
			_gameSprites.push(sp);
			_playerLayer.addChildAt(sp.getDisplay(), index);
			sp.setVolume(GameData.I.config.soundVolume);
		}
		
		public function removeGameSprite(sp:IGameSprite):void {
			var index:int = _gameSprites.indexOf(sp);
			if (index == -1) {
				return;
			}
			
			_gameSprites.splice(index, 1);
			try {
				_playerLayer.removeChild(sp.getDisplay());
			}
			catch (e:Error) {
			}
		}
		
		public function build():void {
			GameCtrler.I.initlize(this);
			EffectCtrl.I.initlize(this, _playerLayer);
			
			gameUI = new GameUI();
		}
		
		public function initFight(p1group:GameRunFighterGroup, p2group:GameRunFighterGroup, map:MapMain):void {
			_map = map;
			_map.gameState = this;
			
			if (_map.bgLayer) {
				addChild(_map.bgLayer);
			}
			addChild(_gameLayer);
			
			if (_map.mapLayer) {
				_gameLayer.addChild(_map.mapLayer);
			}
			_gameLayer.addChild(_playerLayer);
			
			if (_map.frontFixLayer) {
				_gameLayer.addChild(_map.frontFixLayer);
			}
			
			if (_map.frontLayer) {
				_gameLayer.addChild(_map.frontLayer);
			}
			
			_cameraFocus = [];
			var p1:FighterMain = p1group.currentFighter;
			var p2:FighterMain = p2group.currentFighter;
			if (p1) {
				GameLogic.resetFighterHP(p1);
				
				p1.x = _map.p1pos.x;
				p1.y = _map.p1pos.y;
				p1.direct = 1;
				p1.updatePosition();
				_cameraFocus.push(p1.getDisplay());
			}
			if (p2) {
				GameLogic.resetFighterHP(p2);
				
				if (GameMode.isAcrade()) {
					GameLogic.setMessionEnemyAttack(p2);
				}
				p2.x = _map.p2pos.x;
				p2.y = _map.p2pos.y;
				p2.direct = -1;
				p2.updatePosition();
				_cameraFocus.push(p2.getDisplay());
			}
			// 相同人物变色
			if (p1.data && p2.data && p1.data.id == p2.data.id) {
				MCUtils.changeColor(p2);
			}
			
			if (_map.mapLayer) {
//				var stageSize:Point = new Point(_map.mapLayer.width, GameConfig.GAME_SIZE.y);
				initCamera();
				
				camera.focus(_cameraFocus);
				gameUI.initFight(p1group, p2group);
				addChild(gameUI.getUIDisplay());
				
				return;
			}
			
			throw new Error("GameStage.initFight :: mapLayer is null!");
		}
		
		public function resetFight(p1group:GameRunFighterGroup, p2group:GameRunFighterGroup):void {
			var p1:FighterMain = p1group.currentFighter;
			var p2:FighterMain = p2group.currentFighter;
			_cameraFocus = [];
			
			if (p1) {
				GameLogic.resetFighterHP(p1);
				
				p1.x = _map.p1pos.x;
				p1.y = _map.p1pos.y;
				p1.direct = 1;
				p1.idle();
				p1.updatePosition();
				_cameraFocus.push(p1.getDisplay());
			}
			if (p2) {
				GameLogic.resetFighterHP(p2);
				
				p2.x = _map.p2pos.x;
				p2.y = _map.p2pos.y;
				p2.direct = -1;
				p2.idle();
				p2.updatePosition();
				_cameraFocus.push(p2.getDisplay());
			}
			// 相同人物变色
			if (p1.data && p2.data && p1.data.id == p2.data.id) {
				MCUtils.changeColor(p2);
			}
			
			gameUI.initFight(p1group, p2group);
			cameraResume();
		}
		
		public function cameraFocusOne(display:DisplayObject):void {
			camera.focus([display]);
			camera.setZoom(3.5);
			
			camera.tweenSpd = 2.5 / GameConfig.SPEED_PLUS_DEFAULT;
		}
		
		public function cameraResume():void {
			camera.focus(_cameraFocus);
			
			camera.tweenSpd = 2.5 / GameConfig.SPEED_PLUS_DEFAULT;
		}
		
		private function initCamera():void {
			if (camera) {
				throw new Error("GameStage.initCamera :: Camera inited!");
			}
			
			var stageSize:Point = _map.getStageSize();
			camera = new GameCamera(_gameLayer, GameConfig.GAME_SIZE, stageSize, true);
			camera.focusX = true;
			camera.focusY = true;
			camera.offsetY = _map.getMapBottomDistance();
			camera.setStageBounds(new Rectangle(0, -1000, stageSize.x, stageSize.y));
			camera.autoZoom = true;
			camera.autoZoomMin = 1;
			camera.autoZoomMax = 2.5;
			camera.tweenSpd = 2.5 / GameConfig.SPEED_PLUS_DEFAULT;
			
			var startX:Number = stageSize.x / 2 * 2 - 350;
			var startY:Number = _map.bottom - 200;
			camera.setZoom(2);
			camera.setX(-startX);
			camera.setY(-startY);
			camera.updateNow();
		}
		
		public function render():void {
			if (camera) {
				camera.render();
			}
			if (gameUI) {
				gameUI.render();
			}
			if (_map && camera) {
				var rect:Rectangle = camera.getScreenRect(true);
				_map.render(-rect.x, -rect.y, camera.getZoom(true));
			}
		}
		
//		public function drawGameRect(
//			rect:Rectangle,
//			color:uint = 0xFF0000, alpha:Number = 0.5,
//			clear:Boolean = false):void
//		{
//			if (clear) {
//				_gameLayer.graphics.clear();
//			}
//
//			_gameLayer.graphics.beginFill(color, alpha);
//			_gameLayer.graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
//			_gameLayer.graphics.endFill();
//		}
//
//		public function clearDrawGameRect():void {
//			_gameLayer.graphics.clear();
//		}
		
		public function afterBuild():void {}
		
		public function destory(back:Function = null):void {
			removeChildren();
			if (_gameSprites) {
				while (_gameSprites.length > 0) {
					removeGameSprite(_gameSprites.shift());
				}
				
				_gameSprites = null;
			}
			if (_playerLayer) {
				_playerLayer.removeChildren();
				_playerLayer = null;
			}
			if (_gameLayer) {
				_gameLayer.removeChildren();
				_gameLayer = null;
			}
			if (camera) {
				camera = null;
			}
			if (gameUI) {
				gameUI.destory();
				gameUI = null;
			}
			
			EffectCtrl.I.destory();
			GameCtrler.I.destory();
			
			if (_map) {
				_map.destory();
				_map = null;
			}
		}
	}
}
