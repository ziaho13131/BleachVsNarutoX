/**
 * 已重建完成
 */
package net.play5d.kyo.loader {
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;
	
	/**
	 * 类加载器
	 */
	public class KyoClassLoader extends EventDispatcher {
		
		private var _classes:Object = {};
		private var _urls:Array;
		private var _defaultId:String;
		private var _loadedAmount:int;
		private var _loadLength:int;
		
		private var _directory:Dictionary = new Dictionary();
		
		private var _loading:Boolean;
		
		
		public function getClass(className:String, swf:String = null):Class {
			swf ||= _defaultId;
			
			var app:ApplicationDomain = _classes[swf];
			if (!app) {
				throw new Error(swf + "is not loaded!");
			}
			try {
				return app.getDefinition(className) as Class;
			}
			catch (e:Error) {
				throw new Error("The class definiton [" + className + "] cannot be found in \"" + swf + "\" file.");
			}
		}
		
//		public function get loadedAmount():int {
//			return _loadedAmount;
//		}
		
//		public function load(url:Object):void {
//			if (_loading) {
//				throw new Error("You cannot continue to call this method without completing the load!");
//			}
//			if (url is String) {
//				_urls = [url];
//			}
//			if (url is Array) {
//				_urls = url as Array;
//			}
//			_loadLength = _urls.length;
//			_loadedAmount = 0;
//			loadNext();
//
//			_loading = true;
//		}
		
		public function addSwf(id:String, swf:Loader):void {
			_classes[id] = swf.contentLoaderInfo.applicationDomain;
			try {
				swf.unloadAndStop(true);
			}
			catch (e:Error) {
				swf.unload();
			}
		}
		
		private function loadNext():Boolean {
			if (_urls.length < 1) {
				return false;
			}
			_loadedAmount++;
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, loadProgress);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadError);
			
			var url:String = _urls.shift();
			loader.load(new URLRequest(url));
			_directory[loader] = url;
			
			return true;
		}
		
		private function removeLoader(loader:Loader):void {
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadComplete);
			loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, loadProgress);
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loadError);
			
			try {
				loader.unloadAndStop(true);
			}
			catch (e:Error) {
				loader.unload();
			}
			
			loader = null;
		}
		
		private function loadComplete(e:Event):void {
			var loaderinfo:LoaderInfo = e.currentTarget as LoaderInfo;
			var loader:Loader = loaderinfo.loader;
			var id:String = String(_directory[loader]);
			_defaultId = _defaultId || id;
			_classes[id] = loaderinfo.applicationDomain;
			removeLoader(loader);
			checkComplete();
		}
		
		private function loadProgress(e:ProgressEvent):void {
			dispatchEvent(e);
		}
		
		private function loadError(e:IOErrorEvent):void {
			var id:String = null;
			var loader:Loader = (e.currentTarget as LoaderInfo).loader;
			if (loader && loader.loaderInfo) {
				id = loader.loaderInfo.loaderURL;
			}
			
			trace("KyoClassLoader.loadError :: " + id);
			dispatchEvent(e);
			checkComplete();
		}
		
		private function checkComplete():void {
			if (!loadNext()) {
				_loading = false;
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
	}
}
