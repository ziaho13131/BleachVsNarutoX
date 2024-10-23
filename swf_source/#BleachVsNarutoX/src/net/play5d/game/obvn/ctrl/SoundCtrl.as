/**
 * 已重建完成
 */
package net.play5d.game.obvn.ctrl {
	import flash.media.Sound;
	import flash.media.SoundTransform;
	
	import net.play5d.kyo.loader.KyoSoundLoader;
	import net.play5d.kyo.sound.KyoBGSounder;
	import net.play5d.kyo.utils.KyoRandom;
	
	/**
	 * 声音控制器
	 */
	public class SoundCtrl {
		
		private static var _i:SoundCtrl;
		
		private var _bgSound:KyoBGSounder;
		
		private var _soundLoader:KyoSoundLoader;
		
		private var _bgmObj:Object;
		
		private var _bgmPaused:Boolean = false;
		
		private var _waitingSound:Object;
		
		private var _sndTransform:SoundTransform = new SoundTransform();
		
		public static function get I():SoundCtrl {
			_i ||= new SoundCtrl();
			
			return _i;
		}
		
		public function setSoundVolumn(v:Number):void {
			_sndTransform.volume = v;
		}
		
		public function setBgmVolumn(v:Number):void {
			if (!_bgSound) {
				_bgSound = new KyoBGSounder();
			}
			
			_bgSound.volume = v;
		}
		
		public function playAssetSound(name:String, vol:Number = 1):void {
			if (name == null) {
				return;
			}
			
			var sound:Sound = AssetManager.I.getSound(name);
			if (sound) {
				var st:SoundTransform = _sndTransform;
				if (vol != 1) {
					st = new SoundTransform(vol * _sndTransform.volume);
				}
				
				sound.play(0, 0, st);
			}
		}
		
		public function playEffectSound(name:String, vol:Number = 1):void {
			if (name == null) {
				return;
			}
			var sound:Sound = AssetManager.I.getEffect(name);
			if (sound) {
				var st:SoundTransform = _sndTransform;
				if (vol != 1) {
					st = new SoundTransform(vol * _sndTransform.volume);
				}
				
				sound.play(0, 0, st);
			}
		}
		
		public function playAssetSoundRandom(...params):void {
			var name:String = KyoRandom.getRandomInArray(params);
			
			playAssetSound(name);
		}
		
		public function playSwcSound(sc:Class):void {
			var snd:Sound = new sc() as Sound;
			
			if (snd) {
				snd.play(0, 0, _sndTransform);
			}
		}
		
		public function BGM(sound:Object):void {
			if (_bgmPaused) {
				_waitingSound = sound;
				return;
			}
			
			if (!_bgSound) {
				_bgSound = new KyoBGSounder();
			}
			
			if (_bgSound.sound == sound) {
				return;
			}
			if (_bgSound.playing) {
				_bgSound.stop();
			}
			
			if (sound) {
				_bgSound.play(sound);
			}
		}
		
//		public function pauseBGM():void {
//			if (_bgmPaused) {
//				return;
//			}
//
//			_bgmPaused = true;
//			if (_bgSound) {
//				_bgSound.pause();
//			}
//		}
//
//		public function resumeBGM():void {
//			if (!_bgmPaused) {
//				return;
//			}
//
//			_bgmPaused = false;
//			if (_waitingSound) {
//				BGM(_waitingSound);
//				_waitingSound = null;
//				return;
//			}
//			if (_bgSound) {
//				_bgSound.resume();
//			}
//		}
		
		public function loadFightBGM(arr:Array, success:Function, fail:Function = null, process:Function = null):void {
			var curUrl:String;
			
			_bgmObj = {};
			var urls:Array = [];
			for each(var o:Object in arr) {
				_bgmObj[o.id] = o;
				urls.push(o.url);
			}
			
			_soundLoader = new KyoSoundLoader();
			var sndLen:int = int(urls.length);
			loadNext();
			
			function loadNext():void {
				if (urls.length < 1) {
					if (success != null) {
						success();
					}
					
					return;
				}
				
				curUrl = urls.shift();
				AssetManager.I.loadSound(curUrl, loadBack, loadFail, loadProcess);
			}
			function loadBack(snd:Sound):void {
				_soundLoader.addSound(curUrl, snd);
				loadNext();
			}
			function loadFail():void {
				trace("SoundCtrl.loadFightBGM fail!" + curUrl);
				
				loadNext();
			}
			function loadProcess(v:Number):void {
				if (process != null) {
					var cur:Number = sndLen - urls.length - 1 + v;
					var p:Number = cur / sndLen;
					process(p);
				}
			}
		}
		
		public function playFightBGM(id:String):void {
			var o:Object = _bgmObj[id];
			if (id == "map") {
				if (o == null) {
					return;
				}
			}
			else {
				if (o == null) {
					playFightBGM("map");
					return;
				}
				if (Math.random() > Number(o.rate)) {
					playFightBGM("map");
					return;
				}
			}
			
			var sound:Sound = _soundLoader.getSound(o.url);
			BGM(sound);
		}
		
//		public function unloadFightBGM():void {
//			BGM(null);
//
//			if (_soundLoader) {
//				_soundLoader.unload();
//				_soundLoader = null;
//			}
//		}
		
		public function sndSelect():void {
			playSwcSound(snd_menu1);
		}
		
		public function sndConfrim():void {
			playSwcSound(snd_menu2);
		}
	}
}
