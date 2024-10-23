/**
 * 已重建完成
 */
package net.play5d.game.obvn.ui.dialog {
	import com.greensock.TweenLite;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormatAlign;
	
	import net.play5d.game.obvn.GameConfig;
	import net.play5d.game.obvn.ctrl.AssetManager;
	import net.play5d.game.obvn.event.SetBtnEvent;
	import net.play5d.game.obvn.ui.GameUI;
	import net.play5d.game.obvn.ui.SetBtnGroup;
	import net.play5d.game.obvn.ui.UIUtils;
	import net.play5d.kyo.display.bitmap.BitmapFontText;
	import net.play5d.kyo.display.shapes.Box;
	
	/**
	 * 对话框提示类
	 */
	public class ConfirmUI extends Sprite {
		
		private var _enTxt:BitmapFontText;
		private var _cnTxt:TextField;
		private var _btnGroup:SetBtnGroup;
		
		public var yesBack:Function;
		public var noBack:Function;
		
		public function ConfirmUI() {
			build();
		}
		
		public function destory():void {
			if (_enTxt) {
				_enTxt.dispose();
				_enTxt = null;
			}
			if (_btnGroup) {
				_btnGroup.removeEventListener(SetBtnEvent.SELECT, selectHandler);
				_btnGroup.destory();
				_btnGroup = null;
			}
		}
		
		private function build():void {
			var bg:Sprite = new Sprite();
			bg.graphics.beginFill(0, 0.3);
			bg.graphics.drawRect(0, 0, GameConfig.GAME_SIZE.x, GameConfig.GAME_SIZE.y);
			bg.graphics.endFill();
			
			addChild(bg);
			
			var box:Box = new Box(GameConfig.GAME_SIZE.x, 300, 0, 0.8);
			box.y = (GameConfig.GAME_SIZE.y - box.height) / 2;
			addChild(box);
			
			_enTxt = new BitmapFontText(AssetManager.I.getFont("font1"));
			_enTxt.y = 18;
			box.addChild(_enTxt);
			
			if (GameUI.SHOW_CN_TEXT) {
				_cnTxt = new TextField();
				UIUtils.formatText(_cnTxt, {
					color: 0xFFFFFF,
					size : 20,
					align: TextFormatAlign.CENTER
				});
				_cnTxt.y = _enTxt.y + _enTxt.height + 80;
				_cnTxt.width = GameConfig.GAME_SIZE.x;
				_cnTxt.height = 100;
				_cnTxt.mouseEnabled = false;
				
				box.addChild(_cnTxt);
			}
			_btnGroup = new SetBtnGroup();
			_btnGroup.startY = 0;
			_btnGroup.startX = 0;
			_btnGroup.direct = 0;
			_btnGroup.gap = 200;
			_btnGroup.setBtnData([{
				label: "YES",
				cn   : "是"
			}, {
				label: "NO",
				cn   : "否"
			}], 1);
			_btnGroup.addEventListener(SetBtnEvent.SELECT, selectHandler);
			_btnGroup.x = (GameConfig.GAME_SIZE.x - _btnGroup.width) / 2 + 30;
			_btnGroup.y = box.height - 80;
			box.addChild(_btnGroup);
			
			var boxy:Number = box.y;
			box.y = GameConfig.GAME_SIZE.y;
			TweenLite.to(box, 0.2, {
				y: boxy
			});
		}
		
		private function selectHandler(e:SetBtnEvent):void {
			switch (e.selectedLabel) {
				case "YES":
					if (yesBack != null) {
						yesBack();
						break;
					}
					break;
				case "NO":
					if (noBack != null) {
						noBack();
						break;
					}
			}
		}
		
		public function setMsg(en:String = null, cn:String = null):void {
			_enTxt.text = en ? en : "";
			_enTxt.x = (GameConfig.GAME_SIZE.x - _enTxt.width) / 2;
			if (_cnTxt) {
				_cnTxt.text = cn ? cn : "";
			}
		}
	}
}
