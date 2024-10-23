/**
 * 已重建完成
 */
package net.play5d.kyo.sound {
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	
	/**
	 * 背景音乐播放器
	 */
	public class KyoBGSounder {
		
		private static var _i:KyoBGSounder;
		
		
		public var sound:Object;
		public var playing:Boolean;
		
		private var _snd:Sound;
		private var _channel:SoundChannel;
		private var _soundTransform:SoundTransform = new SoundTransform();
		private var _channelPausePosition:int;
		
		public static function get I():KyoBGSounder {
			_i ||= new KyoBGSounder();
			
			return _i;
		}
		
//		public function get volume():Number {
//			return _soundTransform.volume;
//		}
		
		public function set volume(value:Number):void {
			_soundTransform.volume = value;
			if (_channel) {
				_channel.soundTransform = _soundTransform;
			}
		}
		
		public function play(snd:Object = null):void {
			trace("bgm play");
			if (_snd) {
				return;
			}
			if (!snd) {
				snd = sound;
			}
			if (snd) {
				sound = snd;
				if (sound is String) {
					_snd = new Sound(new URLRequest(sound as String));
				}
				if (sound is Class) {
					_snd = new (sound as Class)();
				}
				if (sound is Sound) {
					_snd = sound as Sound;
				}
				playsnd();
				playing = true;
				return;
			}
			trace("There is no music to play!");
		}
		
		public function stop():void {
			trace("bgm stop");
			
			if (_channel) {
				_channel.stop();
				_channel = null;
			}
			if (_snd) {
				try {
					_snd.close();
				}
				catch (e:Error) {
					if (e.errorID != 2029) {
						trace("KyoBGSounder.stop :: " + e);
					}
				}
				_snd = null;
			}
			playing = false;
		}
		
		public function pause():void {
			trace("bgm pause");
			if (_channel) {
				_channelPausePosition = _channel.position;
				_channel.stop();
			}
		}
		
		public function resume():void {
			trace("bgm resume");
			if (_channel) {
				playsnd(_channelPausePosition);
			}
		}
		
//		public function toogle():void {
//			if (playing) {
//				stop();
//				return;
//			}
//
//			play();
//		}
		
		private function playsnd(position:int = 0):void {
			if (!_snd) {
				return;
			}
			
			_channel = _snd.play(position, 1, _soundTransform);
			if (!_channel) {
				return;
			}
			_channel.addEventListener(Event.SOUND_COMPLETE, playCompleteHandler);
		}
		
		private function playCompleteHandler(e:Event):void {
			if (_channel) {
				_channel.removeEventListener(Event.SOUND_COMPLETE, playCompleteHandler);
				_channel = null;
			}
			playsnd(0);
		}
	}
}
