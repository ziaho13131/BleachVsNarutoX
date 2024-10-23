/**
 * 已重建完成
 */
package net.play5d.game.obvn.ui {
	import flash.display.Sprite;
	import flash.events.DataEvent;
	
	import net.play5d.game.obvn.GameConfig;
	import net.play5d.game.obvn.MainGame;
	import net.play5d.game.obvn.ctrl.game_ctrler.GameCtrler;
	import net.play5d.game.obvn.event.SetBtnEvent;
	
	/**
	 * 暂停界面
	 */
	public class PauseDialog extends Sprite {
		
		private var _bg:Sprite;
		private var _btnGroup:SetBtnGroup;
		
		private var _moveList:MoveListSp;
		
		public function PauseDialog() {
			_bg = new Sprite();
			_bg.graphics.beginFill(0, 0.5);
			_bg.graphics.drawRect(0, 0, GameConfig.GAME_SIZE.x, GameConfig.GAME_SIZE.y);
			_bg.graphics.endFill();
			
			addChild(_bg);
			
			_btnGroup = new SetBtnGroup();
			_btnGroup.setBtnData([{
				label: "GAME TITLE",
				cn   : "返回标题"
			}, {
				label: "MOVE LIST",
				cn   : "出招表"
			}, {
				label: "BACK SELECT",
				cn   : "返回选人"
			}, {
				label: "CONTINUE",
				cn   : "继续游戏"
			}], 3);
			
			_btnGroup.addEventListener(SetBtnEvent.SELECT, btnGroupSelectHandler);
			addChild(_btnGroup);
		}
		
		public function destory():void {
			if (_btnGroup) {
				_btnGroup.removeEventListener(SetBtnEvent.SELECT, btnGroupSelectHandler);
				_btnGroup.destory();
				_btnGroup = null;
			}
			if (_moveList) {
				_moveList.destory();
				_moveList = null;
			}
		}
		
//		public function isShowing():Boolean {
//			return visible;
//		}
		
		public function show():void {
			visible = true;
			
			_btnGroup.keyEnable = true;
			_btnGroup.setArrowIndex(3);
		}
		
		public function hide():void {
			visible = false;
			
			_btnGroup.keyEnable = false;
			GameUI.closeConfrim();
		}
		
		private function btnGroupSelectHandler(e:SetBtnEvent):void {
			if (GameUI.showingDialog()) {
				return;
			}
			
			switch (e.selectedLabel) {
				case "GAME TITLE":
					_btnGroup.keyEnable = false;
					
					GameUI.confirm("BACK TITLE", "返回到主菜单？", function ():void {
						MainGame.I.stage.dispatchEvent(new DataEvent(
							"5d_message",
							false,
							false,
							JSON.stringify(["back_title"])
						));
						MainGame.I.goMenu();
					}, function ():void {
						_btnGroup.keyEnable = true;
						MainGame.I.stage.dispatchEvent(new DataEvent(
							"5d_message",
							false,
							false,
							JSON.stringify(["back_title_cancel"])
						));
					});
					break;
				case "MOVE LIST":
					showMoveList();
					
					MainGame.I.stage.dispatchEvent(new DataEvent(
						"5d_message",
						false,
						false,
						JSON.stringify(["move_list"])
					));
					break;
				case "BACK SELECT":
					MainGame.I.goSelect();
					break;
				case "CONTINUE":
					GameCtrler.I.resume(true);
			}
		}
		
		private function showMoveList():void {
			if (!_moveList) {
				_moveList = new MoveListSp();
				_moveList.onBackSelect = hideMoveList;
				addChild(_moveList);
			}
			_btnGroup.keyEnable = false;
			_moveList.show();
		}
		
		private function hideMoveList():void {
			_moveList.hide();
			
			_btnGroup.keyEnable = true;
			MainGame.I.stage.dispatchEvent(new DataEvent(
				"5d_message",
				false,
				false,
				JSON.stringify(["move_list_cancel"])
			));
		}
	}
}
