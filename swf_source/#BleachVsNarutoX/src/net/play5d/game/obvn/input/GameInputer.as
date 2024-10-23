/**
 * 已重建完成
 */
package net.play5d.game.obvn.input {
	import flash.display.Stage;
	import flash.utils.Dictionary;
	
	import net.play5d.game.obvn.MainGame;
	import net.play5d.game.obvn.ctrl.GameRender;
	import net.play5d.game.obvn.data.GameData;
	import net.play5d.game.obvn.interfaces.GameInterface;
	import net.play5d.game.obvn.interfaces.IGameInput;
	
	/**
	 * 游戏输入其
	 */
	public class GameInputer {
		
		private static const JUST_DOWN_DELAY:Number = 0.1;
		
		private static var _inputMap:Dictionary = new Dictionary();
		public static var enabled:Boolean = true;
		private static var _justDownKeys:Object = {};
		private static var _justDownDelayKeys:Object = {};
		private static var _listenKeys:Object;
		
		
		public static function initlize(stage:Stage):void {
			initInput();
			callVoid("initlize", stage);
			
			GameRender.add(render);
		}
		
		public static function initInput():void {
			var menu:Vector.<IGameInput> = GameInterface.instance.getGameInput(GameInputType.MENU);
			if (!menu) {
				menu = new Vector.<IGameInput>([new GameKeyInput()]);
			}
			var p1:Vector.<IGameInput> = GameInterface.instance.getGameInput(GameInputType.P1);
			if (!p1) {
				p1 = new Vector.<IGameInput>([new GameKeyInput()]);
			}
			var p2:Vector.<IGameInput> = GameInterface.instance.getGameInput(GameInputType.P2);
			if (!p2) {
				p2 = new Vector.<IGameInput>([new GameKeyInput()]);
			}
			
			setInput(GameInputType.MENU, menu);
			GameInputer.setInput(GameInputType.P1, p1);
			GameInputer.setInput(GameInputType.P2, p2);
		}
		
		public static function setInput(type:String, input:Vector.<IGameInput>):void {
			_inputMap[type] = input;
		}
		
		public static function updateConfig():void {
			if (GameInterface.instance.updateInputConfig()) {
				return;
			}
			
			setConfig(GameInputType.MENU, GameData.I.config.key_menu);
			setConfig(GameInputType.P1, GameData.I.config.key_p1);
			setConfig(GameInputType.P2, GameData.I.config.key_p2);
		}
		
		private static function setConfig(type:String, config:Object):void {
			call(type, "setConfig", config);
		}
		
		public static function focus():void {
			callVoid("focus");
		}
		
		public static function listenKeys(type:String, ids:Array, justDown:int):void {
			if (justDown != 1 && justDown != 2) {
				return;
			}
			
			if (!_listenKeys) {
				_listenKeys = {};
			}
			var id:String = type + "_" + justDown;
			_listenKeys[id] = {
				type    : type,
				ids     : ids,
				justDown: justDown
			};
		}
		
		public static function unListenKeys(type:String, justDown:int):void {
			var id:String = type + "_" + justDown;
			delete _listenKeys[id];
		}
		
		private static function renderListenKeys():void {
			if (!_listenKeys) {
				return;
			}
			for each(var o:Object in _listenKeys) {
				var a:Array = o.ids as Array;
				var l:int = a.length;
				for (var i:int = 0; i < l; i++) {
					isDown(o.type, a[i], o.justDown, true);
				}
			}
		}
		
		private static function isListenedKey(type:String, funcName:String, justDown:int):Boolean {
			if (!_listenKeys) {
				return false;
			}
			
			var id:String = type + "_" + justDown;
			var o:Object = _listenKeys[id];
			if (!o || !o.ids) {
				return false;
			}
			
			return o.ids.indexOf(funcName) != -1;
		}
		
		public static function render():void {
			for (var i:String in _justDownDelayKeys) {
				if (_justDownDelayKeys[i] > 0) {
					_justDownDelayKeys[i]--;
				}
				else {
					delete _justDownDelayKeys[i];
				}
			}
			renderListenKeys();
		}
		
		public static function anyKey(justDown:int = 0):Boolean {
			return isDown(GameInputType.MENU, "anyKey", justDown);
		}
		
		public static function back(justDown:int = 0):Boolean {
			return isDown(GameInputType.MENU, "back", justDown);
		}
		
		public static function select(type:String, justDown:int = 0):Boolean {
			return isDown(type, "select", justDown);
		}
		
		public static function up(type:String, justDown:int = 0):Boolean {
			return isDown(type, "up", justDown);
		}
		
		public static function down(type:String, justDown:int = 0):Boolean {
			return isDown(type, "down", justDown);
		}
		
		public static function left(type:String, justDown:int = 0):Boolean {
			return isDown(type, "left", justDown);
		}
		
		public static function right(type:String, justDown:int = 0):Boolean {
			return isDown(type, "right", justDown);
		}
		
		public static function attack(type:String, justDown:int = 0):Boolean {
			return isDown(type, "attack", justDown);
		}
		
		public static function jump(type:String, justDown:int = 0):Boolean {
			return isDown(type, "jump", justDown);
		}
		
		public static function dash(type:String, justDown:int = 0):Boolean {
			return isDown(type, "dash", justDown);
		}
		
		public static function skill(type:String, justDown:int = 0):Boolean {
			return isDown(type, "skill", justDown);
		}
		
		public static function superSkill(type:String, justDown:int = 0):Boolean {
			return isDown(type, "superSkill", justDown);
		}
		
		public static function special(type:String, justDown:int = 0):Boolean {
			return isDown(type, "special", justDown);
		}
		
		public static function wankai(type:String, justDown:int = 0):Boolean {
			return isDown(type, "wankai", justDown);
		}
		
		public static function clearInput():void {
			_justDownKeys = {};
			_justDownDelayKeys = {};
			
			callVoid("clear");
		}
		
		private static function isDown(
			type:String, funcName:String, 
			justDown:int = 0, isListenCall:Boolean = false):Boolean 
		{
			var listened:Boolean = isListenCall ? false : isListenedKey(type, funcName, justDown);
			if (justDown == 1) {
				return isJustDown(type, funcName);
			}
			if (justDown == 2) {
				return isJustDownDelay(type, funcName, listened);
			}
			return call(type, funcName);
		}
		
		private static function isJustDown(type:String, funcName:String):Boolean {
			var id:String = type + "_" + funcName;
			var isDown:Boolean = call(type, funcName);
			if (!isDown) {
				_justDownKeys[id] = false;
				return false;
			}
			
			if (_justDownKeys[id]) {
				return false;
			}
			
			_justDownKeys[id] = true;
			return true;
		}
		
		private static function isJustDownDelay(type:String, funcName:String, listened:Boolean):Boolean {
			var justDown:Boolean = isJustDown(type, funcName);
			var id:String = type + "_" + funcName;
			if (justDown) {
				_justDownDelayKeys[id] = JUST_DOWN_DELAY * MainGame.I.getFPS();
			}
			return _justDownDelayKeys[id] && _justDownDelayKeys[id] > 0;
		}
		
		private static function call(type:String, funcName:String, ...params):Boolean {
			if (!enabled) {
				return false;
			}
			if (!_inputMap[type]) {
				return false;
			}
			
			var inputs:Vector.<IGameInput> = _inputMap[type];
			for (var i:int = 0; i < inputs.length; i++) {
				if (inputs[i].enabled) {
					var func:Function = inputs[i][funcName];
					if (func == null) {
						continue;
					}
					
					if (func.apply(null, params)) {
						return true;
					}
				}
				
			}
			return false;
		}
		
		private static function callVoid(funcName:String, ...params):void {
			for each(var p:Vector.<IGameInput> in _inputMap) {
				for (var i:int = 0; i < p.length; i++) {
					if (p[i].enabled) {
						var func:Function = p[i][funcName];
						if (func == null) {
							continue;
						}
						
						func.apply(null, params);
					}
				}
			}
		}
	}
}
