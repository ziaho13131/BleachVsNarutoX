/**
 * 已重建完成
 */
package net.play5d.game.obvn.ui.fight {
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	
	import net.play5d.game.obvn.ctrl.AssetManager;
	import net.play5d.game.obvn.data.FighterVO;
	
	/**
	 * 角色脸部UI
	 */
	public class FightFaceUI {
		
		private var _ui:MovieClip;
		
		private var _ct:MovieClip;
		private var _sp:DisplayObject;
		
		public function FightFaceUI(ui:MovieClip) {
			_ui = ui;
			
			_ct = ui.ct;
			_sp = ui.sp;
		}
		
		public function setData(v:FighterVO):void {
			if (!v) {
				_ui.visible = false;
				return;
			}
			
			_ui.visible = true;
			
			var faceImg:DisplayObject = AssetManager.I.getFighterFaceBar(v);
			if (faceImg && _ct) {
				_ct.addChild(faceImg);
			}
		}
		
		public function setDirect(v:int):void {}
		
		public function setSp(p:Number):void {
			if (!_sp) {
				return;
			}
			
			_sp.scaleY = p;
		}
	}
}
