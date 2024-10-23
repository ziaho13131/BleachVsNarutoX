/**
 * 已重建完成
 */
package net.play5d.game.obvn.stage {
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.setTimeout;
	
	import net.play5d.game.obvn.GameConfig;
	import net.play5d.game.obvn.MainGame;
	import net.play5d.game.obvn.ctrl.AssetManager;
	import net.play5d.game.obvn.ctrl.GameRender;
	import net.play5d.game.obvn.ctrl.SoundCtrl;
	import net.play5d.game.obvn.data.GameData;
	import net.play5d.game.obvn.input.GameInputer;
	import net.play5d.game.obvn.interfaces.GameInterface;
	import net.play5d.game.obvn.ui.GameUI;
	import net.play5d.game.obvn.ui.MenuBtnGroup;
	import net.play5d.game.obvn.ui.UIUtils;
	import net.play5d.game.obvn.utils.ResUtils;
	import net.play5d.kyo.stage.IStage;
	
	/**
	 * 主菜单类
	 */
	public class MenuStage extends Sprite implements IStage {
		
		
		private var _ui:MovieClip;
		private var _btnGroup:MenuBtnGroup;
		private var _versionTxt:TextField;
		private var _destroyed:Boolean = false;
		
		public function get display():DisplayObject {
			return _ui;
		}
		
		public function build():void {
			_ui = ResUtils.I.createDisplayObject(ResUtils.I.title, ResUtils.TITLE);
			_ui.gotoAndStop(1);
			
			GameInterface.instance.initTitleUI(_ui);
			GameInputer.enabled = false;
			
			SoundCtrl.I.BGM(AssetManager.I.getSound("op"));
		}
		
		public function afterBuild():void {
			_ui.gotoAndPlay(2);
			
			setTimeout(function ():void {
				_ui.buttonMode = true;
				_ui.useHandCursor = true;
				_ui.addEventListener(MouseEvent.CLICK, showBtns);
				
				GameRender.add(render);
				GameInputer.focus();
				GameInputer.enabled = true;
			}, 500);
			
			_versionTxt = new TextField();
			UIUtils.formatText(_versionTxt, {
				color: 0x000000,
				size : 18
			});
			_versionTxt.text = MainGame.VERSION;
			_versionTxt.autoSize = TextFieldAutoSize.LEFT;
			_versionTxt.x = GameConfig.GAME_SIZE.x - _versionTxt.width - 15;
			_versionTxt.y = GameConfig.GAME_SIZE.y - _versionTxt.height - 10;
			
			_ui.addChild(_versionTxt);
			if (GameData.I.isFristRun && MainGame.UPDATE_INFO) {
				GameData.I.isFristRun = false;
				GameUI.alert("UPDATE", MainGame.UPDATE_INFO);
			}
		}
		
		private function render():void {
			if (_destroyed) {
				return;
			}
			
			if (GameInputer.anyKey(1)) {
				showBtns();
			}
		}
		
		private function showBtns(...params):void {
			_ui.removeEventListener(MouseEvent.CLICK, showBtns);
			
			GameRender.remove(render);
			
			_ui.buttonMode = false;
			_ui.useHandCursor = false;
			_ui.gotoAndPlay("menu");
			
			SoundCtrl.I.playSwcSound(snd_menu5);
			
			_btnGroup = new MenuBtnGroup();
			_btnGroup.enabled = false;
			_btnGroup.x = 470;
			_btnGroup.y = 100;
			var ct:Sprite = _ui.getChildByName("btnct") as Sprite;
			if (ct) {
				ct.addChild(_btnGroup);
			}
			else {
				_ui.addChild(_btnGroup);
			}
			
			_btnGroup.build();
			_btnGroup.fadIn(0.2, 0.04);
			
			setTimeout(function ():void {
				if (!_btnGroup) {
					return;
				}
				
				_btnGroup.enabled = true;
			}, 400);
		}
		
		public function destory(back:Function = null):void {
			_destroyed = true;
			if (_btnGroup) {
				try {
					_btnGroup.parent.removeChild(_btnGroup);
				}
				catch (e:Error) {
				}
				
				_btnGroup.destory();
				_btnGroup = null;
			}
			
			GameInputer.enabled = false;
		}
	}
}
