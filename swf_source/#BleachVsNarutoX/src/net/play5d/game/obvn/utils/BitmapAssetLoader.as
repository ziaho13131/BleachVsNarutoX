/**
 * 已重建完成
 */
package net.play5d.game.obvn.utils {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	
	import net.play5d.game.obvn.ctrl.AssetManager;
	
	/**
	 * 位图素材加载器
	 */
	public class BitmapAssetLoader {
		
		private var _queueLength:int;					// 队列长度
		private var _urls:Array;						// url集合
		
		private var _cacheObj:Object = {};				//已缓存的图片
		
		private var _successBack:Function;				// 成功回调
		private var _processBack:Function;				// 进度回调
		
		public function getBitmap(id:*):Bitmap {
			var bd:BitmapData = _cacheObj[id];
			if (bd == null) {
				return null;
			}
			
			return new Bitmap(bd);
		}
		
		public function loadQueue(urls:Array, success:Function, process:Function = null):void {
			_successBack = success;
			_processBack = process;
			_urls = urls.concat();
			_queueLength = urls.length;
			
			loadNext();
		}
		
		private function load(url:String, back:Function = null, process:Function = null):void {
			if (url.indexOf(".") == -1) {
				loadBitmap(url, loadCom, loadFail, process);
				return;
			}
			
			// 正常加载
			AssetManager.I.loadBitmap(url, loadCom, loadFail, process);
			
			function loadCom(bp:DisplayObject):void {
				cacheBitmap(url, bp);
				if (back != null) {
					back();
				}
			}
			function loadFail():void {
				trace("BitmapAssetLoader.loadFail :: " + url);
				if (back != null) {
					back();
				}
			}
		}
		
		/**
		 * 从 face.swf 中取得图片数据
		 */
		private static function loadBitmap(cls:String, back:Function = null, fail:Function = null, process:Function = null):* {
			var b:Bitmap = AssetManager.I.getFaceBitmap(cls) as Bitmap;
			if (!b && fail != null) {
				fail();
				return;
			}
			
			if (back != null && process != null) {
				process(1);
				back(b);
			}
		}
		
		private function cacheBitmap(id:String, bp:DisplayObject):void {
			var cache:BitmapData = null;
			
			var content:Bitmap = bp as Bitmap;
			if (!content) {
				trace("BitmapAssetLoader.cacheBitmap Error!");
				return;
			}
			
			try {
				cache = content.bitmapData;
			}
			catch (e:Error) {
				trace("BitmapAssetLoader.cacheBitmap :: " + e);
			}
			
			if (cache) {
				_cacheObj[id] = cache;
			}
			AssetManager.I.disposeAsset(id);
		}
		
		private function loadNext():void {
			if (_urls.length < 1) {
				if (_successBack != null) {
					_successBack();
					_successBack = null;
				}
				return;
			}
			
			var url:String = _urls.shift();
			load(url, loadNext, loadProcess);
			
			function loadProcess(v:Number):void {
				if (_processBack != null) {
					var cur:Number = _queueLength - _urls.length - 1 + v;
					var p:Number = cur / _queueLength;
					
					_processBack(p);
				}
			}
		}
	}
}
