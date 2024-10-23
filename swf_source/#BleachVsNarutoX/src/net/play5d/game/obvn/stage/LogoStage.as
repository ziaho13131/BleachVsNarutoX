/**
 * 已重建完成
 */
package net.play5d.game.obvn.stage {
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import net.play5d.game.obvn.MainGame;
	import net.play5d.game.obvn.utils.ResUtils;
	import net.play5d.kyo.stage.IStage;
	
	import flash.display.MovieClip;
	
	/**
	 * 标志界面场景类
	 */
	public class LogoStage implements IStage {
		
		private var _ui:MovieClip;
		
		public function get display():DisplayObject {
			return _ui;
		}
		
		public function build():void {
			_ui = ResUtils.I.createDisplayObject(ResUtils.I.common_ui, "logo_movie");
			_ui.addEventListener(Event.COMPLETE, playComplete);
			_ui.gotoAndPlay(2);
		}
		
		private function playComplete(e:Event):void {
			_ui.removeEventListener(Event.COMPLETE, playComplete);
			MainGame.I.goMenu();
		}
		
		public function afterBuild():void {}
		
		public function destory(back:Function = null):void {
			_ui.removeEventListener(Event.COMPLETE, playComplete);
		}
	}
}
