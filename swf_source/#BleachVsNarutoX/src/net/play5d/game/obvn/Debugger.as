/**
 * 已重建完成
 */
package net.play5d.game.obvn {
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.utils.Timer;
	
	import net.play5d.game.obvn.ui.UIUtils;
	import net.play5d.kyo.display.BitmapText;
	
	/**
	 * 调试类
	 */
	public class Debugger {
		
		public static var onErrorMsgCall:Function;				// 错误信息回调函数
		
//		public static const DRAW_AREA:Boolean = false;			// 绘制区域
//		public static const SAFE_MODE:Boolean = false;			// 安全模式
//		public static const DEBUG_ENABLED:Boolean = false;		// 是否启用 DEBUG
//		public static const HIDE_MAP:Boolean = false;			// 隐藏地图
//		public static const HIDE_HITEFFECT:Boolean = false;		// 隐藏攻击特效
		
		private static var _stage:Stage;						// 主场景
		
		/**
		 * 记录
		 */
		public static function log(...params):void {
			trace.call(null, params);
		}
		
		/**
		 * 输出错误信息
		 */
		public static function errorMsg(msg:String):void {
			if (msg) {
				trace("Debugger.errorMsg :: " + msg);
			}
			
			if (onErrorMsgCall != null) {
				onErrorMsgCall(msg);
			}
		}
		
		/**
		 * 初始化 Debugger
		 */
		public static function initDebug(stage:Stage):void {
			_stage = stage;
			
			showFPS();
		}
		
		public static function addChild(d:DisplayObject):void {
			_stage.addChild(d);
		}
		
		/**
		 * 显示 FPS
		 */
		public static function showFPS():void {
			var fpsCount:int = 0;
			
			var fpsText:BitmapText = new BitmapText(true, 0xFFFFFF, [new GlowFilter(0x000000, 1, 3, 3, 3)]);
			fpsText.font = "Microsoft YaHei";
			UIUtils.formatText(fpsText.textfield, {
				color: 0xFFFFFF
			});
			
			_stage.addChild(fpsText);
			_stage.addEventListener(Event.ENTER_FRAME, countFPS);
			
			function countFPS(e:Event):void {
				fpsCount++;
			}
			
			var fpsTimer:Timer = new Timer(1000, 0);
			fpsTimer.addEventListener(TimerEvent.TIMER, updateFPS);
			fpsTimer.start();
			
			function updateFPS(e:TimerEvent):void {
				fpsText.text = "FPS:" + fpsCount;
				fpsCount = 0;
			}
		}
	}
}
