/**
 * 已重建完成
 */
package net.play5d.game.obvn.views.effects {
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	
	import net.play5d.game.obvn.ctrl.AssetManager;
	
	/**
	 * 必杀脸部特写
	 */
	public class BishaFaceEffectView {
		
		public var mc:MovieClip = AssetManager.I.getEffect("bisha_face_mc");
		
		private var _faceObj:Object = {};
		
		public function setFace(faceId:int, face:DisplayObject):void {
			var faceMc:MovieClip = mc["facemc" + faceId];
			if (!faceMc) {
				return;
			}
			
			_faceObj[faceId] = face;
			face.width = 254;
			face.height = 180;
			
			faceMc.addChild(face);
		}
		
		public function fadIn():void {
			if (!mc) {
				return;
			}
			
			mc.gotoAndPlay(2);
		}
		
		public function fadOut():void {
			if (!mc) {
				return;
			}
			
			mc.gotoAndPlay("destory");
		}
		
		public function destory():void {
			fadOut();
			
			if (!_faceObj) {
				return;
			}
			
			for each(var i:DisplayObject in _faceObj) {
				if (i is Bitmap) {
					(i as Bitmap).bitmapData.dispose();
				}
			}
			
			_faceObj = null;
		}
	}
}
