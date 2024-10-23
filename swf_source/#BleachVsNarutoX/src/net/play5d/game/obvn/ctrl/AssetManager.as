/**
 * 已重建完成
 */
package net.play5d.game.obvn.ctrl {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.geom.Point;
	import flash.media.Sound;
	
	import net.play5d.game.obvn.data.AssisterModel;
	import net.play5d.game.obvn.data.FighterModel;
	import net.play5d.game.obvn.data.FighterVO;
	import net.play5d.game.obvn.data.MapModel;
	import net.play5d.game.obvn.data.MapVO;
	import net.play5d.game.obvn.interfaces.IAssetLoader;
	import net.play5d.game.obvn.utils.BitmapAssetLoader;
	import net.play5d.kyo.display.bitmap.BitmapFont;
	import net.play5d.kyo.display.bitmap.BitmapFontLoader;
	import net.play5d.kyo.loader.KyoClassLoader;
	import net.play5d.kyo.loader.KyoSoundLoader;
	import net.play5d.kyo.utils.KyoUtils;
	
	/**
	 * 素材管理器
	 */
	public class AssetManager {
		
		private static var _i:AssetManager;
		
		private var _swfLoader       :KyoClassLoader    = new KyoClassLoader();
		private var _soundLoader     :KyoSoundLoader    = new KyoSoundLoader();
		private var _bitmapLoader    :BitmapAssetLoader = new BitmapAssetLoader();
		private var _bitmapFontLoader:BitmapFontLoader  = new BitmapFontLoader();
		private var _assetLoader     :IAssetLoader      = new AssetLoader();
		
		private const _effectSwfPath:String = "assets/effect.swf";
		private const _faceSwfPath  :String = "assets/face.swf";
		
//		private var _fighterFaceCache:Object = {};
		
		public static function get I():AssetManager {
			_i ||= new AssetManager();
			
			return _i;
		}
		
		public function getFont(id:String):BitmapFont {
			return _bitmapFontLoader.getFont(id);
		}
		
//		public function setAssetLoader(v:IAssetLoader):void {
//			_assetLoader = v;
//		}
		
		public function loadBasic(back:Function, process:Function = null):void {
			var type:String;
			var loadStep:int = 0;
			var loadCount:int = 4;
			loadNext();
			
			function loadProcess(p:Number):void {
				if (process != null) {
					process(p, type, loadStep, loadCount);
				}
			}
			function loadNext():void {
				switch (loadStep) {
					case 0:
						loadPreLoadSounds(loadNext, loadProcess);
						type = "声音";
						loadProcess(0);
						break;
					case 1:
						loadGraphics([_effectSwfPath, _faceSwfPath], loadNext, loadProcess);
						type = "特效";
						loadProcess(0);
						break;
					case 2:
						loadFonts(loadNext, loadProcess);
						type = "字体";
						loadProcess(0);
						break;
					case 3:
						loadBitmaps(loadNext, loadProcess);
						type = "图片";
						loadProcess(0);
						break;
					case 4:
						initAssets();
						if (back != null) {
							back();
							break;
						}
				}
				loadStep++;
			}
		}
		
		private function loadPreLoadSounds(back:Function, process:Function):void {
			_assetLoader.loadXML("assets/config/preload.xml", function (xml:XML):void {
				var sounds:Array = [];
				var bgmPath:String = xml.bgm.@path;
				var soundPath:String = xml.sound.@path;
				
				for each(var i:XML in xml.bgm.item) {
					sounds.push(bgmPath + "/" + i.toString());
				}
				for each(var j:XML in xml.sound.item) {
					sounds.push(soundPath + "/" + j.toString());
				}
				loadSnds(sounds, back, process);
			});
		}
		
		private function loadSnds(sounds:Array, back:Function, process:Function):void {
			var curUrl:String;
			
			var snds:Array = sounds.concat();
			var sndLen:int = int(snds.length);
			loadNext();
			
			function loadNext():void {
				if (snds.length < 1) {
					if (back != null) {
						back();
					}
					return;
				}
				curUrl = snds.shift();
				_assetLoader.loadSound(curUrl, loadCom, loadErr, loadProcess);
			}
			function loadCom(snd:Sound):void {
				_soundLoader.addSound(curUrl, snd);
				_assetLoader.dispose(curUrl);
				loadNext();
			}
			function loadErr():void {
				trace("Failed to load sound : " + curUrl);
				loadNext();
			}
			function loadProcess(v:Number):void {
				if (process != null) {
					var cur:Number = sndLen - snds.length - 1 + v;
					var p:Number = cur / sndLen;
					process(p);
				}
			}
		}
		
		private function initAssets():void {
			var font1:BitmapFont = getFont("font1");
			if (font1) {
				font1.charGap = -8;
				font1.spaceGap = 10;
				font1.offsetY = -5;
			}
		}
		
		public function getEffect(className:String):* {
			var cls:Class = _swfLoader.getClass(className, _effectSwfPath);
			return new cls();
		}
		
		public function getFaceBitmap(className:String):Bitmap {
			var cls:Class = _swfLoader.getClass(className, _faceSwfPath);
			
			var bd:BitmapData = new cls() as BitmapData;
			return new Bitmap(bd);
		}
		
		public function getSound(name:String):Sound {
			return _soundLoader.getSound(name);
		}
		
		public function getFighterFace(fv:FighterVO, size:Point = null):DisplayObject {
			var bp:Bitmap = _bitmapLoader.getBitmap(fv.faceCls);
			if (!bp) {
				return null;
			}
			if (!size) {
				size = new Point(50, 50);
			}
			
			bp.width = size.x;
			bp.height = size.y;
			
			return bp;
		}
		
		public function getFighterFaceBig(fv:FighterVO, size:Point = null):DisplayObject {
			var bp:Bitmap = _bitmapLoader.getBitmap(fv.faceBigCls);
			if (!bp) {
				return null;
			}
			if (!size) {
				size = new Point(245, 62);
			}
			
			bp.width = size.x;
			bp.height = size.y;
			
			return bp;
		}
		
		public function getFighterFaceBar(fv:FighterVO, size:Point = null):DisplayObject {
			var bp:Bitmap = _bitmapLoader.getBitmap(fv.faceBarCls);
			if (!bp) {
				return null;
			}
			if (!size) {
				size = new Point(102, 64);
			}
			
			bp.width = size.x;
			bp.height = size.y;
			return bp;
		}
		
		public function getFighterFaceWin(fv:FighterVO, size:Point = null):DisplayObject {
			if (!fv.faceWinCls) {
				return null;
			}
			
			var bp:Bitmap = _bitmapLoader.getBitmap(fv.faceWinCls);
			if (!bp) {
				return null;
			}
			if (!size) {
				size = new Point(300, 250);
			}
			
			bp.width = size.x;
			bp.height = size.y;
			
			return bp;
		}
		
		public function getMapPic(mv:MapVO, size:Point = null):DisplayObject {
			var bp:Bitmap = _bitmapLoader.getBitmap(mv.picUrl);
			
			if (!bp) {
				return null;
			}
			if (!size) {
				size = new Point(450, 240);
			}
			
			bp.width = size.x;
			bp.height = size.y;
			
			return bp;
		}
		
		public function loadXML(url:String, back:Function, fail:Function):void {
			_assetLoader.loadXML(url, back, fail);
		}
		
		public function loadSWF(url:String, back:Function, fail:Function = null, process:Function = null):void {
			_assetLoader.loadSwf(url, back, fail, process);
		}
		
		public function loadSound(url:String, back:Function, fail:Function = null, process:Function = null):void {
			_assetLoader.loadSound(url, back, fail, process);
		}
		
		public function loadBitmap(url:String, back:Function, fail:Function = null, process:Function = null):void {
			_assetLoader.loadBitmap(url, back, fail, process);
		}
		
		public function disposeAsset(url:String):void {
			_assetLoader.dispose(url);
		}
		
		private function loadGraphics(loadarray:Array, back:Function = null, process:Function = null):void {
			var loadedAmount:int = 0;
			var curUrl:String = null;
			var loads:Array = loadarray.concat();
			var queueLength:int = loads.length;
			loadNext();
			
			function loadNext():void {
				if (loads.length < 1) {
					if (back != null) {
						back();
					}
					return;
				}
				curUrl = loads.shift();
				_assetLoader.loadSwf(curUrl, loadCom, loadFail, loadProcess);
			}
			function loadCom(loader:Loader):void {
				loadedAmount++;
				_swfLoader.addSwf(curUrl, loader);
				_assetLoader.dispose(curUrl);
				loadNext();
			}
			function loadFail():void {
				trace("Error :: " + curUrl + " load fail!");
				loadNext();
			}
			function loadProcess(p:Number):void {
				if (process != null) {
					var cur:Number = queueLength - loads.length - 1 + p;
					process(cur / queueLength);
				}
			}
		}
		
		private function loadBitmaps(back:Function = null, process:Function = null):void {
			var bps:Array = getFighterFaceUrls(FighterModel.I.getAllFighters(), true, true);
			bps = bps.concat(getFighterFaceUrls(AssisterModel.I.getAllAssisters()));
			bps = bps.concat(getMapPicUrls(MapModel.I.getAllMaps()));
			
			// 去除相同
			KyoUtils.array_deleteSames(bps);
			_bitmapLoader.loadQueue(bps, back, process);
		}
		
		private function loadFonts(back:Function = null, process:Function = null):void {
			var fontXML:XML;
			var fontBitmapUrl:String;
			const url:String = "assets/font/font1.xml";
			_assetLoader.loadXML(url, loadXMLCom, loadXMLFail);
			
			function loadXMLCom(xml:XML):void {
				fontXML = xml;
				
				var bpurl:String = String(xml.pages.page.@file);
				var floder:String = url.substr(0, url.lastIndexOf("/") + 1);
				
				fontBitmapUrl = floder + bpurl;
				
				_assetLoader.loadBitmap(fontBitmapUrl, bitmapCom, bitmapFail);
			}
			function bitmapCom(d:DisplayObject):void {
				var bp:Bitmap = d as Bitmap;
				
				_bitmapFontLoader.addFont(fontXML, bp.bitmapData);
				_assetLoader.dispose(fontBitmapUrl);
				
				if (back != null) {
					back();
				}
			}
			function bitmapFail():void {
				trace("Font image load failed. url:" + url);
			}
			function loadXMLFail():void {
				trace("Font xml load failed. url:" + url);
			}
		}
		
		private static function getFighterFaceUrls(fighters:Object, loadBar:Boolean = false, loadWin:Boolean = false):Array {
			var ra:Array = [];
			for each(var i:FighterVO in fighters) {
				if (i.faceCls) {
					ra.push(i.faceCls);
				}
				if (i.faceBigCls) {
					ra.push(i.faceBigCls);
				}
				if (loadBar && i.faceBarCls) {
					ra.push(i.faceBarCls);
				}
				if (loadWin && i.faceWinCls) {
					ra.push(i.faceWinCls);
				}
			}
			
			return ra;
		}
		
		private static function getMapPicUrls(maps:Object):Array {
			var ra:Array = [];
			
			for each(var i:MapVO in maps) {
				ra.push(i.picUrl);
			}
			
			return ra;
		}
		
		public function needPreLoad():Boolean {
			return _assetLoader.needPreLoad();
		}
		
		public function loadPreLoad(back:Function, fail:Function = null, process:Function = null):void {
			_assetLoader.loadPreLoad(back, fail, process);
		}
	}
}
