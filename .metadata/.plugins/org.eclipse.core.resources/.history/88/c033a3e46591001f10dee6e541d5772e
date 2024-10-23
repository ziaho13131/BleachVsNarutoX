/**
 * 已重建完成
 */
package net.play5d.game.bvn {
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.DataEvent;
	import flash.geom.Rectangle;
	
	import net.play5d.game.bvn.Debugger;
	import net.play5d.game.bvn.ctrl.GameRender;
	import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
	import net.play5d.game.bvn.data.EffectModel;
	import net.play5d.game.bvn.data.GameData;
	import net.play5d.game.bvn.input.GameInputer;
	import net.play5d.game.bvn.interfaces.GameInterface;
	import net.play5d.game.bvn.stage.CongratulateStage;
	import net.play5d.game.bvn.stage.CreditsStage;
	import net.play5d.game.bvn.stage.GameLoadingStage;
	import net.play5d.game.bvn.stage.GameOverStage;
	import net.play5d.game.bvn.stage.GameStage;
	import net.play5d.game.bvn.stage.HowToPlayStage;
	import net.play5d.game.bvn.stage.LoadingStage;
	import net.play5d.game.bvn.stage.LogoStage;
	import net.play5d.game.bvn.stage.MenuStage;
	import net.play5d.game.bvn.stage.SelectFighterStage;
	import net.play5d.game.bvn.stage.SettingStage;
	import net.play5d.game.bvn.stage.RuleStage;
	import net.play5d.game.bvn.stage.WinnerStage;
	import net.play5d.game.bvn.utils.GameLogger;
	import net.play5d.game.bvn.utils.ResUtils;
	import net.play5d.kyo.stage.KyoStageCtrl;
	
	/**
	 * 	生存模式
	 */
	import net.play5d.game.bvn.plot_Mode.Main_plot_Mode;
	
	public class MainGame {
		
		public static const VERSION:String = "V3.4 小幻神修改版 基于OpenBVN";			// 版本
		public static const VERSION_DATE:String = "2024.9.20";		                   // 版本日期
		public static var UPDATE_INFO:String = "更新记录:"+"\n"+
		"2024/7/1 新增剧情模式的开关 并修复了主界面按钮的若干BUG";
		
		public static var stageCtrl:KyoStageCtrl;					// 场景控制器
		public static var I:MainGame;

		public var MenuSt:MenuStage;
		
		private var _rootSprite:Sprite;
		private var _stage:Stage;
		
		private var _fps:Number = 60;
		
		public function MainGame() {
			I = this;
		}
		
		/**
		 * 获得根精灵
		 */
		public function get root():Sprite {
			return _rootSprite;
		}
		
		/**
		 * 获得主场景
		 */
		public function get stage():Stage {
			return _stage;
		}
		
		/**
		 * 初始化
		 */
		public function initlize(root:Sprite, stage:Stage, initBack:Function = null, initFail:Function = null):void {
			ResUtils.I.initalize(resInitBack, initFail);
			
			function resInitBack():void {
				GameLogger.log("res init ok");
				_rootSprite = root;
				_stage = stage;
				GameLogger.log("init game render");
				GameRender.initlize(stage);
				GameLogger.log("init game inputer");
				GameInputer.initlize(_stage);
				GameLogger.log("init game data");
				GameData.I.loadData();
				GameLogger.log("init config");
				GameData.I.config.applyConfig();
				GameLogger.log("init inputer config");
				GameInputer.updateConfig();
				GameLogger.log("init scroll");
				root.scrollRect = new Rectangle(0, 0, GameConfig.GAME_SIZE.x, GameConfig.GAME_SIZE.y);
				GameLogger.log("init stagectrl");
				stageCtrl = new KyoStageCtrl(_rootSprite);
				GameLogger.log("init loading");
				var loadingState:GameLoadingStage = new GameLoadingStage();
				stageCtrl.goStage(loadingState);
				loadingState.loadGame(loadGameBack, initFail);
			}
			function loadGameBack():void {
				EffectModel.I.initlize();
				if(!Debugger.MODE_DEBUG)goLogo();
				if (initBack != null) {
					initBack();
				}
			}
		}
		
		private static function resetDefault():void {
			GameCtrl.I.autoEndRoundAble = true;
			GameCtrl.I.autoStartAble = true;
			SelectFighterStage.AUTO_FINISH = true;
			LoadingStage.AUTO_START_GAME = true;
		}
		
		public function getFPS():Number {
			return _fps;
		}
		
		public function setFPS(v:Number):void {
			_fps = v;
			_stage.frameRate = v;
		}
		
		public function goLogo():void {
			stageCtrl.goStage(new LogoStage());
			setFPS(60);
		}
		
		public function goMenu():void {
			MainGame.I.stage.dispatchEvent(new DataEvent(
				"5d_message",
				false,
				false,
				JSON.stringify(["go_menu_stage"])
			));
			resetDefault();
			MenuSt = new MenuStage();
			stageCtrl.goStage(MenuSt);
			setFPS(60);
		}
		
		public function goHowToPlay():void {
			stageCtrl.goStage(new HowToPlayStage());
			
			setFPS(30);
		}
		
		public function goSelect():void {
			stageCtrl.goStage(new SelectFighterStage(),true);
			setFPS(30);
		}
		
		public function loadGame():void {
			var ls:LoadingStage = new LoadingStage();
			stageCtrl.goStage(ls, true);
			
			setFPS(60);
		}
		
		public function goGame():void {
			var gs:GameStage = new GameStage();
			stageCtrl.goStage(gs);
			
			GameCtrl.I.startGame();
			setFPS(GameConfig.FPS_GAME);
		}
		
		public function goOption():void {
			stageCtrl.goStage(new SettingStage());
			setFPS(60);
		}
		
		public function goRuleBook():void {
			stageCtrl.goStage(new RuleStage());
			setFPS(60);
		}
		
		public function goContinue():void {
			var stg:GameOverStage = new GameOverStage();
			stg.showContinue();
			stageCtrl.goStage(stg);
			
			setFPS(60);
		}
		
		public function goGameOver():void {
			var stg:GameOverStage = new GameOverStage();
			stg.showGameOver();
			stageCtrl.goStage(stg);

            setFPS(30);
		}
		
		public function goWinner():void {
			var stg:WinnerStage = new WinnerStage();
			stageCtrl.goStage(stg);
			setFPS(30);
		}
		
		public function goCredits():void {
			stageCtrl.goStage(new CreditsStage());
			setFPS(30);
		}
		
//		public static function moreGames():void {
//			GameInterface.instance.moreGames();
//		}
		
		public function goCongratulations():void {
			stageCtrl.goStage(new CongratulateStage());
			setFPS(30);
		}
		
//		public function submitScore():void {
//			GameInterface.instance.submitScore(GameData.I.score);
//		}
		
//		public function showRank():void {
//			GameInterface.instance.showRank();
//		}
		public function goBigmap():void{
			stageCtrl.goStage(new Main_plot_Mode());
		}
	}
}
