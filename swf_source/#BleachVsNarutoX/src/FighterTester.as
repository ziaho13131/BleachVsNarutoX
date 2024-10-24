/**
 * 已重建完成
 */
package {
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	import net.play5d.game.obvn.Debugger;
	import net.play5d.game.obvn.GameConfig;
	import net.play5d.game.obvn.GameQuality;
	import net.play5d.game.obvn.MainGame;
	import net.play5d.game.obvn.ctrl.GameLogic;
	import net.play5d.game.obvn.ctrl.StateCtrl;
	import net.play5d.game.obvn.ctrl.game_ctrler.GameCtrler;
	import net.play5d.game.obvn.ctrl.game_ctrler.TrainingCtrler;
	import net.play5d.game.obvn.data.GameData;
	import net.play5d.game.obvn.data.GameMode;
	import net.play5d.game.obvn.data.GameRunDataVO;
	import net.play5d.game.obvn.data.MapModel;
	import net.play5d.game.obvn.data.SelectVO;
	import net.play5d.game.obvn.fighter.FighterMain;
	import net.play5d.game.obvn.fighter.ctrler.FighterCtrler;
	import net.play5d.game.obvn.fighter.ctrler.FighterEffectCtrler;
	import net.play5d.game.obvn.fighter.ctrler.FighterVoice;
	import net.play5d.game.obvn.fighter.events.FighterEvent;
	import net.play5d.game.obvn.fighter.events.FighterEventDispatcher;
	import net.play5d.game.obvn.fighter.models.HitVO;
	import net.play5d.game.obvn.interfaces.GameInterface;
	import net.play5d.game.obvn.interfaces.GameInterfaceManager;
	import net.play5d.game.obvn.stage.LoadingStage;
	import net.play5d.kyo.display.ui.KyoSimpButton;
	
// 设置SWF参数 (宽度为800为Release模式 : 1000则为Debugger模式)
	[SWF(frameRate="60", backgroundColor="#000000", width="1000", height="600")]
	
	/**
	 * 游戏主类
	 */
	public class FighterTester extends Sprite {
		private var _debuggerMode:Boolean = stage.stageWidth != 800 && // 是否是调试模式 
			      stage.stageHeight == 600 && stage.stageWidth == 1000;
		private var _mainGame:MainGame;
		private var _gameSprite:Sprite;
		private var _testUI:Sprite;
		[Embed(source="/../res/tester.jpg")] // 嵌入测试机图片
		private var _testpicClass:Class;
		private var _testpic:Bitmap;
		private var _p1InputId:TextField;
		private var _p2InputId:TextField;
		private var _p1FzInputId:TextField;
		private var _p2FzInputId:TextField;
		private var _autoReceiveHp:TextField;
		private var _mapInputId:TextField;
		private var _fpsInput:TextField;
		private var _debugText:TextField;
		
		public function FighterTester() {
			if (stage) {
				if (!_debuggerMode) {
				// 赋值DebuggerMode 到 GameConfig	
					GameConfig.DEBUG_MODE = _debuggerMode;
				}
				
			// 初始化游戏	
				initlize();
				return;
			}
			addEventListener(Event.ADDED_TO_STAGE, initlize);
		}
		
	/**
	 * 重新设置游戏窗口尺寸
	 */	
		private function onResize(event:Event):void {	
			stage.stageWidth = 800;
			stage.stageHeight = 600;

		}	
		
	/**
	 * 初始化游戏
	 */
		private function initlize(e:Event = null):void {
		// 初始化Debugger	
			Debugger.initDebug(stage);
			Debugger.onErrorMsgCall = onDebugLog;
		
		// 初始化GameSprite
			_gameSprite = new Sprite();
			_gameSprite.scrollRect = new Rectangle(0, 0, GameConfig.GAME_SIZE.x, GameConfig.GAME_SIZE.y);
			addChild(_gameSprite);
			
		// 初始化GameInterfaceManager (游戏接口管理器)
			GameInterface.instance = new GameInterfaceManager();
		
		// 初始化测试机设置	
			GameData.I.config.keyInputMode = 1;
			GameData.I.config.quality = GameQuality.MEDIUM;
			GameData.I.config.fighterHP = 2;
			GameData.I.config.AI_level = 6;
			GameData.I.config.fightTime = -1;
		
		// 初始化MainGame (主要游戏)
			_mainGame = new MainGame();
			_mainGame.initlize(_gameSprite, stage, initBackHandler, initFailHandler);
		
		// 默认设置游戏转场为不开启	
			StateCtrl.I.transEnabled = false;
			
		}
		
		private function initBackHandler():void {
			if (_debuggerMode)buildTestUI();
			else _mainGame.goLogo();
		}
		
		private function initFailHandler(msg:String):void {
			     trace("initlize.initFailHandler :: Failed to initlize Game "+msg);
		}
		
		private function buildTestUI():void {
		 // 添加测试机底框
			_testUI = new Sprite();
			_testUI.x = 810;
			_testUI.graphics.beginFill(0xae292d, 1);
			_testUI.graphics.drawRect(-10, 0, 200, 600);
			_testUI.graphics.endFill();
			addChild(_testUI);
			
		 // 添加测试机图片
			_testpic = new _testpicClass();
			_testpic.width = 200;
			_testpic.height = 600;
			_testpic.x = -10;
			_testpic.alpha = 0.3;
			_testUI.addChild(_testpic);
			
		// 测试机选项标签间隔: y轴	
			var yy:Number = 20;
		
		// 添加选项标签	
			addLabel("Player 1", yy);
			yy += 40;
			
			addLabel("fighter_id", yy);
			_p1InputId = addInput("ichigo", yy, 80);
			yy += 40;
			
			addLabel("assistant_id", yy);
			_p1FzInputId = addInput("kon", yy, 80);
			yy += 80;
			
			addLabel("Player 2", yy);
			yy += 40;
			
			addLabel("fighter_id", yy);
			_p2InputId = addInput("naruto", yy, 80);
			yy += 40;
			
			addLabel("assistant_id", yy);
			_p2FzInputId = addInput("gaara", yy, 80);
			yy += 40;
			
			addLabel("map_id", yy);
			_mapInputId = addInput(MapModel.I.getAllMaps()[1].id, yy, 80);
			yy += 60;
			
			addLabel("Game FPS", yy);
			_fpsInput = addInput(GameConfig.FPS_GAME.toString(), yy, 80);
			yy += 40;
			
			addLabel("Recover", yy);
			_autoReceiveHp = addInput("1", yy, 80);
			yy += 60;
			
		// 设置测试机错误输出字体	
			_debugText = addLabel("夏娜碳等待调试ing(o゜▽゜)o☆", yy, 0);
			_debugText.width = 190;
			_debugText.height = 200;
			_debugText.textColor = 0xe3f050;
			_debugText.multiline = true;
           
		// 添加测试机选项按钮	
			addButton("Start Test", 500, 25, 140, 35, testGame);
			addButton("Kill P2", 550, 25, 140, 35, killP2);
		}
		
	/**
	 * 添加测试机选项标签
	 * *@param txt 选项字符串
	 * *@param y 选项y轴
	 * *@param x 选项x轴
	 */
		private function addLabel(txt:String, y:Number = 0, x:Number = 0):TextField {
		// 设置字体样式	
			var tf:TextFormat = new TextFormat();
			tf.size = 14;
			tf.color = 0xffc26c;
		
		// 设置字体
			var label:TextField = new TextField();
			label.defaultTextFormat = tf;
			label.text = txt;
			label.x = x;
			label.y = y;
			label.mouseEnabled = false;
			_testUI.addChild(label);
			return label;
		}
		
	/**
	 * 添加测试机选项输入
	 * *@param txt 输入字符串
	 * *@param y 输入y轴
	 * *@param x 输入x轴
	 */	
		private function addInput(txt:String, y:Number = 0, x:Number = 0):TextField {
			var tf:TextFormat = new TextFormat();
			tf.size = 14;
			tf.color = 0;
			
			var label:TextField = new TextField();
			label.defaultTextFormat = tf;
			label.text = txt;
			label.x = x;
			label.y = y;
			label.width = 100;
			label.height = 20;
			label.backgroundColor = 0xFFFFFF;
			label.background = true;
			label.type = TextFieldType.INPUT;
			label.condenseWhite = true;
			
			_testUI.addChild(label);
			return label;
		}
		
	/**
	 * 添加测试机按钮选项
	 * *@param label 按钮字符串
	 * *@param y 按钮y轴
	 * *@param x 按钮x轴
	 * *@param width 按钮宽度
	 * *@param height 按钮高度
	 * *@param click 按钮回调函数 
	 */	
		private function addButton(
			label:String,
			y:Number = 0, x:Number = 0,
			width:Number = 100, height:Number = 50,
			click:Function = null):Sprite {
		
		// 设置Kyo简单按钮
			var btn:KyoSimpButton = new KyoSimpButton(label, width, height);
			btn.x = x;
			btn.y = y;
			
		// 如果存在回调函数 则: 设置按钮触发后执行回调函数
			if (click != null) {
				btn.onClick(click);
			}
		
		// 添加按钮 	
			_testUI.addChild(btn);
			return btn;
		}
		
		private function onDebugLog(msg:String):void {
			if (!_debugText) {
				return;
			}
			
			_debugText.text = msg;
		}
		
		private function changeFPS(...params):void {
			var fps:int = int(_fpsInput.text);
			
			GameConfig.setGameFps(fps);
			stage.frameRate = fps;
		}
		
		private function testGame(...params):void {
			changeFPS();
			GameMode.currentMode = GameMode.TRAINING;
			TrainingCtrler.RECOVER_HP = _autoReceiveHp.text != "0";
			
			GameData.I.p1Select = new SelectVO();
			GameData.I.p2Select = new SelectVO();
			
			GameData.I.p1Select.fighter1 = _p1InputId.text;
			GameData.I.p2Select.fighter1 = _p2InputId.text;
			GameData.I.p1Select.fuzhu = _p1FzInputId.text;
			GameData.I.p2Select.fuzhu = _p2FzInputId.text;
			GameData.I.selectMap = _mapInputId.text;
			
			loadGame();
		}
		
		private static function loadGame():void {
			var ls:LoadingStage = new LoadingStage();
			MainGame.stageCtrl.goStage(ls);
		}
		
		private function killP2(...params):void {
			var rundata:GameRunDataVO = GameCtrler.I.gameRunData;
			if (!rundata) {
				Debugger.errorMsg("No game data!");
				return;
			}
			if (!GameCtrler.I.actionEnable) {
				Debugger.errorMsg("In system control!");
				return;
			}
			
			var p1:FighterMain = rundata.p1FighterGroup.currentFighter;
			var p2:FighterMain = rundata.p2FighterGroup.currentFighter;
			if (!p1 || !p2) {
				return;
			}
			if (GameMode.currentMode == GameMode.TRAINING) {
				Debugger.errorMsg("Current mode is TRAINING!");
				return;
			}
			if (!p1.isAlive || !p2.isAlive) {
				return;
			}
			
			var hv:HitVO = new HitVO();
			hv.owner = p1;
			
			var p2hp:Number = p2.hp;
			p2.hurtHit = hv;
			p2.loseHp(p2hp);
			
			var p2Ctrler:FighterCtrler = p2.getCtrler();
			p2Ctrler.getMcCtrl().idle();
			p2Ctrler.getMcCtrl().hurtFly(-5, 0);
			p2Ctrler.getVoiceCtrl().playVoice(FighterVoice.DIE);
			
			var p2EffectCtrl:FighterEffectCtrler = p2Ctrler.getEffectCtrl();
			p2EffectCtrl.endBisha();
			p2EffectCtrl.endGhostStep();
			p2EffectCtrl.endGlow();
			
			if (GameLogic.checkFighterDie(p2)) {
				Debugger.errorMsg("LoseHp : " + p2hp);
				
				FighterEventDispatcher.dispatchEvent(p2, FighterEvent.DIE);
				p2.isAlive = false;
				
				trace("Kill P2 success!");
			}
		}
	}
}
