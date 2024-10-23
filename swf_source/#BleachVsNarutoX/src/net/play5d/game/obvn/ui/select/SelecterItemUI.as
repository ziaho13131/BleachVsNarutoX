/**
 * 已重建完成
 */
package net.play5d.game.obvn.ui.select {
	import flash.display.MovieClip;
	
	import net.play5d.game.obvn.data.AssisterModel;
	import net.play5d.game.obvn.data.FighterModel;
	import net.play5d.game.obvn.data.FighterVO;
	import net.play5d.game.obvn.data.SelectVO;
	import net.play5d.game.obvn.utils.ResUtils;
	import net.play5d.kyo.utils.KyoUtils;
	
	/**
	 * 选择器UI类
	 */
	public class SelecterItemUI {
		
		public var ui:MovieClip;
		public var currentFighter:FighterVO;
		public var selectTimes:int;
		public var selectTimesCount:int = 1;
		public var inputType:String;
		public var group:SelectedFighterGroup;
		public var selectVO:SelectVO;
		public var isSelectAssist:Boolean;
		
		public var x:int;
		public var y:int;
		
		public var enabled:Boolean = true;
		public var randoms:Vector.<FighterVO> = null;
		public var randFrame:int;
		
		private var _playerType:int;
		
		public function SelecterItemUI(playerType:int = 1) {
			_playerType = playerType;
			
			ui = ResUtils.I.createDisplayObject(ResUtils.I.select, "select_item_mc");
			ui.mouseChildren = false;
			ui.mouseEnabled = false;
			ui.mc.gotoAndStop(playerType == 1 ? 1 : 2);
		}
		
		public function selectFinish():Boolean {
			return selectTimes >= selectTimesCount;
		}
		
		public function getCurrentSelectes():Array {
			if (isSelectAssist) {
				return [selectVO.fuzhu];
			}
			
			return [selectVO.fighter1, selectVO.fighter2, selectVO.fighter3];
		}
		
//		public function setCurrentSelect(v:Array):void {
//			if (isSelectAssist) {
//				selectVO.fuzhu = v[0];
//				group.updateFighter(AssisterModel.I.getAssister(selectVO.fuzhu));
//			}
//			else {
//				selectVO.fighter1 = v[0];
//				selectVO.fighter2 = v[1];
//				selectVO.fighter3 = v[2];
//
//				group.updateFighter(FighterModel.I.getFighter(selectVO.fighter1));
//				group.addFighter(FighterModel.I.getFighter(selectVO.fighter2));
//				group.addFighter(FighterModel.I.getFighter(selectVO.fighter3));
//			}
//
//			selectTimes = selectTimesCount;
//			enabled = false;
//		}
		
		public function isSelected(id:String):Boolean {
			if (!selectVO) {
				return false;
			}
			if (isSelectAssist) {
				return selectVO.fuzhu == id;
			}
			
			return selectVO.fighter1 == id || selectVO.fighter2 == id || selectVO.fighter3 == id;
		}
		
		public function select(back:Function = null):void {
			if (!selectVO) {
				throw new Error("SelecterItemUI.select :: Not set selectVO!");
			}
			if (isSelectAssist) {
				selectVO.fuzhu = currentFighter.id;
			}
			else {
				switch (selectTimes) {
					case 0:
						selectVO.fighter1 = currentFighter.id;
						break;
					case 1:
						selectVO.fighter2 = currentFighter.id;
						break;
					case 2:
						selectVO.fighter3 = currentFighter.id;
				}
			}
			
			selectTimes++;
			if (!selectFinish()) {
				group.addFighter(currentFighter);
			}
			
			enabled = false;
			var _this:SelecterItemUI = this;
			
			ui.gotoAndPlay("select");
			updateRandom();
			
			KyoUtils.addFrameScript(ui, function ():void {
				if (!selectFinish()) {
					enabled = true;
				}
				if (back != null) {
					// 防止 this 指向问题
					back(_this);
				}
			});
		}
		
		public function moveTo(x:Number, y:Number):void {
			ui.x = x;
			ui.y = y;
		}
		
		public function destory():void {
			enabled = false;
			removeSelecter();
			removeGroup();
		}
		
		public function removeSelecter():void {
			if (ui && ui.parent) {
				try {
					ui.parent.removeChild(ui);
				}
				catch (e:Error) {
				}
				
				ui = null;
			}
		}
		
		public function removeGroup():void {
			if (group && group.parent) {
				try {
					group.parent.removeChild(group);
				}
				catch (e:Error) {
				}
				
				group = null;
			}
		}
		
		private function updateRandom():void {
			if (!randoms) {
				return;
			}
			if (!selectVO) {
				return;
			}
			
			if (selectVO.fighter1) {
				removeRand(selectVO.fighter1);
			}
			if (selectVO.fighter2) {
				removeRand(selectVO.fighter2);
			}
			if (selectVO.fighter3) {
				removeRand(selectVO.fighter3);
			}
		}
		
		private function removeRand(id:String):void {
			var index:int = -1;
			
			for (var i:int = 0; i < randoms.length; i++) {
				if (randoms[i].id == id) {
					index = i;
					
					break;
				}
			}
			
			if (index != -1) {
				randoms.splice(index, 1);
			}
		}
	}
}
