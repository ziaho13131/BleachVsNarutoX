/**
 * 已重建完成
 */
package net.play5d.game.obvn.map {
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import net.play5d.game.obvn.GameConfig;
	import net.play5d.game.obvn.GameQuality;
	import net.play5d.game.obvn.data.GameData;
	import net.play5d.game.obvn.data.MapVO;
	import net.play5d.game.obvn.interfaces.IGameSprite;
	import net.play5d.game.obvn.stage.GameStage;
	import net.play5d.game.obvn.utils.MCUtils;
	import net.play5d.kyo.utils.KyoUtils;
	
	/**
	 * 地图主类
	 */
	public class MapMain {
		
		
		public var mapLayer:MovieClip;
		public var frontLayer:Sprite;
		public var frontFixLayer:Sprite;
		public var bgLayer:Bitmap;
		
		public var p1pos:Point;
		public var p2pos:Point;
		
		public var left:Number = 0;
		public var right:Number = 0;
		public var bottom:Number = 0;
		public var playerBottom:Number = 0;
		
		public var mapMc:Sprite;
		
		public var data:MapVO;
		public var gameState:GameStage;
		
		private var _defaultFrontPos:Point;
		private var _floors:Array;
		
		public function MapMain(mapMc:Sprite) {
			this.mapMc = mapMc;
		}
		
		public function destory():void {
			if (mapMc) {
				try {
					MCUtils.stopAllMovieClips(mapMc);
					mapMc.removeChildren();
				}
				catch (e:Error) {
					trace(e);
				}
				
				mapMc = null;
			}
			if (mapLayer) {
				mapLayer = null;
			}
			if (frontLayer) {
				frontLayer = null;
			}
			if (frontFixLayer) {
				frontFixLayer = null;
			}
			if (bgLayer) {
				bgLayer.bitmapData.dispose();
				bgLayer = null;
			}
		}
		
		public function setVisible(v:Boolean):void {
			if (mapLayer) {
				mapLayer.visible = v;
			}
			if (frontLayer) {
				frontLayer.visible = v;
			}
			if (frontFixLayer) {
				frontFixLayer.visible = v;
			}
			if (bgLayer) {
				bgLayer.visible = v;
			}
		}
		
		public function initlize():void {
			var leftLine        :DisplayObject = mapMc.getChildByName("line_left");
			var rightLine       :DisplayObject = mapMc.getChildByName("line_right");
			var bottomLine      :DisplayObject = mapMc.getChildByName("line_bottom");
			var playerBottomLine:DisplayObject = mapMc.getChildByName("line_player_bottom");
			var gamesize        :Point         = GameConfig.GAME_SIZE;
			
			if (leftLine) {
				left = leftLine.x;
				mapMc.removeChild(leftLine);
			}
			if (rightLine) {
				right = rightLine.x;
				mapMc.removeChild(rightLine);
			}
			if (bottomLine) {
				bottom = bottomLine.y;
				mapMc.removeChild(bottomLine);
			}
			if (playerBottomLine) {
				playerBottom = playerBottomLine.y;
				mapMc.removeChild(playerBottomLine);
			}
			
			var p1mc:DisplayObject = mapMc.getChildByName("p1");
			var p2mc:DisplayObject = mapMc.getChildByName("p2");
			if (p1mc) {
				p1pos = new Point(p1mc.x, p1mc.y);
				mapMc.removeChild(p1mc);
			}
			if (p2mc) {
				p2pos = new Point(p2mc.x, p2mc.y);
				mapMc.removeChild(p2mc);
			}
			
			mapLayer      = mapMc.getChildByName("map")       as MovieClip;
			frontLayer    = mapMc.getChildByName("front")     as Sprite;
			frontFixLayer = mapMc.getChildByName("front_fix") as Sprite;
			
			bgLayer       = drawBitmap("bg", false, 0);
			if (bgLayer) {
				normalizeLayer(bgLayer);
			}
			var offsetY:Number = gamesize.y - bottom;
			if (mapLayer) {
				normalizeLayer(mapLayer);
				mapLayer.y += offsetY;
			}
			if (frontLayer) {
				normalizeLayer(frontLayer);
				frontLayer.y += offsetY;
				_defaultFrontPos = new Point(frontLayer.x, frontLayer.y);
			}
			if (frontFixLayer) {
				normalizeLayer(frontFixLayer);
				frontFixLayer.y += offsetY;
			}
			playerBottom += offsetY;
			bottom += offsetY;
			if (p1pos) {
				p1pos.y += offsetY;
			}
			if (p2pos) {
				p2pos.y += offsetY;
			}
			
			initFloor(offsetY);
		}
		
		private function drawBitmap(name:String, transparent:Boolean = true, fillColor:uint = 0):Bitmap {
			var d:DisplayObject = mapMc.getChildByName(name);
			if (!d) {
				return null;
			}
			
			return KyoUtils.drawDisplay(d, true, transparent, fillColor);
		}
		
		private static function normalizeLayer(display:DisplayObject):void {
			if (display is Bitmap) {
				(display as Bitmap).smoothing = GameData.I.config.quality == GameQuality.BEST;
			}
			if (display is Sprite) {
				var sp:Sprite = display as Sprite;
				for (var i:int = 0; i < sp.numChildren; i++) {
					var d:DisplayObject = sp.getChildAt(i);
					if (d is Bitmap) {
						(d as Bitmap).smoothing = GameData.I.config.quality == GameQuality.BEST;
					}
				}
//				if (GameConfig.MAP_LOGO_STATE != 1) {
//					var logoSp:DisplayObject = sp.getChildByName("logo4399");
//					if (logoSp) {
//						logoSp.visible = false;
//					}
//				}
			}
		}
		
		public function getStageSize():Point {
			return new Point(mapLayer.width, GameConfig.GAME_SIZE.y);
		}
		
		public function getMapBottomDistance():Number {
			return bottom - playerBottom;
		}
		
		private function initFloor(offsetY:Number):void {
			_floors = [];
			
			var floormc:Sprite = mapMc.getChildByName("floor") as Sprite;
			if (!floormc) {
				return;
			}
			
			for (var i:int = 0; i < floormc.numChildren; i++) {
				var f:DisplayObject = floormc.getChildAt(i);
				if (!f) {
					continue;
				}
				
				var fv:FloorVO = new FloorVO();
				fv.xFrom = floormc.x + f.x;
				fv.xTo = floormc.x + f.x + f.width;
				fv.y = floormc.y + f.y + offsetY;
				
				_floors.push(fv);
			}
		}
		
		public function getFloorHitTest(x:Number, y:Number, speed:Number):FloorVO {
			for each (var fv:FloorVO in _floors) {
				if (fv.hitTest(x, y, speed)) {
					return fv;
				}
			}
			
			return null;
		}
		
		public function render(gameX:Number, gameY:Number, zoom:Number):void {
			if (frontLayer) {
				var gx:Number = gameX;
				var gy:Number = gameY + bottom;
				var yy:Number = gy * 0.1 + _defaultFrontPos.y;
				
				frontLayer.x = gx * 0.1 + _defaultFrontPos.x;
				if (yy < _defaultFrontPos.y) {
					yy = _defaultFrontPos.y
				}
				
				frontLayer.y = yy;
				renderOptical(frontLayer);
			}
			
			if (frontFixLayer) {
				renderOptical(frontFixLayer);
			}
		}
		
		private function renderOptical(sp:Sprite):void {
			if (!gameState) {
				return;
			}
			var spLength:int = sp.numChildren;
			if (spLength < 1) {
				return;
			}
			var gameSps:Vector.<IGameSprite> = gameState.getGameSprites();
			if (!gameSps || gameSps.length < 1) {
				return;
			}
			for (var i:int = 0; i < spLength; i++) {
				var d:DisplayObject = sp.getChildAt(i);
				if (d is MovieClip != false) {
					var r:Rectangle = d.getBounds(sp);
					r.x += sp.x;
					r.y += sp.y;
					d.alpha = checkHitGameSprite(r, gameSps) ? 0.5 : 1;
				}
			}
		}
		
		private static function checkHitGameSprite(rect:Rectangle, gameSps:Vector.<IGameSprite>):Boolean {
			for (var i:int = 0; i < gameSps.length; i++) {
				var gp:IGameSprite = gameSps[i] as IGameSprite;
				if (!gp) {
					continue;
				}
				
				var rect2:Rectangle = gp.getArea();
				if (rect2) {
					if (rect.intersects(rect2)) {
						return true;
					}
				}
			}
			
			return false;
		}
	}
}
