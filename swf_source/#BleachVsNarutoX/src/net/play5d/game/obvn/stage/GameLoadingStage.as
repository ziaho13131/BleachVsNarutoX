/**
 * 已重建完成
 */
package net.play5d.game.obvn.stage {
	import flash.display.DisplayObject;
	
	import net.play5d.game.obvn.Debugger;
	import net.play5d.game.obvn.ctrl.AssetManager;
	import net.play5d.game.obvn.data.GameData;
	import net.play5d.game.obvn.utils.ResUtils;
	import net.play5d.kyo.stage.IStage;
	
	import flash.display.MovieClip;
	
	/**
	 * 游戏加载场景
	 */
	public class GameLoadingStage implements IStage {
		
		private var _ui:MovieClip;
		
		private var _initBack:Function;
		private var _initFail:Function;
		
		public function get display():DisplayObject {
			return _ui;
		}
		
		public function build():void {
			_ui = ResUtils.I.createDisplayObject(ResUtils.I.loading, "loading_cover_mc");
		}
		
		public function loadGame(succ:Function, fail:Function):void {
			_initBack = succ;
			_initFail = fail;
			
			if (AssetManager.I.needPreLoad()) {
				AssetManager.I.loadPreLoad(loadPreloadBack, loadPreloadFail, loadPreloadProcess);
				msg("游戏初始化：准备游戏资源");
				return;
			}
			
			loadPreloadBack();
		}
		
		private function loadPreloadBack():void {
			GameData.I.loadConfig(loadConfigBack, loadConfigFail);
			msg("游戏初始化：正在加载配置文件");
		}
		
		private function loadPreloadFail(errorStr:String = null):void {
			Debugger.log("游戏初始化失败：准备游戏资源失败：", errorStr);
			msg("游戏初始化失败：准备游戏资源失败!");
			if (_initFail != null) {
				_initFail(errorStr);
			}
		}
		
		private function loadPreloadProcess(p:Number):void {
			if (p > 1) {
				p = 1;
			}
			
			_ui.bar.bar.scaleX = p;
		}
		
		private function loadConfigFail(errorStr:String):void {
			Debugger.log("游戏初始化失败：加载配置文件失败：", errorStr);
			msg("游戏初始化失败：加载配置文件失败!");
			
			if (_initFail != null) {
				_initFail(errorStr);
			}
		}
		
		private function loadConfigBack():void {
			AssetManager.I.loadBasic(loadAssetBack, loadAssetProcess);
			msg("游戏初始化：正在加载游戏资源");
		}
		
		private function loadAssetProcess(p:Number, message:String, step:int, totalStep:int):void {
			if (p > 1) {
				trace(message + " :: Progressover 100%!");
				p = 1;
			}
			
			_ui.bar.bar.scaleX = p;
			msg("游戏初始化：正在加载" + message + "资源(" + step + "/" + totalStep + ")");
		}
		
		private function loadAssetBack():void {
			if (_initBack != null) {
				_initBack();
				_initBack = null;
			}
			_initFail = null;
		}
		
		public function afterBuild():void {}
		
		public function destory(back:Function = null):void {}
		
		private function msg(v:String):void {
			_ui.bar.txt.text = v;
		}
	}
}
