/**
 * 已重建完成
 */
package net.play5d.game.obvn.ctrl {
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.media.Sound;
	import flash.net.URLRequest;
	
	import net.play5d.game.obvn.interfaces.IAssetLoader;
	import net.play5d.kyo.loader.KyoURLoader;
	
	/**
	 * 素材加载器
	 */
	public class AssetLoader implements IAssetLoader {
		
		public function loadXML(url:String, back:Function, fail:Function = null):void {
			KyoURLoader.load(url, function (v:String):void {
				if (back != null) {
					back(new XML(v));
				}
			}, fail);
		}
		
		public function loadSwf(url:String, back:Function, fail:Function = null, process:Function = null):void {
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadError);
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, loadProcess);
			loader.load(new URLRequest(url));
			
			function loadComplete(e:Event):void {
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadComplete);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loadError);
				loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, loadProcess);
				if (back != null) {
					back(loader);
				}
			}
			function loadError(e:Event):void {
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadComplete);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loadError);
				loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, loadProcess);
				if (fail != null) {
					fail();
				}
			}
			function loadProcess(e:ProgressEvent):void {
				if (process != null) {
					process(e.bytesLoaded / e.bytesTotal);
				}
			}
		}
		
		public function loadBitmap(url:String, back:Function, fail:Function = null, process:Function = null):void {
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadError);
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, loadProcess);
			loader.load(new URLRequest(url));
			
			function loadComplete(e:Event):void {
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadComplete);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loadError);
				loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, loadProcess);
				if (back != null) {
					back(loader.content);
				}
			}
			function loadError(e:Event):void {
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadComplete);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loadError);
				loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, loadProcess);
				if (fail != null) {
					fail();
				}
			}
			function loadProcess(e:ProgressEvent):void {
				if (process != null) {
					process(e.bytesLoaded / e.bytesTotal);
				}
			}
		}
		
		public function loadSound(url:String, back:Function, fail:Function = null, process:Function = null):void {
			var sound:Sound = new Sound(new URLRequest(url));
			sound.addEventListener(Event.COMPLETE, loadCom);
			sound.addEventListener(IOErrorEvent.IO_ERROR, loadErr);
			sound.addEventListener(ProgressEvent.PROGRESS, loadProcess);
			
			function loadCom(e:Event):void {
				sound.removeEventListener(Event.COMPLETE, loadCom);
				sound.removeEventListener(IOErrorEvent.IO_ERROR, loadErr);
				sound.removeEventListener(ProgressEvent.PROGRESS, loadProcess);
				if (back != null) {
					back(sound);
				}
			}
			function loadErr(e:IOErrorEvent):void {
				sound.removeEventListener(Event.COMPLETE, loadCom);
				sound.removeEventListener(IOErrorEvent.IO_ERROR, loadErr);
				sound.removeEventListener(ProgressEvent.PROGRESS, loadProcess);
				if (fail != null) {
					fail();
				}
			}
			function loadProcess(e:ProgressEvent):void {
				if (process != null) {
					process(e.bytesLoaded / e.bytesTotal);
				}
			}
		}
		
		public function dispose(url:String):void {}
		
		public function needPreLoad():Boolean {
			return false;
		}
		
		public function loadPreLoad(back:Function, fail:Function = null, process:Function = null):void {}
	}
}
