/**
 * 已重建完成
 */
package net.play5d.game.obvn.stage {
	import com.greensock.TweenLite;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	
	import net.play5d.game.obvn.GameConfig;
	import net.play5d.game.obvn.MainGame;
	import net.play5d.game.obvn.ctrl.AssetManager;
	import net.play5d.game.obvn.ctrl.SoundCtrl;
	import net.play5d.game.obvn.data.ConfigVO;
	import net.play5d.game.obvn.data.GameData;
	import net.play5d.game.obvn.data.KeyConfigVO;
	import net.play5d.game.obvn.event.SetBtnEvent;
	import net.play5d.game.obvn.input.GameInputer;
	import net.play5d.game.obvn.interfaces.IInnerSetUI;
	import net.play5d.game.obvn.ui.SetBtnGroup;
	import net.play5d.game.obvn.ui.SetCtrlBtnUI;
	import net.play5d.game.obvn.utils.ResUtils;
	import net.play5d.kyo.stage.IStage;
	
	/**
	 * 设置界面场景类
	 */
	public class SettingStage implements IStage {
		
		private var _ui:MovieClip;
		private var _btnGroup:SetBtnGroup;
		private var _innerSetUI:IInnerSetUI;
		private var _man:MovieClip;
		
		public function get display():DisplayObject {
			return _ui;
		}
		
		public function build():void {
			_ui = ResUtils.I.createDisplayObject(ResUtils.I.setting, ResUtils.SETTING);
			
			_btnGroup = new SetBtnGroup();
			_btnGroup.startY = 30;
			_btnGroup.endY = 550;
			_btnGroup.gap = 70;
			_btnGroup.initMainSet();
			_btnGroup.initScroll(GameConfig.GAME_SIZE.x, 600);
			_btnGroup.addEventListener(SetBtnEvent.SELECT, onBtnSelect);
			_btnGroup.addEventListener(SetBtnEvent.OPTION_CHANGE, onOptionChange);
			
			_ui.addChild(_btnGroup);
			_man = _ui.ichigo;
			
			SoundCtrl.I.BGM(AssetManager.I.getSound("back"));
		}
		
		private static function onOptionChange(e:SetBtnEvent):void {
			var config:ConfigVO = GameData.I.config;
			config.setValueByKey(e.optionKey, e.optionValue);
		}
		
		private function onBtnSelect(e:SetBtnEvent):void {
			switch (e.selectedLabel) {
				case "P1 KEY SET":
					goKeyConfig(1, GameData.I.config.key_p1);
					break;
				case "P2 KEY SET":
					goKeyConfig(2, GameData.I.config.key_p2);
					break;
				case "APPLY":
					GameData.I.saveData();
					GameData.I.config.applyConfig();
					GameInputer.updateConfig();
					MainGame.I.goMenu();
			}
		}
		
		private function goKeyConfig(player:int, key:KeyConfigVO):void {
			var setBtnUI:SetCtrlBtnUI = new SetCtrlBtnUI();
			
			setBtnUI.setKey(key);
			goInnerSetPage(setBtnUI);
		}
		
		public function goInnerSetPage(innerUI:IInnerSetUI):void {
			destoryInnerSetUI();
			
			_innerSetUI = innerUI;
			innerUI.addEventListener(SetBtnEvent.APPLY_SET, innerSetHandler);
			innerUI.addEventListener(SetBtnEvent.CANCEL_SET, innerSetHandler);
			
			_ui.addChild(innerUI.getUI());
			innerUI.fadIn();
			
			TweenLite.to(_btnGroup, 0.2, {
				y         : -GameConfig.GAME_SIZE.y,
				onComplete: function ():void {
					_btnGroup.visible = false;
				}
			});
			
			_btnGroup.keyEnable = false;
			_man.gotoAndPlay("key_fadin");
			
			
		}
		
		private function destoryInnerSetUI():void {
			if (!_innerSetUI) {
				return;
			}
			
			try {
				_ui.removeChild(_innerSetUI.getUI());
			}
			catch (e:Error) {
			}
			
			_innerSetUI.removeEventListener(SetBtnEvent.APPLY_SET, innerSetHandler);
			_innerSetUI.removeEventListener(SetBtnEvent.CANCEL_SET, innerSetHandler);
			_innerSetUI.destory();
			_innerSetUI = null;
		}
		
		private function goMainSetting():void {
			TweenLite.to(_btnGroup, 0.2, {
				y         : 0,
				onComplete: function ():void {
					_btnGroup.keyEnable = true;
				},
				delay     : 0.1
			});
			
			_btnGroup.visible = true;
			
			if (_innerSetUI) {
				_innerSetUI.fadOut();
				_innerSetUI.removeEventListener(SetBtnEvent.APPLY_SET, innerSetHandler);
				_innerSetUI.removeEventListener(SetBtnEvent.CANCEL_SET, innerSetHandler);
			}
			
			_man.gotoAndPlay("key_fadout");
		}
		
		private function innerSetHandler(v:String):void {
			goMainSetting();
		}
		
		public function afterBuild():void {}
		
		public function destory(back:Function = null):void {
			if (_btnGroup) {
				try {
					_ui.removeChild(_btnGroup);
				}
				catch (e:Error) {
				}
				
				_btnGroup.removeEventListener(SetBtnEvent.SELECT, onBtnSelect);
				_btnGroup.removeEventListener(SetBtnEvent.OPTION_CHANGE, onOptionChange);
				_btnGroup.destory();
				_btnGroup = null;
			}
			destoryInnerSetUI();
		}
	}
}
