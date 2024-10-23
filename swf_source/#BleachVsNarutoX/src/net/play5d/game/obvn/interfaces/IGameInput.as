/**
 * 已重建完成
 */
package net.play5d.game.obvn.interfaces {
	import flash.display.Stage;
	
	/**
	 * 游戏输入接口
	 */
	public interface IGameInput {
		
		function initlize(stage:Stage):void;
		
		function setConfig(config:Object):void;
		
		function get enabled():Boolean;
		function set enabled(v:Boolean):void;
		
		function focus():void;
		
		function anyKey():Boolean;
		function back():Boolean;
		function select():Boolean;
		function up():Boolean;
		function down():Boolean;
		function left():Boolean;
		function right():Boolean;
		function attack():Boolean;
		function jump():Boolean;
		function dash():Boolean;
		function skill():Boolean;
		function superSkill():Boolean;
		function special():Boolean;
		function wankai():Boolean;
		
		function clear():void;
	}
}
