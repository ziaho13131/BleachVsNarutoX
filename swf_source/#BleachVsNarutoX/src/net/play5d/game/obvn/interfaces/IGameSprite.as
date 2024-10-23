/**
 * 已重建完成
 */
package net.play5d.game.obvn.interfaces {
	import flash.display.DisplayObject;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	
	import net.play5d.game.obvn.data.TeamVO;
	import net.play5d.game.obvn.fighter.models.HitVO;
	
	/**
	 * 游戏精灵接口
	 */
	public interface IGameSprite {
		
		
		function destory(dispose:Boolean = true):void;
		function isDestoryed():Boolean;
		
		function render():void;
		function renderAnimate():void;
		
		function getDisplay():DisplayObject;
		
		function get colorTransform():ColorTransform;
		function set colorTransform(ct:ColorTransform):void;
		
		function get direct():int;
		function set direct(value:int):void;
		
		function get x():Number;
		function set x(v:Number):void;
		
		function get y():Number;
		function set y(v:Number):void;
		
		function get team():TeamVO;
		function set team(value:TeamVO):void;
		
		function hit(hitvo:HitVO, target:IGameSprite):void;
		function beHit(hitvo:HitVO, hitRect:Rectangle = null):void;
		
		function getArea():Rectangle;
		function getBodyArea():Rectangle;
		
		function getCurrentHits():Array;
		function allowCrossMapXY():Boolean;
		function allowCrossMapBottom():Boolean;
		
		function getIsTouchSide():Boolean;
		function setIsTouchSide(v:Boolean):void;
		function setSpeedRate(v:Number):void;
		function setVolume(v:Number):void;
	}
}
