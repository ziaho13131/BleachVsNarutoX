/**
 * 已重建完成
 */
package net.play5d.game.obvn.ui.fight {
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	
	import net.play5d.game.obvn.data.GameRunFighterGroup;
	import net.play5d.game.obvn.fighter.FighterMain;
	
	
	/**
	 * 战斗面部组类
	 */
	public class FightFaceGroup {
		
		private var _ui:MovieClip;
		
		private var _face1:FightFaceUI;
		private var _face2:FightFaceUI;
		private var _face3:FightFaceUI;
		
		private var _curFighter:FighterMain;
		
		public function FightFaceGroup(ui:MovieClip) {
			_ui = ui;
			_ui.face2.removeChild(_ui.face2.sp);
			_ui.face3.removeChild(_ui.face3.sp);
//			_ui.cacheAsBitmap = true;
			setCacheAsBitmap(true);
			
			_face1 = new FightFaceUI(_ui.face);
			_face2 = new FightFaceUI(_ui.face2);
			_face3 = new FightFaceUI(_ui.face3);
		}
		
		private function setCacheAsBitmap(v:Boolean):void {
			_ui.face.ct.cacheAsBitmap = v;
			_ui.face2.cacheAsBitmap = v;
			_ui.face3.cacheAsBitmap = v;
		}
		
		public function get ui():DisplayObject {
			return _ui;
		}
		
		public function setFighter(fighterGroup:GameRunFighterGroup = null):void {
//			_ui.cacheAsBitmap = false;
			setCacheAsBitmap(false);
			
			_curFighter = fighterGroup.currentFighter;
			if (_curFighter) {
				_face1.setData(_curFighter.data);
			}
			
			switch (_curFighter) {
				case fighterGroup.fighter1:
					_face2.setData(
						fighterGroup.fighter2 ? 
						fighterGroup.fighter2.data : 
						null
					);
					_face3.setData(
						fighterGroup.fighter3 ? 
						fighterGroup.fighter3.data : 
						null
					);
					break;
				case fighterGroup.fighter2:
					_face2.setData(
						fighterGroup.fighter3 ? 
						fighterGroup.fighter3.data : 
						null
					);
					_face3.setData(null);
					break;
				case fighterGroup.fighter3:
					_face2.setData(null);
					_face3.setData(null);
			}
			
//			_ui.cacheAsBitmap = true;
			setCacheAsBitmap(true);
		}
		
		public function setDirect(v:int):void {
			_face1.setDirect(v);
			_face2.setDirect(v);
			_face3.setDirect(v);
		}
		
		public function render():void {
			_face1.setSp(_curFighter.spRate);
		}
	}
}
