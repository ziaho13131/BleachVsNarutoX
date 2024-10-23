/**
 * 已重建完成
 */
package net.play5d.game.obvn.interfaces {
	
	/**
	 * 素材加载器接口
	 */
	public interface IAssetLoader {
		
		function loadXML(url:String, back:Function, fail:Function = null):void;
		function loadSwf(url:String, back:Function, fail:Function = null, process:Function = null):void;
		function loadSound(url:String, back:Function, fail:Function = null, process:Function = null):void;
		function loadBitmap(url:String, back:Function, fail:Function = null, process:Function = null):void;
		
		function dispose(url:String):void;
		function needPreLoad():Boolean;
		function loadPreLoad(back:Function, fail:Function = null, process:Function = null):void;
	}
}
