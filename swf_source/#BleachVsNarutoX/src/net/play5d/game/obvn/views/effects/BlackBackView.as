/**
 * 已重建完成
 */
package net.play5d.game.obvn.views.effects {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	import net.play5d.game.obvn.GameConfig;
	import net.play5d.game.obvn.ctrl.game_ctrler.GameCtrler;
	
	/**
	 * 黑屏背景元件
	 */
	public class BlackBackView extends Sprite {
		
		
		private var _bishaFace:BishaFaceEffectView;
		
//		private var isRenderFadIn:Boolean;
//		private var isRenderFadOut:Boolean;
		
		private var _bg:Bitmap;
		
		public function BlackBackView() {
			var bd:BitmapData = new BitmapData(
				GameConfig.GAME_SIZE.x / 10, GameConfig.GAME_SIZE.y / 10, 
				false, 0x000000
			);
			
			_bg = new Bitmap(bd);
			_bg.width = GameConfig.GAME_SIZE.x;
			_bg.height = GameConfig.GAME_SIZE.y;
			
			addChild(_bg);
		}
		
		public function destory():void {
			if (_bg) {
				try {
					removeChild(_bg);
				}
				catch (e:Error) {
				}
				
				_bg.bitmapData.dispose();
				_bg = null;
			}
			removeBishaFace();
		}
		
		public function renderAnimate():void {}
		
		public function fadIn():void {}
		
		public function fadOut():void {
			removeBishaFace();
			
			try {
				parent.removeChild(this);
			}
			catch (e:Error) {}
		}
		
		public function showBishaFace(faceId:int, face:DisplayObject):void {
			if (!_bishaFace) {
				_bishaFace = new BishaFaceEffectView();
				
				var zoom:Number = 1;
				if (GameCtrler.I && GameCtrler.I.gameState && GameCtrler.I.gameState.camera) {
					zoom = GameCtrler.I.gameState.camera.getZoom();
				}
				
				_bishaFace.mc.y = 100 + 100 / zoom;
				addChild(_bishaFace.mc);
			}
			
			_bishaFace.setFace(faceId, face);
			_bishaFace.fadIn();
		}
		
		private function removeBishaFace():void {
			if (_bishaFace) {
				_bishaFace.fadOut();
				_bishaFace.destory();
				_bishaFace = null;
			}
		}
	}
}
