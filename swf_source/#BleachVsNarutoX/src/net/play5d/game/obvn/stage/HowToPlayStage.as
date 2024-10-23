/**
 * 已重建完成
 */
package net.play5d.game.obvn.stage {
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	
	import net.play5d.game.obvn.MainGame;
	import net.play5d.game.obvn.ctrl.AssetManager;
	import net.play5d.game.obvn.ctrl.GameRender;
	import net.play5d.game.obvn.ctrl.SoundCtrl;
	import net.play5d.game.obvn.data.GameData;
	import net.play5d.game.obvn.data.KeyConfigVO;
	import net.play5d.game.obvn.input.GameInputType;
	import net.play5d.game.obvn.input.GameInputer;
	import net.play5d.game.obvn.utils.ResUtils;
	import net.play5d.kyo.input.KyoKeyCode;
	import net.play5d.kyo.stage.IStage;
	
	/**
	 * 如何开始游戏场景
	 */
	public class HowToPlayStage implements IStage {
		
		
		private var _ui:MovieClip;
		
		public function get display():DisplayObject {
			return _ui;
		}
		
		public function build():void {
			_ui = ResUtils.I.createDisplayObject(ResUtils.I.howtoplay, "movie_howtoplay");
			_ui.addEventListener(Event.COMPLETE, uiComplete);
			_ui.gotoAndPlay(2);
			
			SoundCtrl.I.BGM(AssetManager.I.getSound("back"));
			
			var kc:KeyConfigVO = GameData.I.config.key_p1;
			setKeyText(_ui.txt_up, kc.up);
			setKeyText(_ui.txt_down, kc.down);
			setKeyText(_ui.txt_left, kc.left);
			setKeyText(_ui.txt_right, kc.right);
			setKeyText(_ui.txt_attack, kc.attack);
			setKeyText(_ui.txt_jump, kc.jump);
			setKeyText(_ui.txt_dash, kc.dash);
			setKeyText(_ui.txt_skill, kc.skill);
			setKeyText(_ui.txt_bisha, kc.superKill);
			setKeyText(_ui.txt_special, kc.beckons);
			
			setTimeout(function ():void {
				GameRender.add(render);
				GameInputer.focus();
				GameInputer.enabled = true;
				_ui.skip_btn.addEventListener(MouseEvent.CLICK, skipBtnHandler);
			}, 1000);
		}
		
		private function render():void {
			if (GameInputer.back(1) || GameInputer.select(GameInputType.MENU, 1)) {
				GameRender.remove(render);
				
				_ui.gotoAndPlay("skip");
			}
		}
		
		private function skipBtnHandler(e:MouseEvent):void {
			GameRender.remove(render);
			
			_ui.gotoAndPlay("skip");
		}
		
		private function uiComplete(e:Event):void {
			_ui.removeEventListener(Event.COMPLETE, uiComplete);
			
			MainGame.I.goSelect();
		}
		
		private static function setKeyText(text:TextField, code:int):void {
			var name:String = KyoKeyCode.code2name(code);
			
			if (name) {
				text.text = name;
			}
		}
		
		public function afterBuild():void {}
		
		public function destory(back:Function = null):void {
			SoundCtrl.I.BGM(null);
			
			GameRender.remove(render);
			
			_ui.removeEventListener(Event.COMPLETE, uiComplete);
			
			_ui.gotoAndStop("destory");
		}
	}
}
